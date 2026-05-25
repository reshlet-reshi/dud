#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

typedef struct {
    char *data;
    size_t len;
    size_t cap;
} String;

static int usage(void) {
    fputs(
        "usage: expect output EXPECTED ACTUAL LABEL\n"
        "       expect status EXPECTED_STATUS COMMAND [ARG...]\n"
        "       expect error EXPECTED_STATUS EXPECTED_ERROR COMMAND [ARG...]\n",
        stderr);
    return 2;
}

static int internal_error(char *label) {
    fprintf(stderr, "%s: %s\n", label, strerror(errno));
    return 2;
}

static int parse_status(char *s, int *out) {
    char *end = NULL;
    long value;

    errno = 0;
    value = strtol(s, &end, 10);

    if (errno != 0 || s[0] == '\0' || *end != '\0') {
        return 0;
    }

    if (value < INT_MIN || value > INT_MAX) {
        return 0;
    }

    *out = (int) value;
    return 1;
}

static void print_command(char **argv) {
    int i = 0;

    while (argv[i] != NULL) {
        if (i != 0) {
            fputc(' ', stderr);
        }
        fputs(argv[i], stderr);
        i = i + 1;
    }
}

static int wait_for_status(pid_t pid, int *status_out) {
    int wait_status;

    while (waitpid(pid, &wait_status, 0) == -1) {
        if (errno != EINTR) {
            return -1;
        }
    }

    if (WIFEXITED(wait_status)) {
        *status_out = WEXITSTATUS(wait_status);
        return 0;
    }

    if (WIFSIGNALED(wait_status)) {
        *status_out = 128 + WTERMSIG(wait_status);
        return 0;
    }

    *status_out = 2;
    return 0;
}

static int append_bytes(String *string, char *bytes, size_t bytes_len) {
    size_t needed;
    size_t cap;
    char *data;

    if (bytes_len > SIZE_MAX - string->len - 1) {
        errno = ENOMEM;
        return -1;
    }

    needed = string->len + bytes_len + 1;
    cap = string->cap;

    if (cap == 0) {
        cap = 4096;
    }

    while (cap < needed) {
        if (cap > SIZE_MAX / 2) {
            errno = ENOMEM;
            return -1;
        }
        cap = cap * 2;
    }

    if (cap != string->cap) {
        data = realloc(string->data, cap);
        if (data == NULL) {
            return -1;
        }
        string->data = data;
        string->cap = cap;
    }

    memcpy(string->data + string->len, bytes, bytes_len);
    string->len = string->len + bytes_len;
    string->data[string->len] = '\0';
    return 0;
}

static int read_all(int fd, String *string) {
    char buffer[4096];

    for (;;) {
        ssize_t n = read(fd, buffer, sizeof(buffer));

        if (n > 0) {
            if (append_bytes(string, buffer, (size_t) n) != 0) {
                return -1;
            }
            continue;
        }

        if (n == 0) {
            if (string->data == NULL && append_bytes(string, "", 0) != 0) {
                return -1;
            }
            return 0;
        }

        if (errno != EINTR) {
            return -1;
        }
    }
}

static void strip_trailing_newlines(String *string) {
    while (string->len > 0 && string->data[string->len - 1] == '\n') {
        string->len = string->len - 1;
        string->data[string->len] = '\0';
    }
}

static int exec_failure_status(int err) {
    if (err == ENOENT) {
        return 127;
    }

    return 126;
}

static int run_status_command(char **command_argv, int *status_out) {
    int null_fd;
    pid_t pid;

    null_fd = open("/dev/null", O_WRONLY);
    if (null_fd == -1) {
        return -1;
    }

    pid = fork();
    if (pid == -1) {
        int saved_errno = errno;
        close(null_fd);
        errno = saved_errno;
        return -1;
    }

    if (pid == 0) {
        if (dup2(null_fd, STDOUT_FILENO) == -1) {
            _exit(126);
        }
        if (dup2(null_fd, STDERR_FILENO) == -1) {
            _exit(126);
        }
        if (null_fd > STDERR_FILENO) {
            close(null_fd);
        }

        execvp(command_argv[0], command_argv);
        _exit(exec_failure_status(errno));
    }

    close(null_fd);
    return wait_for_status(pid, status_out);
}

