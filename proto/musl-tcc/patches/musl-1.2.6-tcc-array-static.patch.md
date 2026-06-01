# proto/musl-tcc/patches/musl-1.2.6-tcc-array-static.patch

This note is the evidence trail for `proto/musl-tcc/patches/musl-1.2.6-tcc-array-static.patch`.

The patch replaces C99 `static` array parameter qualifiers in a few musl 1.2.6
internal declarations and definitions with ordinary array parameters.

## What The Patch Does

The old runme path applied this transformation after unpacking musl:

```sh
sed 's/\[static /[/g'
```

That touched these files:

- `src/internal/syscall.h`
- `src/network/lookup.h`
- `src/network/lookup_ipliteral.c`
- `src/network/lookup_name.c`
- `src/network/lookup_serv.c`

This patch records the same edits explicitly, so the bootstrap source changes
are reviewable and applied with the rest of the patch-based setup.

## Why It Is Safe Here

In function parameters, C array parameters are adjusted to pointer parameters.
The `static N` qualifier documents a caller-side minimum size contract and can
enable diagnostics or optimization for compilers that implement it, but it does
not change the function ABI.

The bootstrap TCC used here does not accept these qualifiers, so the patch keeps
the same callable interfaces while using syntax the bootstrap compiler accepts.
