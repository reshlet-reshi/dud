
#include <stdlib.h>

#include "exit.h"

#include "io.h"



void clib_exit_1(void) {
    clib_fputs("!!!\n", clib_stderr());
    exit(1);
}

void clib_exit_2(void) {
    clib_fputs("???\n", clib_stderr());
    exit(2);
}
