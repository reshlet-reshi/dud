# 99-experiments/musl-tcc/runme.sh musl_libc_objs

This note is the evidence trail for `musl_libc_objs` in `99-experiments/musl-tcc/runme.sh`.

This is the compile stage after `musl_libc_srcs` has been assembled. It turns
each selected musl-relative source path into an object file under `$musl_obj`
and records the object path for the later archive step.

## Pipeline

```sh
: > "$musl_libc_objs"
while IFS= read -r rel; do
    obj=$musl_obj/${rel%.*}.o
    mkdir -p "$(dirname "$obj")"
    (cd "$musl_src"; tcc0_musl_cc -c "$rel" -o "$obj")
    printf '%s\n' "$obj" >>"$musl_libc_objs"
done <"$musl_libc_srcs"
```

Step by step:

- `: > "$musl_libc_objs"` creates or truncates the final object-list file.
- The `while` loop reads musl-relative source paths from `musl_libc_srcs`.
- `obj=$musl_obj/${rel%.*}.o` maps each source to its output object path. For
  example, `src/process/x86_64/vfork.s` becomes
  `$musl_obj/src/process/x86_64/vfork.o`.
- `mkdir -p "$(dirname "$obj")"` creates the destination directory for that
  object.
- `(cd "$musl_src"; tcc0_musl_cc -c "$rel" -o "$obj")` compiles from the musl
  source root. Keeping `$rel` relative means compiler diagnostics and include
  behavior match the musl source layout.
- `printf '%s\n' "$obj" >>"$musl_libc_objs"` records the compiled object path.

The completed `musl_libc_objs` file is read by the archive step that creates
`$musl_lib/libc.a`.
