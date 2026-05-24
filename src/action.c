#include <stddef.h>
#include <string.h>

#include "action.h"
#include "quot.h"

fn_action *action_from_arg(char *arg) {
    if (strcmp(arg, "--quot") == 0) { return quot_bytes; }
    return NULL;
}
