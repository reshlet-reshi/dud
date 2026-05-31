# 99-experiments/musl-tcc/runme.sh musl_replaced_objs

This note is the evidence trail for `musl_replaced_objs` in
`99-experiments/musl-tcc/runme.sh`.

The transform mirrors musl 1.2.6's Makefile model:

```make
ARCH_OBJS = $(patsubst $(srcdir)/%,%.o,$(basename $(ARCH_SRCS)))
REPLACED_OBJS = $(sort $(subst /$(ARCH)/,/,$(ARCH_OBJS)))
```

Musl uses `REPLACED_OBJS` to tell when an architecture-specific source should
replace a generic source that would otherwise produce the same object name.

## Transformation

For each x86_64 source path in `musl_arch_srcs`, this runme path computes the
generic object slot it replaces.

Example input:

```text
.../musl-1.2.6/src/process/x86_64/vfork.s
```

The pipeline applies these edits:

```sh
sed \
    -e "s#^$musl_src/##" \
    -e 's#\.[csS]$#.o#' \
    -e 's#/x86_64/#/#' \
    -e 's#^#obj/#' \
    "$musl_arch_srcs" \
    | sort \
    >"$musl_replaced_objs"
```

Step by step:

- `s#^$musl_src/##` strips the absolute musl source directory, turning
  `/.../musl-1.2.6/src/process/x86_64/vfork.s` into
  `src/process/x86_64/vfork.s`.
- `s#\.[csS]$#.o#` turns the source suffix into an object suffix. It handles
  `.c`, `.s`, and `.S`, so the example becomes
  `src/process/x86_64/vfork.o`.
- `s#/x86_64/#/#` removes the architecture directory from the object path. This
  is the key replacement step: `src/process/x86_64/vfork.o` becomes the generic
  object slot `src/process/vfork.o`.
- `s#^#obj/#` adds musl's object root, producing
  `obj/src/process/vfork.o`.
- `sort` gives a deterministic list, matching musl's sorted Makefile variables.

The same flow in compact form:

```text
src/process/x86_64/vfork.s    strip the musl source prefix
src/process/x86_64/vfork.o    replace .c/.s/.S with .o
src/process/vfork.o           remove /x86_64/
obj/src/process/vfork.o       add the object root
```

The final line, `obj/src/process/vfork.o`, is written to `musl_replaced_objs`.
When the runme path later walks generic base sources, it skips any generic source
whose object path appears in this list.

That lets `src/process/x86_64/vfork.s` replace a generic
`src/process/vfork.c` if one exists, without compiling two objects for the same
archive member.
