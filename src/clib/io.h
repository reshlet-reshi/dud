#ifndef CLIB_IO_H
#define CLIB_IO_H

void *clib_fopen(char *path, char *mode);
void *clib_fmemopen(void *buffer, int size, char *mode);
void *clib_stdin(void);
void *clib_stdout(void);
void *clib_stderr(void);

int clib_eof(void);
int clib_fclose(void *file);
int clib_fgetc(void *file);
int clib_fputc(int c, void *file);
int clib_ferror(void *file);
int clib_fflush(void *file);
int clib_fputs(char *s, void *file);

#endif
