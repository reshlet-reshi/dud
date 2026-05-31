#define _GNU_SOURCE

#include "seccomp.h"

#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/prctl.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <unistd.h>

#ifndef MAP_STACK
#define MAP_STACK 0
#endif

#ifndef SYS_close_range
#ifdef __NR_close_range
#define SYS_close_range __NR_close_range
#endif
#endif

#define MAX_TARGET_SIZE (1024U * 1024U)
#define CLEAN_STACK_SIZE (16U * 1024U)
#define CLOSE_FALLBACK_MAX (1024UL * 1024UL)

void sandbox_jump(void *entry, void *stack_top) __attribute__((noreturn));

static int read_exact(int fd, unsigned char *buf, size_t len) {
    size_t off = 0;

    while (off < len) {
        ssize_t n = read(fd, buf + off, len - off);

        if (n > 0) {
            off = off + (size_t) n;
            continue;
        }

        if (n == 0) {
            errno = EIO;
            return -1;
        }

        if (errno != EINTR) {
            return -1;
        }
    }

    return 0;
}

static int load_target(void **entry_out) {
    int fd;
    struct stat st;
    void *mem;
    size_t size;

    fd = open("/target", O_RDONLY | O_CLOEXEC);
    if (fd == -1) {
        return -1;
    }

    if (fstat(fd, &st) == -1) {
        int saved_errno = errno;
        close(fd);
        errno = saved_errno;
        return -1;
    }

    if (st.st_size <= 0 || st.st_size > (off_t) MAX_TARGET_SIZE) {
        close(fd);
        errno = EFBIG;
        return -1;
    }

    size = (size_t) st.st_size;
    mem = mmap(
        NULL,
        size,
        PROT_READ | PROT_WRITE,
        MAP_PRIVATE | MAP_ANONYMOUS,
        -1,
        0
    );
    if (mem == MAP_FAILED) {
        int saved_errno = errno;
        close(fd);
        errno = saved_errno;
        return -1;
    }

    if (read_exact(fd, mem, size) == -1) {
        int saved_errno = errno;
        close(fd);
        munmap(mem, size);
        errno = saved_errno;
        return -1;
    }

    if (close(fd) == -1) {
        int saved_errno = errno;
        munmap(mem, size);
        errno = saved_errno;
        return -1;
    }

    if (mprotect(mem, size, PROT_READ | PROT_EXEC) == -1) {
        int saved_errno = errno;
        munmap(mem, size);
        errno = saved_errno;
        return -1;
    }

    *entry_out = mem;
    return 0;
}

static int allocate_clean_stack(void **stack_top_out) {
    unsigned char *stack;
    uintptr_t top;

    stack = mmap(
        NULL,
        CLEAN_STACK_SIZE,
        PROT_READ | PROT_WRITE,
        MAP_PRIVATE | MAP_ANONYMOUS | MAP_STACK,
        -1,
        0
    );
    if (stack == MAP_FAILED) {
        return -1;
    }

    top = (uintptr_t) (stack + CLEAN_STACK_SIZE);
    top = top & ~(uintptr_t) 0xfU;
    *stack_top_out = (void *) top;
    return 0;
}

static int close_all_fds(void) {
#ifdef SYS_close_range
    if (syscall(SYS_close_range, 0U, ~0U, 0U) == 0) {
        return 0;
    }

    if (errno != ENOSYS && errno != EINVAL) {
        return -1;
    }
#endif

    {
        struct rlimit limit;
        unsigned long max_fd = 1024UL;
        unsigned long fd;

        if (getrlimit(RLIMIT_NOFILE, &limit) == 0 &&
            limit.rlim_cur != RLIM_INFINITY &&
            limit.rlim_cur > 0) {
            max_fd = (unsigned long) limit.rlim_cur;
        }

        if (max_fd > CLOSE_FALLBACK_MAX) {
            max_fd = CLOSE_FALLBACK_MAX;
        }

        for (fd = 0; fd < max_fd; fd = fd + 1) {
            while (close((int) fd) == -1 && errno == EINTR) {
            }
        }
    }

    return 0;
}

int main(int argc, char **argv) {
    void *entry = NULL;
    void *stack_top = NULL;

    (void) argc;
    (void) argv;

    if (load_target(&entry) == -1) {
        return 126;
    }

    if (allocate_clean_stack(&stack_top) == -1) {
        return 126;
    }

    if (close_all_fds() == -1) {
        return 126;
    }

    if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0) == -1) {
        return 126;
    }

    if (install_exit0_seccomp() == -1) {
        return 126;
    }

    sandbox_jump(entry, stack_top);
}

