#include <stdio.h>

#include "action.h"
#include "exit.h"
#include "fopen_argv.h"

int main(int argc, char *argv[]) {
    if (argc == 1) {
        exit_2();
    }

    fn_action *action = action_from_arg(argv[1]);
    if (!action) {
        exit_2();
    }

    int should_close;
    FILE *input = fopen_argv(argc, argv, &should_close);

    action(input);

    if (should_close && fclose(input) != 0) {
        exit_1();
    }

    return 0;
}
