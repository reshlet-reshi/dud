#include <stdlib.h>

#include "dud/io.h"
#include "exit.h"

void exit_1(void) {
    dud_fputs("!!!\n", dud_stderr());
    exit(1);
}

void exit_2(void) {
    dud_fputs("???\n", dud_stderr());
    exit(2);
}
