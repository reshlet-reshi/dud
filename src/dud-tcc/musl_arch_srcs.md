# src/dud-tcc/init musl_arch_srcs

This note is the evidence trail for `musl_arch_srcs` in `src/dud-tcc/init`.

The source-list shape is adapted from musl 1.2.6's Makefile:

```make
SRC_DIRS = $(addprefix $(srcdir)/,src/* src/malloc/$(MALLOC_DIR) crt ldso $(COMPAT_SRC_DIRS))
ARCH_GLOBS = $(addsuffix /$(ARCH)/*.[csS],$(SRC_DIRS))
ARCH_SRCS = $(sort $(wildcard $(ARCH_GLOBS)))
```

This bootstrap targets x86_64 and builds a `libc.a` subset, so `musl_arch_srcs`
is not a verbatim expansion of upstream `ARCH_SRCS`. It collects x86_64-specific
C and assembly sources under `src/*/x86_64/*`, then sorts the list.

## Local Differences

- Upstream `ARCH_SRCS` also ranges over `crt` and `ldso` via `SRC_DIRS`. This
  bootstrap source list is only for the static libc archive. The CRT startup
  files are built later as installable CRT objects: `crt/crt1.c`,
  `crt/x86_64/crti.s`, and `crt/x86_64/crtn.s`. They must not be archived into
  `libc.a`.
- `ldso` is the dynamic loader path. This bootstrap compiler intentionally
  supports static output only, so it does not build a dynamic loader or include
  dynamic-loader objects in the libc archive. In musl 1.2.6 there are no
  `ldso/x86_64/*` files, but the upstream Makefile model still includes `ldso`
  in the arch-source glob.
- Compat arch sources are not included because this bootstrap is not attempting
  a full musl `ALL_OBJS` build; it builds the `src/*` libc objects needed for
  the static bootstrap archive.
- `src/fenv/x86_64/fenv.s` is excluded because the x86_64 fenv assembly uses
  floating-point environment instructions and assembler forms outside this
  bootstrap path. The generic fenv C sources remain in the base list where this
  init path can compile them.
- `src/math/x86_64/*` is excluded to avoid optimized x86_64 math and long-double
  assembly helpers such as `expl.s`, `logl.s`, and `sqrtl.s`. This init path
  uses the generic math C sources instead.
- `src/string/x86_64/*` is excluded to avoid optimized x86_64 assembly for
  `memcpy`, `memmove`, and `memset`. This init path uses the generic C sources
  instead.
