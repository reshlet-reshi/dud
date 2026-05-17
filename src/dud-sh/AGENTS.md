# AGENTS.md

These rules apply under `src/dud-sh/`.

## Source Profile

Shared bootstrap files must follow the current `dud-sh` source profile in
`language.md`. That file is the durable reference for the language model,
allowed forms, token and comment rules, command dispatch, and reserved future
features.

Do not broaden the language, introduce reserved/future forms, or change command
semantics without explicit owner approval and matching policy/doc updates.

Shared byte-emitting source uses POSIX-portable octal escapes. Comments and
docs may show hex for readability.

## File Placement

- Entry scripts live in `bin/` with no extension.
- Shared dot-sourced files use `.dsh` and live under `lib/`.
- Host-only shell adapters use `.sh` and must be clearly separate from shared
  bootstrap source.
- Generated native artifacts go to repository root `.bin/`.
- Scratch and test temporaries go to repository root `.tmp/`.
- Planned directories are documented, not preserved with `.gitkeep`. Create
  directories when adding real tracked files; tools and tests must create
  output/scratch directories before writing.

## Fragment Discipline

Open fragments may be dot-sourced and may emit bytes, but must not emit
relative jumps whose offsets depend on surrounding layout. Sealed gadgets emit
all bytes inline, do not dot-source other files, and may contain documented
internal relative jumps.

Marker byte encodings are provisional until implementation and tests exist.
Ask before freezing emitted ABI.

## Tests

When `dud-sh` tests begin, create `src/dud-sh/test.py` as the canonical
stdlib-only Python test runner. It should compare bytes directly with Python
file reads and avoid depending on `cmp`, `od`, `xxd`, `hexdump`, `sed`, `awk`,
or `grep`.

Exact stderr text is not a conformance oracle. Exact accepted syntax, byte
output, generated file bytes, exit status where specified, and whitespace or
comment behavior are conformance concerns.
