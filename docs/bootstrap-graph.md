# Bootstrap Graph

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
