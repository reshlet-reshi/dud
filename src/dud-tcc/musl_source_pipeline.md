# src/dud-tcc/init musl source pipeline

This note is the evidence trail for the musl libc source/object list pipeline
in `src/dud-tcc/init`.

The logic mirrors musl 1.2.6's Makefile model:

```make
BASE_SRCS = $(sort $(wildcard $(BASE_GLOBS)))
ARCH_SRCS = $(sort $(wildcard $(ARCH_GLOBS)))
REPLACED_OBJS = $(sort $(subst /$(ARCH)/,/,$(ARCH_OBJS)))
ALL_OBJS = $(addprefix obj/, $(filter-out $(REPLACED_OBJS), $(sort $(BASE_OBJS) $(ARCH_OBJS))))
LIBC_OBJS = $(filter obj/src/%,$(ALL_OBJS)) $(filter obj/compat/%,$(ALL_OBJS))
```

This init path writes the intermediate lists to files under `.init/musl-tcc-build`
instead of asking `make` to expand them.

## Temporary Lists

- `musl-base-srcs`: generic musl C sources under `src/*/*.c`, plus
  `src/malloc/mallocng/*.c`, excluding `src/complex/*`.
- `musl-arch-srcs`: x86_64-specific musl C/assembly sources under
  `src/*/x86_64/*`, with bootstrap exclusions for fenv, math, and string
  sources this init path does not compile.
- `musl-replaced-objs`: object names that x86_64-specific sources replace.
  For example, `src/foo/x86_64/bar.s` maps to `obj/src/foo/bar.o`, so the
  generic source producing the same object is skipped.
- `musl-libc-srcs`: the final source list for this bootstrap libc archive:
  generic sources minus replaced objects, followed by x86_64 sources.
- `musl-libc-objs`: the object files compiled from `musl-libc-srcs`; this is
  the list passed to `tcc0 -ar rcs` to create `libc.a`.

## Why Files

The source and object lists are long enough that shell variables would be
awkward, and `tcc0 -ar` eventually needs the object paths as positional
arguments. Keeping the lists as sorted files makes the pipeline deterministic
and easy to inspect when the bootstrap init fails.
