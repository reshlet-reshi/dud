#define _POSIX_C_SOURCE 200809L

#include <stdio.h>

#include "io.h"

void *dud_fopen(char *path, char *mode) {
    return fopen(path, mode);
}

void *dud_fmemopen(void *buffer, int size, char *mode) {
    return fmemopen(buffer, size, mode);
}

void *dud_stdin(void) {
    return stdin;
}

void *dud_stdout(void) {
    return stdout;
}

void *dud_stderr(void) {
    return stderr;
}

int dud_eof(void) {
    return EOF;
}

int dud_fclose(void *file) {
    return fclose((FILE *) file);
}

int dud_fgetc(void *file) {
    return fgetc((FILE *) file);
}

int dud_fputc(int c, void *file) {
    return fputc(c, (FILE *) file);
}

int dud_ferror(void *file) {
    return ferror((FILE *) file);
}

int dud_fflush(void *file) {
    return fflush((FILE *) file);
}

int dud_fputs(char *s, void *file) {
    return fputs(s, (FILE *) file);
}
