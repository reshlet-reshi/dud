#include <stdlib.h>

#include "io.h"
#include "exit.h"

void dud_exit_1(void) {
    dud_fputs("!!!\n", dud_stderr());
    exit(1);
}

void dud_exit_2(void) {
    dud_fputs("???\n", dud_stderr());
    exit(2);
}
