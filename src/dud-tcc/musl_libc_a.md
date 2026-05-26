# src/dud-tcc/build musl libc.a

This note is the evidence trail for the `libc.a` archive creation step in
`src/dud-tcc/build`.

This stage consumes the object list in `musl_libc_objs` and creates the static
musl libc archive used later when linking the intermediate `tcc1`, which is
installed as the user-facing `tcc` after the fixed-point check.

## Pipeline

```sh
mkdir -p "$musl_lib"
(
    set --
    while IFS= read -r obj; do
        set -- "$@" "$obj"
    done <"$musl_libc_objs"
    "$tcc0" -ar rcs "$musl_lib/libc.a" "$@"
)
```

Step by step:

- `mkdir -p "$musl_lib"` creates the destination directory for musl libraries
  and CRT objects.
- The subshell keeps the temporary positional-argument list local to this
  archive step.
- `set --` clears the subshell's positional arguments.
- The `while` loop reads each object path from `musl_libc_objs`.
- `set -- "$@" "$obj"` appends each object path to the positional-argument
  list while preserving spaces or other shell-sensitive characters.
- `"$tcc0" -ar rcs "$musl_lib/libc.a" "$@"` invokes TCC's archive mode to
  create `libc.a` from the collected object paths.

The result may include a leading archive symbol index member. The following
`musl_libc_a_noindex` step normalizes that if present.
