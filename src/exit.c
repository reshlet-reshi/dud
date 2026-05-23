#include <stdio.h>
#include <stdlib.h>

#include "exit.h"

_Noreturn void exit_1(void) {
    fputs("!!!\n", stderr);
    exit(1);
}

_Noreturn void exit_2(void) {
    fputs("???\n", stderr);
    exit(2);
}
