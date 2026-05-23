#include <stdio.h>

#include "exit.h"
#include "wc_c.h"

void wc_c(FILE *input) {
    unsigned char buffer[8192];
    int count = 0;

    for (;;) {
        int bytes_read;

        bytes_read = fread(buffer, 1, sizeof(buffer), input);
        count += bytes_read;

        if (bytes_read < sizeof(buffer)) {
            if (ferror(input)) {
                exit_1();
            }

            break;
        }
    }

    if (printf("%d\n", count) < 0) {
        exit_1();
    }

    if (fflush(stdout) == EOF) {
        exit_1();
    }

    return;
}
