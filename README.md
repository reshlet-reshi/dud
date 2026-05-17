# dud

`dud` is a bootstrap toolchain project. The first subproject is `dud-sh`,
a deliberately tiny `/bin/sh`-compatible command language for early bootstrap
work.

Current slogan:

```text
Shell temporarily hosts dsh.
Later dsh runs the same files itself.
```

The first milestone is the path from hosted `dud-sh`-compatible scripts to
`patch-elf`, then `patch-elf-modular`, and later a native `dud-sh` kernel path.
No implementation code is committed yet.

## Bootstrap Path

Current intended path:

```text
/bin/sh-hosted dud-sh-compatible source
  -> first native patch-elf
  -> patch-elf-modular built from dot-sourced fragments
  -> toward a native dud-sh kernel
```

`patch-elf` is the first native artifact. It patches ELF32 program header
fields so later scripts can emit executable ELF files without hard-coding the
final file size.

Stage 0 does not include labels, relocations, or a general assembler. Those
belong to later work.

## Layout

```text
.bin/              intended future generated native artifact directory
.tmp/              intended future scratch and test temporary directory
docs/              intended future top-level project docs directory
src/dud-sh/        first bootstrap subproject
```

See `src/dud-sh/README.md` for the current subproject scaffold.
