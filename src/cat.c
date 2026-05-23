#include <stdio.h>

#include "cat.h"
#include "exit.h"

void cat(FILE *input) {
    unsigned char buffer[8192];

    for (;;) {
        int bytes_read;

        bytes_read = fread(buffer, 1, sizeof(buffer), input);
        if (
            bytes_read > 0 && 
            fwrite(buffer, 1, bytes_read, stdout) != bytes_read
        ) {
            exit_1();
        }

        if (bytes_read < sizeof(buffer)) {
            if (ferror(input)) {
                exit_1();
            }

            break;
        }
    }

    if (fflush(stdout) == EOF) {
        exit_1();
    }

    return;
}
