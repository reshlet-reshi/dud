# src/dud-tcc/build musl_base_srcs

This note is the evidence trail for `musl_base_srcs` in `src/dud-tcc/build`.

The source-list shape is adapted from musl 1.2.6's Makefile:

```make
SRC_DIRS = $(addprefix $(srcdir)/,src/* src/malloc/$(MALLOC_DIR) crt ldso $(COMPAT_SRC_DIRS))
BASE_GLOBS = $(addsuffix /*.c,$(SRC_DIRS))
BASE_SRCS = $(sort $(wildcard $(BASE_GLOBS)))
```

This bootstrap builds a `libc.a` subset, so `musl_base_srcs` is not a verbatim
expansion of upstream `BASE_SRCS`. It collects generic C sources from
`src/*/*.c` and `src/malloc/mallocng/*.c`, then sorts the list.

## Local Differences

- Upstream `BASE_SRCS` also ranges over `crt` via `SRC_DIRS`. This bootstrap
  source list is only for the static libc archive. The installed CRT startup
  objects are built later from `crt/crt1.c`, `crt/x86_64/crti.s`, and
  `crt/x86_64/crtn.s`. Other upstream CRT variants such as `Scrt1.c` and
  `rcrt1.c` are for shared/dynamic startup modes this bootstrap does not
  provide.
- `ldso` is the dynamic loader path. Upstream base sources include
  `ldso/dlstart.c` and `ldso/dynlink.c`, but this bootstrap compiler is
  static-output-only and does not build a dynamic loader.
- Compat sources are not included because this bootstrap is not attempting a
  full musl `ALL_OBJS` build. In musl 1.2.6 the compat tree is primarily
  `compat/time32/*` wrappers for older time32 ABI entry points, which are out
  of scope for this static bootstrap archive.
- `src/complex/*` is excluded because TCC 0.9.27 does not support the C
  `_Complex` type syntax used by musl's complex math implementation and
  `<complex.h>`. The bootstrap TCC advertises this with
  `__STDC_NO_COMPLEX__`.
