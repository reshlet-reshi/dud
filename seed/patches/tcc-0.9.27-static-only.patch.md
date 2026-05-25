# seed/patches/tcc-0.9.27-static-only.patch

This note is the evidence trail for `seed/patches/tcc-0.9.27-static-only.patch`.

The short version: this bootstrap TCC is intentionally a static-output
compiler. It should not emit dynamic executables, shared objects, `.interp`, or
ELF metadata that depends on a dynamic loader path.

## What The Patch Does

The patch enforces that policy in two places:

- In `tcc.c`, after option parsing, it rejects `-shared` and default
  non-static executable output. This gives normal command-line users a direct
  error before the compiler gets deep into linking.
- In `tccelf.c`, inside `elf_output_file()`, it repeats the same restriction
  before runtime libraries are linked and before upstream would create
  `.interp`, `.dynsym`, `.dynamic`, GOT/PLT dynamic-linking state, or shared
  object exports. This is the safety check for less-direct entry paths.

The patch also changes `-print-search-dirs` to report:

```text
elfinterp:
  -
```

That avoids printing an upstream default loader path which this bootstrap
compiler cannot validly use.

## Why Not Configure `CONFIG_TCC_ELFINTERP`

Upstream TCC uses `CONFIG_TCC_ELFINTERP` only after it has already chosen to
emit a dynamic executable. Supplying an empty string, `false`, or any other
sentinel would still leave a dynamic ELF path in the compiler: it would just
choose a bad interpreter string when the bad path is reached.

This patch makes the dynamic ELF path unsupported instead. Bootstrap builds no
longer pass `-DCONFIG_TCC_ELFINTERP=""`; there is no meaningful interpreter
path to configure because dynamic executable output is banned.

## Expected Behavior

Allowed:

- Static executable output with `-static`.
- Object output with `-c`.
- Preprocessor output with `-E`.
- Archive creation with `-ar`.

Rejected:

- Default executable output without `-static`.
- Shared object output with `-shared`.
- Shared object output with `-shared -static`.

The policy is intentionally narrower than a general-purpose TCC install. It is
for this repo's x86_64 Linux bootstrap compiler, whose job is to produce static
bootstrap artifacts.

## Why CRT Cannot Fix This

The CRT starts after the kernel has already loaded the executable. For a
dynamic executable, the `.interp` segment has already selected the dynamic
loader before any CRT code can run. The CRT also lacks TCC's relocation and
symbol metadata, so it cannot reconstruct intended GOT/PLT targets or repair a
bad interpreter decision.

The right place to reject this is therefore the ELF link step, before `.interp`
or dynamic-linking sections are emitted.
