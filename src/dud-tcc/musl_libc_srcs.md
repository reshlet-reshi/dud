# src/dud-tcc/build musl_libc_srcs

This note is the evidence trail for `musl_libc_srcs` in `src/dud-tcc/build`.

The final source list mirrors the libc portion of musl 1.2.6's Makefile object
selection:

```make
ALL_OBJS = $(addprefix obj/, $(filter-out $(REPLACED_OBJS), $(sort $(BASE_OBJS) $(ARCH_OBJS))))
LIBC_OBJS = $(filter obj/src/%,$(ALL_OBJS)) $(filter obj/compat/%,$(ALL_OBJS))
```

This bootstrap keeps source paths, not object paths, in `musl_libc_srcs`. The
later compile loop turns each source path into an object path under
`$musl_obj`.

## Pipeline

```sh
: > "$musl_libc_srcs"
while IFS= read -r src_file; do
    rel=${src_file#"$musl_src"/}
    obj=obj/${rel%.*}.o
    if ! grep -F -x "$obj" "$musl_replaced_objs" >/dev/null 2>&1; then
        printf '%s\n' "$rel" >>"$musl_libc_srcs"
    fi
done <"$musl_base_srcs"
sed "s#^$musl_src/##" "$musl_arch_srcs" >>"$musl_libc_srcs"
sort "$musl_libc_srcs" >"$musl_libc_srcs.sorted"
mv "$musl_libc_srcs.sorted" "$musl_libc_srcs"
```

Step by step:

- `: > "$musl_libc_srcs"` creates or truncates the final source-list file.
- The `while` loop reads absolute generic source paths from `musl_base_srcs`.
- `rel=${src_file#"$musl_src"/}` converts each source to a musl-relative path,
  such as `src/process/vfork.c`.
- `obj=obj/${rel%.*}.o` computes the object slot that source would produce,
  such as `obj/src/process/vfork.o`.
- `grep -F -x "$obj" "$musl_replaced_objs"` checks whether an x86_64 source
  already claims that object slot.
- If the object is not replaced, the relative source path is appended to
  `musl_libc_srcs`.
- `sed "s#^$musl_src/##" "$musl_arch_srcs"` appends every selected x86_64
  source, also as a musl-relative path.
- The final `sort`/`mv` makes the combined source list deterministic.

## Example

If `musl_replaced_objs` contains:

```text
obj/src/process/vfork.o
```

then a generic source that would produce the same object:

```text
src/process/vfork.c
```

is skipped. The x86_64 source:

```text
src/process/x86_64/vfork.s
```

is appended instead. This prevents two archive members with the same logical
object name while preserving musl's arch-source replacement behavior.
