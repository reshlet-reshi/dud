
#include "lex.h"

#include "../clib/exit.h"
#include "../clib/io.h"



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

    while ((c = clib_fgetc(input)) != clib_eof()) {
        int written = clib_fputc(
            to_lexer_symbol(c), 
            clib_stdout()
        );
        if (written == clib_eof()) {
            clib_exit_1();
        }
    }

    if (clib_ferror(input)) {
        clib_exit_1();
    }

    if (clib_fflush(clib_stdout()) == clib_eof()) {
        clib_exit_1();
    }

    return;
}
