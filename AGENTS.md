# AGENTS.md

This repository is `dud`. The current work is `dud-sh`; `dsh` is only an
internal shorthand unless the owner decides otherwise.

## Current Milestone

Build the path from `/bin/sh`-hosted `dud-sh`-compatible files to the first
native `patch-elf`, then to `patch-elf-modular`, then toward a native
`dud-sh` kernel. Do not let later `dud-asm` or `dud-cc` ideas drive stage 0.

## Workflow

- Inspect the current branch and `git status` before editing.
- If on `main`, create or ask for an agent branch before changing files.
- Read this file and any nearer `AGENTS.md` before editing under a subtree.
- Keep changes small and coherent. Prefer one reviewed PR per step.
- Follow `docs/for-agents/github-workflow.md` for GitHub branch, PR, and
  post-merge cleanup work.
- Do not silently change public API/ABI, emitted ABI, language semantics,
  conformance expectations, dependencies, or legal files.
- Keep generated native outputs in `.bin/` and scratch/test temporaries in
  `.tmp/`.

## Validation And Reporting

Run the smallest relevant check before committing. If no check exists yet,
say that clearly. After edits, report changed files, why they changed, tests
run or skipped, relevant output, and open risks.

## Provenance

Browse or re-check primary sources before touching instruction encodings,
syscall numbers, ELF headers, POSIX portability, licenses, or bootstrap
history. Prefer official specs, POSIX/Open Group docs, vendor manuals, Linux
man pages, kernel headers, and well-maintained project docs. Do not copy
substantial third-party or generated code verbatim.

## License

The repository uses 0BSD unless the owner overrides it later.

## Subprojects

Rules specific to `dud-sh` live in `src/dud-sh/AGENTS.md`.
