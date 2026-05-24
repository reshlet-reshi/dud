
#include "action.h"
#include "clib/exit.h"
#include "clib/io.h"
#include "fopen_argv.h"



int main(int argc, char *argv[]) {
    if (argc == 1) {
        clib_exit_2();
    }

    fn_action *action = action_from_arg(argv[1]);
    if (!action) {
        clib_exit_2();
    }

    int should_close;
    void *input = fopen_argv(argc, argv, &should_close);

    action(input);

    if (should_close && clib_fclose(input) != 0) {
        clib_exit_1();
    }

    return 0;
}
