# Agent Helper Tools

This directory contains host-side helper tools for agents working on `dud`.
These files are not `dud-sh` bootstrap/runtime source.

Executable helpers live in `src/for-agents/bin/` and have no filename
extension. Shared helper libraries live in `src/for-agents/lib/`. These files
may use ordinary host tools such as `git`, `gh`, and POSIX `sh`.

## Tools

- `bin/cleanup-merged-pr PR_NUMBER` verifies that a pull request is merged,
  updates local `main`, removes the matching local branch, and removes the
  remote branch only if it still exists after merge.

## Docs

- `docs/sh.md` documents host-side POSIX `sh` conventions and source comment
  references for agent helper scripts.

## TODO

- Vendor a `shellcheck` binary, or pin a repo-local ShellCheck path, for
  validating host-side agent scripts.
