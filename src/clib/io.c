
#define _POSIX_C_SOURCE 200809L

#include <stdio.h>

#include "io.h"



void *clib_fopen(char *path, char *mode) {
    return fopen(path, mode);
}

void *clib_fmemopen(void *buffer, int size, char *mode) {
    return fmemopen(buffer, size, mode);
}

void *clib_stdin(void) {
    return stdin;
}

void *clib_stdout(void) {
    return stdout;
}

void *clib_stderr(void) {
    return stderr;
}

int clib_eof(void) {
    return EOF;
}

int clib_fclose(void *file) {
    return fclose((FILE *) file);
}

int clib_fgetc(void *file) {
    return fgetc((FILE *) file);
}

int clib_fputc(int c, void *file) {
    return fputc(c, (FILE *) file);
}

int clib_ferror(void *file) {
    return ferror((FILE *) file);
}

int clib_fflush(void *file) {
    return fflush((FILE *) file);
}

int clib_fputs(char *s, void *file) {
    return fputs(s, (FILE *) file);
}
