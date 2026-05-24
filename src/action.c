#include <stddef.h>
#include <string.h>

#include "action.h"
#include "cat.h"
#include "quot.h"
#include "wc_c.h"

fn_action *action_from_arg(char *arg) {
    if (strcmp(arg, "--cat") == 0) { return cat; }
    if (strcmp(arg, "--quot") == 0) { return quot_bytes; }
    if (strcmp(arg, "--wc-c") == 0) { return wc_c; }
    return NULL;
}
