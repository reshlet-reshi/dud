#include "dud/io.h"
#include "dud/exit.h"
#include "dud/macro.h"
#include "dud/str.h"
#include "fopen_argv.h"

enum kind {
    INPUT_ARG,
    INPUT_DASH_DASH,
    INPUT_FILE,
    INPUT_STDIN,

    INPUT_MAX,
    INPUT_NIL = -1,
};

typedef void * fn_fopen(char *);

struct config {
    int argc;
    int should_close;
    fn_fopen *p_fopen;
};

static void * fopen_arg(char * arg) {
    void *stream = dud_fmemopen(
        (void *)arg, 
        dud_strlen(arg), 
        "rb"
    );
    if (stream == ((void *) 0)) {
        dud_exit_1();
    }
    return stream;
}

static void * fopen_path(char * arg) {
    void *file = dud_fopen(arg, "rb");
    if (file == ((void *) 0)) {
        dud_exit_1();
    }
    return file;
}

static void * fopen_stdin(char * arg) {
    (void) arg;
    return dud_stdin();
}

struct config lookup[] = {
    { 4, 1, fopen_arg },    // INPUT_ARG
    { 4, 1, fopen_path },   // INPUT_DASH_DASH
    { 3, 1, fopen_path },   // INPUT_FILE
    { 3, 0, fopen_stdin},   // INPUT_STDIN
};
STATIC_ASSERT((sizeof(lookup)/sizeof(0[lookup])) == INPUT_MAX);

static enum kind kind_from_arg(char *arg) {
    if (dud_strcmp(arg, "-c") == 0) { return INPUT_ARG; }
    if (dud_strcmp(arg, "--") == 0) { return INPUT_DASH_DASH;}
    if (dud_strcmp(arg, "-") == 0) { return INPUT_STDIN; }
    if (arg[0] == '-') { return INPUT_NIL; }
    return INPUT_FILE;
}

void *fopen_argv(
    int argc, 
    char *argv[], 
    int *should_close
) {
    if (argc < 3) {
        dud_exit_2();
    }

    enum kind kind = kind_from_arg(argv[2]);
    if (kind == INPUT_NIL) {
        dud_exit_2();
    }

    struct config config = lookup[kind];
    if (config.argc != argc){
        dud_exit_2();
    }

    char * arg = argv[argc - 1];
    *should_close = config.should_close;
    return config.p_fopen(arg);
}
