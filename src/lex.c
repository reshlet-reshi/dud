#include <stdio.h>

#include "exit.h"
#include "lex.h"

unsigned char to_lexer_symbol(int c) {
    if (c == '#') {
        return '#';
    }

    if (c == ' ') {
        return ' ';
    }

    if (c >= '!' && c <= '~') {
        return '.';
    }

    return '\n';
}

void to_lexer_symbols(void *arg) {
    FILE *input = (FILE *) arg;
    int c;

    while ((c = fgetc(input)) != EOF) {
        int written = fputc(
            to_lexer_symbol(c), 
            stdout
        );
        if (written == EOF) {
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
