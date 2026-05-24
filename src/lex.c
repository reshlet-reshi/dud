#include <stdio.h>

#include "exit.h"
#include "lex.h"

int to_lexer_symbol(int byte) {
    if (byte == '#') {
        return '#';
    }

    if (byte == ' ') {
        return ' ';
    }

    if (byte >= '!' && byte <= '~') {
        return '.';
    }

    return '\n';
}

void to_lexer_symbols(FILE *input) {
    int byte;
    while ((byte = fgetc(input)) != EOF) {
        int written = fputc(
            to_lexer_symbol(byte), 
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
