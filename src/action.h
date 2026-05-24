#ifndef ACTION_H
#define ACTION_H

typedef void fn_action(void *arg);
fn_action *action_from_arg(char *arg);

#endif
