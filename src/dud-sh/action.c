
#include "action.h"

#include "../clib/str.h"
#include "lex.h"



fn_action *action_from_arg(char *arg) {
    if (clib_streq(arg, "--to-lexer-symbols")) { return to_lexer_symbols; }
    return ((void *) 0);
}
