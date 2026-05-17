# Archived Root Agent Policy

Status: archived

This file preserves root `AGENTS.md` policy text that was removed from binding
policy on 2026-05-17. It is historical context only and is not binding.

## Repository Identity And Milestone

The current work is `dud-sh`; `dsh` is only an internal shorthand unless the
owner decides otherwise.

## Current Milestone

Build the path from `/bin/sh`-hosted `dud-sh`-compatible files to the first
native `patch-elf`, then to `patch-elf-modular`, then toward a native
`dud-sh` kernel. Do not let later `dud-asm` or `dud-cc` ideas drive stage 0.

## Workflow

- Follow `for-agents/github-workflow.md` for the active GitHub branch, local
  commit, later PR extraction, and post-merge cleanup workflow.
- Do not silently change public API/ABI, emitted ABI, language semantics,
  conformance expectations, dependencies, or legal files.

## Source Profile

Shared bootstrap files must follow the current `dud-sh` source profile in
`language.md`. That file is the durable reference for the language model,
allowed forms, token and comment rules, command dispatch, and reserved future
features.

Do not broaden the language, introduce reserved/future forms, or change
command semantics without explicit owner approval and matching policy/doc
updates.

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

When `dud-sh` tests begin, create `test.py` as the canonical stdlib-only
Python test runner. It should compare bytes directly with Python file reads
and avoid depending on `cmp`, `od`, `xxd`, `hexdump`, `sed`, `awk`, or
`grep`.

Exact stderr text is not a conformance oracle. Exact accepted syntax, byte
output, generated file bytes, exit status where specified, and whitespace or
comment behavior are conformance concerns.

## Validation And Reporting

Run the smallest relevant check before committing. If no check exists yet, say
that clearly. After edits, report changed files, why they changed, tests run
or skipped, relevant output, and open risks.

## Provenance

Browse or re-check primary sources before touching instruction encodings,
syscall numbers, ELF headers, POSIX portability, licenses, or bootstrap
history. Prefer official specs, POSIX/Open Group docs, vendor manuals, Linux
man pages, kernel headers, and well-maintained project docs. Do not copy
substantial third-party or generated code verbatim.

## License

The repository uses 0BSD unless the owner overrides it later.
