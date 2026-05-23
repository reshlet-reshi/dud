#define _POSIX_C_SOURCE 200809L

#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "exit.h"
#include "fopen_argv.h"

enum kind {
    INPUT_ARG,
    INPUT_DASH_DASH,
    INPUT_FILE,
    INPUT_STDIN,

    INPUT_MAX,
    INPUT_NIL = -1,
};

typedef FILE * fn_fopen(char *);

struct config {
    int argc;
    int should_close;
    fn_fopen *p_fopen;
};

static FILE * fopen_arg(char * arg) {
    FILE *stream = fmemopen(
        (void *)arg, 
        strlen(arg), 
        "rb"
    );
    if (stream == NULL) {
        exit_1();
    }
    return stream;
}

static FILE * fopen_path(char * arg) {
    FILE *file = fopen(arg, "rb");
    if (file == NULL) {
        exit_1();
    }
    return file;
}

static FILE * fopen_stdin(char * arg) {
    (void) arg;
    return stdin;
}

struct config lookup[] = {
    { 4, 1, fopen_arg },    // INPUT_ARG
    { 4, 1, fopen_path },   // INPUT_DASH_DASH
    { 3, 1, fopen_path },   // INPUT_FILE
    { 3, 0, fopen_stdin},   // INPUT_STDIN
};
static_assert((sizeof(lookup)/sizeof(0[lookup])) == INPUT_MAX);

static enum kind kind_from_arg(char *arg) {
    if (strcmp(arg, "-c") == 0) { return INPUT_ARG; }
    if (strcmp(arg, "--") == 0) { return INPUT_DASH_DASH;}
    if (strcmp(arg, "-") == 0) { return INPUT_STDIN; }
    if (arg[0] == '-') { return INPUT_NIL; }
    return INPUT_FILE;
}

FILE *fopen_argv(
    int argc, 
    char *argv[], 
    int *should_close
) {
    if (argc < 3) {
        exit_2();
    }

    enum kind kind = kind_from_arg(argv[2]);
    if (kind == INPUT_NIL) {
        exit_2();
    }

    struct config config = lookup[kind];
    if (config.argc != argc){
        exit_2();
    }

    char * arg = argv[argc - 1];
    *should_close = config.should_close;
    return config.p_fopen(arg);
}
