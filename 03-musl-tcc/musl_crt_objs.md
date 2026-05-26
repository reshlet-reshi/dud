# 03-musl-tcc/init musl CRT objects

This note is the evidence trail for the musl CRT object build in
`03-musl-tcc/init`.

These objects are not part of `libc.a`. They are standalone startup/finalizer
objects installed beside `libc.a` and used by TCC when linking static programs.
This bootstrap init builds only the static x86_64 startup set:

```text
crt1.o
crti.o
crtn.o
```

## Pipeline

```sh
mkdir -p "$musl_obj/crt/x86_64"
(
    cd "$musl_src"
    tcc0_musl_cc -DCRT -c crt/crt1.c -o "$musl_obj/crt/crt1.o"
    tcc0_musl_cc -DCRT -c crt/x86_64/crti.s \
        -o "$musl_obj/crt/x86_64/crti.o"
    tcc0_musl_cc -DCRT -c crt/x86_64/crtn.s \
        -o "$musl_obj/crt/x86_64/crtn.o"
)
```

Step by step:

- `mkdir -p "$musl_obj/crt/x86_64"` creates the object output directory for
  generic CRT objects and x86_64-specific CRT assembly objects.
- The subshell keeps `cd "$musl_src"` local to this init step.
- Compiling from `$musl_src` keeps source paths and include lookup aligned with
  musl's own build layout.
- `tcc0_musl_cc -DCRT -c crt/crt1.c -o "$musl_obj/crt/crt1.o"` builds the
  static executable entry object.
- `tcc0_musl_cc -DCRT -c crt/x86_64/crti.s ...` builds the x86_64 prologue for
  the `.init` and `.fini` sections.
- `tcc0_musl_cc -DCRT -c crt/x86_64/crtn.s ...` builds the x86_64 epilogue for
  the `.init` and `.fini` sections.

`-DCRT` mirrors musl 1.2.6's Makefile rule:

```make
$(CRT_OBJS): CFLAGS_ALL += -DCRT
```

## Object Roles

`crt1.o` provides the static program entry path. On x86_64, musl's
`arch/x86_64/crt_arch.h` emits `_start`, sets up the initial stack argument for
C code, aligns the stack, and calls `_start_c`. `crt/crt1.c` then extracts
`argc` and `argv` and calls:

```c
__libc_start_main(main, argc, argv, _init, _fini, 0);
```

`crti.o` opens the `_init` and `_fini` section functions by emitting the
function labels and initial prologue instructions.

`crtn.o` closes those same section functions by emitting the matching epilogue
and `ret` instructions.

## Install Shape

After building these objects under `$musl_obj`, `03-musl-tcc/init` copies them
to `$musl_lib`:

```sh
cp "$musl_obj/crt/crt1.o" "$musl_lib/crt1.o"
cp "$musl_obj/crt/x86_64/crti.o" "$musl_lib/crti.o"
cp "$musl_obj/crt/x86_64/crtn.o" "$musl_lib/crtn.o"
```

The intermediate `tcc1` bootstrap link also uses them explicitly around
`tcc.c`, `libc.a`, and `libtcc1.a`. Once that fixed-point compiler is installed
as the user-facing `tcc`, its configured CRT prefix points at this same library
directory so later static links can find the CRT objects by their conventional
names.
