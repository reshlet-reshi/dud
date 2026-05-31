# 03-musl-tcc/stdarg.h

This note is the evidence trail for `03-musl-tcc/stdarg.h`.

The file replaces musl 1.2.6's `include/stdarg.h` during the musl-tcc bootstrap.

## What It Does

Upstream musl's `stdarg.h` maps the public macros directly to compiler
builtins:

```c
#define va_start(v,l)   __builtin_va_start(v,l)
#define va_end(v)       __builtin_va_end(v)
#define va_arg(v,l)     __builtin_va_arg(v,l)
#define va_copy(d,s)    __builtin_va_copy(d,s)
```

The bootstrap TCC path used here does not provide those GCC-compatible varargs
builtins in the form musl expects. This replacement keeps musl's `va_list` type
from `<bits/alltypes.h>`, but routes the operations through bootstrap-provided
helpers instead:

```c
void __va_start(__va_list_struct *, void *);
void *__va_arg(__va_list_struct *, int, int, int);
```

`va_start` passes the current frame address to `__va_start`, and `va_arg`
passes TCC's type metadata, size, and alignment values to `__va_arg`.

## Bootstrap Scope

This is a bootstrap header for the repo's x86_64 Linux musl-tcc runme path. It is
not intended to be a general replacement for musl's upstream `stdarg.h`, and it
depends on compiler/runtime support for:

- `__builtin_frame_address`
- `__builtin_va_arg_types`
- `__alignof__`
- `__va_start`
- `__va_arg`
