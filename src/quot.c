#include <stdio.h>

#include "exit.h"
#include "quot.h"

void quot_bytes(FILE *input) {
    int byte;

    while ((byte = fgetc(input)) != EOF) {
        int output;

        if (byte == '#') {
            output = '#';
        } else if (byte == ' ') {
            output = ' ';
        } else if (byte >= '!' && byte <= '~') {
            output = '.';
        } else {
            output = '\n';
        }

        if (fputc(output, stdout) == EOF) {
            exit_1();
        }
    }

    if (ferror(input)) {
        exit_1();
    }

    if (fflush(stdout) == EOF) {
        exit_1();
    }

    return;
}