static int run_error_command(
    char **command_argv,
    int *status_out,
    String *error_out
) {
    int null_fd;
    int pipe_fds[2];
    pid_t pid;
    int read_result;

    null_fd = open("/dev/null", O_WRONLY);
    if (null_fd == -1) {
        return -1;
    }

    if (pipe(pipe_fds) == -1) {
        int saved_errno = errno;
        close(null_fd);
        errno = saved_errno;
        return -1;
    }

    pid = fork();
    if (pid == -1) {
        int saved_errno = errno;
        close(null_fd);
        close(pipe_fds[0]);
        close(pipe_fds[1]);
        errno = saved_errno;
        return -1;
    }

    if (pid == 0) {
        close(pipe_fds[0]);
        if (dup2(null_fd, STDOUT_FILENO) == -1) {
            _exit(126);
        }
        if (dup2(pipe_fds[1], STDERR_FILENO) == -1) {
            _exit(126);
        }
        if (null_fd > STDERR_FILENO) {
            close(null_fd);
        }
        if (pipe_fds[1] > STDERR_FILENO) {
            close(pipe_fds[1]);
        }

        execvp(command_argv[0], command_argv);
        _exit(exec_failure_status(errno));
    }

    close(null_fd);
    close(pipe_fds[1]);

    read_result = read_all(pipe_fds[0], error_out);
    close(pipe_fds[0]);

    if (wait_for_status(pid, status_out) != 0) {
        return -1;
    }

    if (read_result != 0) {
        return -1;
    }

    strip_trailing_newlines(error_out);
    return 0;
}

static int expect_output(int argc, char *argv[]) {
    char *expected;
    char *actual;
    char *label;

    if (argc != 5) {
        return usage();
    }

    expected = argv[2];
    actual = argv[3];
    label = argv[4];

    if (strcmp(actual, expected) != 0) {
        fprintf(
            stderr,
            "%s: expected \"%s\", got \"%s\"\n",
            label,
            expected,
            actual);
        return 1;
    }

    return 0;
}

static int expect_status(int argc, char *argv[]) {
    int expected;
    int actual;

    if (argc < 4 || !parse_status(argv[2], &expected)) {
        return usage();
    }

    if (run_status_command(&argv[3], &actual) != 0) {
        return internal_error("expect status");
    }

    if (actual != expected) {
        fprintf(stderr, "expected exit %d, got %d: ", expected, actual);
        print_command(&argv[3]);
        fputc('\n', stderr);
        return 1;
    }

    return 0;
}

static int expect_error(int argc, char *argv[]) {
    int expected_status;
    int actual_status;
    char *expected_error;
    String actual_error = {0};

    if (argc < 5 || !parse_status(argv[2], &expected_status)) {
        return usage();
    }

    expected_error = argv[3];

    if (run_error_command(&argv[4], &actual_status, &actual_error) != 0) {
        free(actual_error.data);
        return internal_error("expect error");
    }

    if (actual_status != expected_status) {
        fprintf(
            stderr,
            "expected exit %d, got %d: ",
            expected_status,
            actual_status);
        print_command(&argv[4]);
        fputc('\n', stderr);
        free(actual_error.data);
        return 1;
    }

    if (strcmp(actual_error.data, expected_error) != 0) {
        fprintf(
            stderr,
            "expected stderr \"%s\", got \"%s\": ",
            expected_error,
            actual_error.data);
        print_command(&argv[4]);
        fputc('\n', stderr);
        free(actual_error.data);
        return 1;
    }

    free(actual_error.data);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        return usage();
    }

    if (strcmp(argv[1], "output") == 0) {
        return expect_output(argc, argv);
    }

    if (strcmp(argv[1], "status") == 0) {
        return expect_status(argc, argv);
    }

    if (strcmp(argv[1], "error") == 0) {
        return expect_error(argc, argv);
    }

    return usage();
}
