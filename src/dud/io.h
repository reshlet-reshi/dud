#ifndef DUD_IO_H
#define DUD_IO_H

void *dud_fopen(char *path, char *mode);
void *dud_fmemopen(void *buffer, int size, char *mode);
void *dud_stdin(void);
void *dud_stdout(void);
void *dud_stderr(void);

int dud_eof(void);
int dud_fclose(void *file);
int dud_fgetc(void *file);
int dud_fputc(int c, void *file);
int dud_ferror(void *file);
int dud_fflush(void *file);
int dud_fputs(char *s, void *file);

#endif
