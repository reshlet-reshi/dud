#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc == 1) {
        fprintf(stderr, "dud-sh: missing command\n");
        return 2;
    }

    if (strcmp(argv[1], "-c") == 0) {
        if (argc == 2) {
            fprintf(stderr, "dud-sh: -c requires a command string\n");
            return 2;
        }

        if (argc == 3 && strcmp(argv[2], ":") == 0) {
            return 0;
        }

        fprintf(stderr, "dud-sh: unsupported command\n");
        return 2;
    }

    fprintf(stderr, "dud-sh: unsupported invocation\n");
    return 2;
}
