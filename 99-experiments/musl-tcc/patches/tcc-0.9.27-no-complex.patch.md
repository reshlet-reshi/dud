# 99-experiments/musl-tcc/patches/tcc-0.9.27-no-complex.patch

This note is the evidence trail for `99-experiments/musl-tcc/patches/tcc-0.9.27-no-complex.patch`.

The patch makes the bootstrap TCC predefine `__STDC_NO_COMPLEX__`.

## Why It Is Needed

This musl-tcc bootstrap does not build musl's `src/complex/*` implementations,
and TCC 0.9.27 does not support the C `_Complex` type syntax used by musl's
`include/complex.h`.

Musl's `complex.h` is not conditionally hidden based on `__STDC_NO_COMPLEX__`;
it assumes compiler complex support is available. The standard macro is still
useful because user code can check it before including `<complex.h>` or using
complex types.

## Patch Point

Upstream TCC defines standard predefined macros in `libtcc.c`:

```c
tcc_define_symbol(s, "__STDC__", NULL);
tcc_define_symbol(s, "__STDC_VERSION__", "199901L");
tcc_define_symbol(s, "__STDC_HOSTED__", NULL);
```

This patch adds `__STDC_NO_COMPLEX__` in the same block. Passing `NULL` follows
TCC's existing convention for object-like predefined macros that expand to `1`.
