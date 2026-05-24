#include <stddef.h>
#include <string.h>

#include "action.h"
#include "lex.h"

fn_action *action_from_arg(char *arg) {
    if (strcmp(arg, "--to-lexer-symbols") == 0) { return to_lexer_symbols; }
    return NULL;
}
