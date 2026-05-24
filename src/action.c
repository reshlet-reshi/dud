#include "action.h"
#include "dud/str.h"
#include "lex.h"

fn_action *action_from_arg(char *arg) {
    if (dud_streq(arg, "--to-lexer-symbols")) { return to_lexer_symbols; }
    return ((void *) 0);
}
