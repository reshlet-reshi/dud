# src/dud-tcc/build musl libc.a no-index normalization

This note is the evidence trail for the `libc.a` archive-index stripping step
in `src/dud-tcc/build`.

The short version: `tcc0 -ar` writes a leading archive symbol index, but TCC
0.9.27's archive indexer does not include weak definitions. Musl uses weak
definitions for several libc symbols. If the index is present, TCC's linker
trusts it and does not scan the archive members directly, so those weak-only
providers can be missed.

The workaround removes only the leading archive index member. Without that
member, TCC falls back to scanning the archive's object members directly, which
lets the musl bootstrap link resolve the weak definitions.

## Failure Without This

A local probe temporarily removed this block from `src/dud-tcc/build` and then
reran the build. The final link failed with unresolved symbols:

```text
tcc: error: undefined symbol 'mprotect'
tcc: error: undefined symbol 'sigaction'
tcc: error: undefined symbol '__init_tls'
tcc: error: undefined symbol '__stdio_exit_needed'
```

Those symbols are present in the generated `libc.a`, but as weak definitions in
objects such as `mprotect.o`, `sigaction.o`, `__init_tls.o`, and
`__stdio_exit.o`. TCC's archive indexer in `tcctools.c` records only symbol
infos `0x10`, `0x11`, and `0x12`, which are global symbols with type
`NOTYPE`, `OBJECT`, or `FUNC`. Weak symbols have binding `STB_WEAK`, so their
symbol-info byte is in the `0x20` range and they are not written to the index.

## Why The Leading `/` Matters

Unix `ar` archives begin with an 8-byte magic header:

```text
!<arch>\n
```

Each member then has a 60-byte ASCII header followed by that member's data.
The first 16 bytes of each member header are the member name.

TCC's archive reader treats a member named `/` as the archive symbol table. In
the normal TCC link mode, that makes it use indexed, "as needed" archive
loading. If an undefined symbol is not in that index, TCC has no reason to pull
the object that defines it.

If the archive has no leading `/` member, TCC's archive reader walks the member
list and loads object members directly. This is less selective, but it is good
enough for this bootstrap archive and avoids the incomplete weak-symbol index.

## Pipeline

```sh
ar_first_name=$(dd if="$musl_lib/libc.a" bs=1 skip=8 count=16 2>/dev/null)
ar_first_name=$(printf '%s\n' "$ar_first_name" | tr -d ' ')
if [ "$ar_first_name" = "/" ]; then
    ar_index_size=$(dd if="$musl_lib/libc.a" bs=1 skip=56 count=10 2>/dev/null)
    ar_index_size=$(printf '%s\n' "$ar_index_size" | tr -cd '0-9')
    ar_index_skip=$((8 + 60 + ar_index_size + ar_index_size % 2))
    printf '%s\n' '!<arch>' >"$musl_lib/libc.a.noindex"
    dd \
        if="$musl_lib/libc.a" \
        bs=1 \
        skip="$ar_index_skip" \
        >>"$musl_lib/libc.a.noindex" \
        2>/dev/null
    mv "$musl_lib/libc.a.noindex" "$musl_lib/libc.a"
fi
```

Step by step:

- `dd if="$musl_lib/libc.a" bs=1 skip=8 count=16` reads the first archive
  member's name field. `skip=8` jumps past the global `!<arch>\n` header, and
  `count=16` reads the fixed-width `ar_name` field.
- `tr -d ' '` removes padding spaces from that fixed-width name field.
- `if [ "$ar_first_name" = "/" ]` checks whether the first member is the
  archive symbol index. If the first member is already a normal object, there
  is nothing to normalize.
- `dd ... skip=56 count=10` reads the first member's size field. The size field
  begins 48 bytes into the 60-byte member header, and the archive header starts
  after the 8-byte global magic, so the absolute offset is `8 + 48 = 56`.
- `tr -cd '0-9'` keeps only the decimal digits from the fixed-width ASCII size
  field.
- `ar_index_skip=$((8 + 60 + ar_index_size + ar_index_size % 2))` computes the
  byte offset immediately after the leading index member:
  - `8` for the global archive magic,
  - `60` for the index member header,
  - `ar_index_size` for the index member payload,
  - `ar_index_size % 2` for the optional one-byte archive padding when the
    payload has odd length.
- `printf '%s\n' '!<arch>' >"$musl_lib/libc.a.noindex"` starts a replacement
  archive with only the global archive magic.
- The second `dd` copies the rest of the original archive, beginning just after
  the leading index member, into the replacement archive.
- `mv "$musl_lib/libc.a.noindex" "$musl_lib/libc.a"` atomically swaps the
  normalized archive into the path used by the final `tcc1` link.

The resulting archive still contains the same object members in the same order.
Only the leading symbol-index member is removed.
