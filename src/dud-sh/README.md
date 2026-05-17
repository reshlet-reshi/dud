# dud-sh

`dud-sh` is the first `dud` subproject. It is not a general shell; it is a tiny
bootstrap command language that is intentionally hosted by `/bin/sh` at first.

No implementation code is committed yet.

## Docs

- [Language](language.md) describes the current `dud-sh` source profile
  and parser model.

## Planned Layout

Directories listed here may be absent until real tracked content exists. Do not
preserve empty planned directories with `.gitkeep` placeholders.

```text
AGENTS.md
README.md
bin/                 entry scripts, no extension
lib/std/i386/        future i386 byte fragments and docs-backed helpers
lib/std/elf32/       future ELF32 byte fragments and docs-backed helpers
lib/std/patch-elf/   future patch-elf-specific fragments
test/                fixtures and support data for test.py
docs/                intended future per-project concept documentation
test.py              reserved canonical test runner path
```
