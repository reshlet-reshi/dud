# AGENTS.md

These rules apply under `src/dud-sh/`.

## Source Profile

Shared bootstrap files must stay in the tiny `dud-sh` subset that `/bin/sh`
can host today and a future native `dud-sh` can interpret later.

Allowed current forms:

- `set -e`
- `set -- ARG...`
- `:`
- `. PATH-WITH-SLASH`
- `printf FORMAT`
- `chmod +x PATH`
- explicit-path project commands containing `/`
- trailing `>` and `>>` command-local redirection
- `$1` through `$9` and `"$1"` through `"$9"` in constrained forms
- whole-line comments only

Reserved/future, not current: `exec`, FD redirection, `$0`, `$#`, `shift`,
pipelines, functions, variables, command substitution, loops, `if`, `case`,
`test`, `exit`, and `return`.

## Token And Byte Rules

- Use whole-line comments only. Inline comments are invalid for shared source.
- Use single quotes only around literal `printf` format tokens.
- Use double quotes only when the whole token is a positional parameter, such
  as `"$1"`.
- Do not use mixed quoted/unquoted token concatenation.
- Dot-sourced paths and project commands must contain `/`; do not rely on
  ambient `PATH` lookup.
- Shared byte-emitting source uses POSIX-portable octal escapes. Comments and
  docs may show hex for readability.
- Backslash byte interpretation belongs to `printf`, not the file tokenizer.

## File Placement

- Entry scripts live in `bin/` with no extension.
- Shared dot-sourced files use `.dsh` and live under `lib/`.
- Host-only shell adapters use `.sh` and must be clearly separate from shared
  bootstrap source.
- Generated native artifacts go to repository root `.bin/`.
- Scratch and test temporaries go to repository root `.tmp/`.

## Fragment Discipline

Open fragments may be dot-sourced and may emit bytes, but must not emit
relative jumps whose offsets depend on surrounding layout. Sealed gadgets emit
all bytes inline, do not dot-source other files, and may contain documented
internal relative jumps.

Marker byte encodings are provisional until implementation and tests exist.
Ask before freezing emitted ABI.

## Tests

`src/dud-sh/test.py` is reserved for the canonical stdlib-only Python test
runner. It should compare bytes directly with Python file reads and avoid
depending on `cmp`, `od`, `xxd`, `hexdump`, `sed`, `awk`, or `grep`.

Exact stderr text is not a conformance oracle. Exact accepted syntax, byte
output, generated file bytes, exit status where specified, and whitespace or
comment behavior are conformance concerns.
