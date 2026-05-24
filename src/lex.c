#include "dud/io.h"
#include "dud/exit.h"
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
    void *input = arg;
    int c;

    while ((c = dud_fgetc(input)) != dud_eof()) {
        int written = dud_fputc(
            to_lexer_symbol(c), 
            dud_stdout()
        );
        if (written == dud_eof()) {
            dud_exit_1();
        }
    }

    if (dud_ferror(input)) {
        dud_exit_1();
    }

    if (dud_fflush(dud_stdout()) == dud_eof()) {
        dud_exit_1();
    }

    return;
}
