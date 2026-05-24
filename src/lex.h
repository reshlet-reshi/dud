#ifndef LEX_H
#define LEX_H

#include <stdio.h>

unsigned char to_lexer_symbol(int byte);
void to_lexer_symbols(FILE *input);

#endif
