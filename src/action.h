#ifndef ACTION_H
#define ACTION_H

#include <stdio.h>

typedef void fn_action(FILE *stream);

fn_action *action_from_arg(char *arg);

#endif
