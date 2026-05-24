
#include <stdlib.h>

#include "exit.h"

#include "io.h"



void dud_exit_1(void) {
    dud_fputs("!!!\n", dud_stderr());
    exit(1);
}

void dud_exit_2(void) {
    dud_fputs("???\n", dud_stderr());
    exit(2);
}
