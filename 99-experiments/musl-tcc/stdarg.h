#ifndef _STDARG_H
#define _STDARG_H

#undef __DEFINED_va_list
#undef __DEFINED___isoc_va_list
#undef __isoc_va_list

#define __NEED_va_list

#include <bits/alltypes.h>

void __va_start(__va_list_struct *, void *);
void *__va_arg(__va_list_struct *, int, int, int);

#define va_start(ap, last) __va_start(ap, __builtin_frame_address(0))
#define va_arg(ap, type) \
    (*(type *)(__va_arg(ap, __builtin_va_arg_types(type), sizeof(type), __alignof__(type))))
#define va_copy(dest, src) (*(dest) = *(src))
#define va_end(ap)

typedef va_list __gnuc_va_list;

#endif
