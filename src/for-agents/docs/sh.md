# Host-Side POSIX sh Helpers

This document describes conventions for host-side agent helper scripts under
`src/for-agents/`. These conventions do not apply to `dud-sh` bootstrap source.

## Scope

Agent helpers may use ordinary host tools such as `git`, `gh`, POSIX `sh`, and
future repo-local validation tools. They are convenience tooling for Codex
workflow, not part of the bootstrap runtime.

## Entry Points And Libraries

Executable entry points live in `src/for-agents/bin/` and have no filename
extension. Shared shell libraries live in `src/for-agents/lib/` and may use a
`.sh` extension because they are sourced, not executed directly.

Entry points should stay small:

- validate arguments;
- locate any sibling library files;
- source explicit library paths;
- call one top-level function.

Libraries should hold reusable functions and the workflow logic.

POSIX `sh` runs commands from a file, command string, or standard input; a
script file does not need to be executable when passed as a shell command file.
For executable host helpers, this repo still uses `#!/bin/sh` for pragmatic
host compatibility. POSIX does not guarantee the standard shell is exactly
`/bin/sh`, so this is a deliberate host-tooling convention rather than a
portable bootstrap claim. Sources: [POSIX `sh(1p)`](https://man7.org/linux/man-pages/man1/sh.1p.html)
and [POSIX shell command language](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html).

## Sourcing

Use `.` only with an explicit path containing `/`. POSIX dot-sourcing searches
`PATH` when the file operand contains no slash, which is not appropriate for
repo-local helper libraries. Source: [POSIX dot utility](https://man7.org/linux/man-pages/man1/dot.1p.html).

Entry points should resolve their library directory relative to the entrypoint
path, then source that explicit path:

```sh
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
helpers_dir=$(dirname -- "$script_dir")/lib
. "$helpers_dir/github-workflow.sh"
```

## Comments And References

Shell helper scripts should use whole-line comments. Prefer short comments that
explain why a safety check or non-obvious shell pattern exists.

When a script relies on a repo convention documented here, use a repo-local
reference comment:

```sh
# @./src/for-agents/docs/sh.md#sourcing
```

## Safety Pattern

Host-side helpers should:

- use `set -eu`;
- fail with a clear diagnostic before destructive actions;
- echo mutating commands before running them;
- verify current GitHub identity before pushing or deleting remote refs;
- verify PR merge state and branch object IDs before cleanup;
- keep validation commands in PR bodies and commit messages.

## Field Parsing

Prefer structured CLI output when practical. If a helper intentionally splits a
fixed-width, whitespace-delimited command result, keep that split localized,
document why it is safe, and add a narrow ShellCheck directive rather than
disabling checks for the whole file.
