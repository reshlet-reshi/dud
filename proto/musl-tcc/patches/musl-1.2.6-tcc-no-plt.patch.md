# proto/musl-tcc/patches/musl-1.2.6-tcc-no-plt.patch

This note is the evidence trail for `proto/musl-tcc/patches/musl-1.2.6-tcc-no-plt.patch`.

The patch removes `@PLT` symbol suffixes from musl 1.2.6 assembly sources.

## What The Patch Does

The old runme path applied this transformation after unpacking musl:

```sh
sed 's/@PLT//g'
```

It ran over every `.s` and `.S` file. In musl 1.2.6, only these files contain
`@PLT` and therefore change:

- `src/unistd/sh/pipe.s`
- `src/signal/x86_64/sigsetjmp.s`
- `src/signal/x32/sigsetjmp.s`
- `src/signal/sh/sigsetjmp.s`
- `src/process/sh/vfork.s`
- `src/math/x86_64/expl.s`
- `src/math/x32/expl.s`
- `src/ldso/sh/dlsym.s`

This patch records those substitutions explicitly, so the bootstrap source
changes are reviewable and fail loudly if upstream musl changes the affected
assembly.

## Why It Is Needed

The bootstrap TCC assembler/linker path used here does not accept musl's
explicit `@PLT` relocation syntax in assembly sources. Removing the suffix keeps
the call and address expressions direct, which is the form this bootstrap runme
path can assemble.
