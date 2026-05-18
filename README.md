# dud

`dud` is a bootstrap toolchain project. The current stage-0 work is `dud-sh`,
a deliberately tiny `/bin/sh`-compatible command language for early bootstrap
work. That current work lives at the repository root for now.

Current slogan:

```text
Shell temporarily hosts dsh.
Later dsh runs the same files itself.
```

The first milestone is the path from hosted `dud-sh`-compatible scripts to
`patch-elf`, then `patch-elf-modular`, and later a native `dud-sh` kernel path.
No implementation code is committed yet.

## Docs

- [Language](language.md) describes the current `dud-sh` source profile and
  parser model.

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

Directories listed here may be absent until real tracked content exists. Do not
preserve empty planned directories with `.gitkeep` placeholders.

```text
.bin/              intended future generated native artifact directory
.stash/            local in-progress untracked experiment directory
.tmp/              transient scratch/test directory, safe to delete anytime
bin/               future entry scripts, no extension
docs/              intended future top-level project docs directory
lib/std/i386/      future i386 byte fragments and docs-backed helpers
lib/std/elf32/     future ELF32 byte fragments and docs-backed helpers
lib/std/patch-elf/ future patch-elf-specific fragments
src/               intended future multi-project or source tree
test/              future fixtures and support data for test.py
test.py            future canonical test runner, added when tests begin
```
