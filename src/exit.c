#include <stdio.h>
#include <stdlib.h>

#include "exit.h"

void exit_1(void) {
    fputs("!!!\n", stderr);
    exit(1);
}

void exit_2(void) {
    fputs("???\n", stderr);
    exit(2);
}
