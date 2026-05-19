# Shell Policy

Status: Experimental

This policy applies to tracked shell scripts in this repository.

Tracked files ending in `.sh` are shell scripts for this policy.

Tracked executable files with sh, bash, dash, or ksh shebangs are shell
scripts for this policy.

Tracked shell script edits must pass ShellCheck before they are run.

Tracked shell script edits must pass ShellCheck before they are staged or
committed.

Bootstrap commands are exempt when they install or verify the checking tool.

That exemption ends once the vendored ShellCheck binary is available.

## Tools

ShellCheck is the shell script analyzer.

The pinned Linux x86_64 binary lives at
`vendor/shellcheck/linux-x86_64/shellcheck`.

Vendored ShellCheck metadata lives in `vendor/shellcheck/checksums.txt`.

Ordinary checks should use `tools/check-shell.sh`.

## Required Checks

Run ShellCheck with the vendored repository binary.

Use `vendor/shellcheck/linux-x86_64/shellcheck`.

After the vendored binary exists, ordinary checks must not require network
access.

Use `tools/check-shell.sh` for the ordinary repository check.

## Bootstrap Boundary

The first bootstrap step may use network or system tooling.

The bootstrap step may create files under `.tmp/`.

After bootstrap, checks should use only the vendored ShellCheck binary.

Helper scripts should not download ShellCheck during ordinary checks.
