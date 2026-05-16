# dud-sh Language

`dud-sh` is not a general shell. It is a tiny bootstrap command language whose
early source files are hosted by `/bin/sh` today and should remain regular
enough for a future native `dud-sh` to interpret the same files later.

The guiding model is deliberately small:

```text
A file is newline-separated commands.
A command is whitespace-separated tokens.
The kernel parser does no global syntax parsing beyond that.
Any extra interpretation belongs to a command, not to the file parser.
```

## Current Source Profile

Shared bootstrap files may use only the current `dud-sh` profile:

- `set -e`
- `set -- ARG...`
- `:`
- `. PATH-WITH-SLASH`
- `printf FORMAT`
- `chmod +x PATH`
- explicit-path project commands containing `/`
- trailing `>` and `>>` command-local redirection
- `$1` through `$9` and `"$1"` through `"$9"` in constrained forms
- whole-line comments

`set -e` means simplified fail-fast behavior for shared source: if any command
returns nonzero, the script aborts. Shared source should avoid shell constructs
that make real `/bin/sh` `set -e` behavior surprising.

`set -- ARG...` is the only current parameterization form. It sets positional
parameters for later commands or dot-sourced fragments. Avoid broader variable
semantics.

## Comments

A comment line is one whose first non-whitespace token starts with `#`.
Inline comments are invalid in shared `dud-sh` source.

Valid:

```sh
# This is a whole-line comment.
printf '\177\105\114\106'
```

Invalid:

```sh
printf '\177\105\114\106' # inline comments are not part of dud-sh
```

## Tokens And Quoting

Quotes are allowed only as shell-compatible token wrappers in the current
profile. They are not a general string language.

Allowed quoting forms:

- single quotes around a fully literal `printf` format token
- double quotes only when the whole token is a positional parameter, such as
  `"$1"`

Forbidden forms:

- mixed quoted/unquoted token concatenation
- command substitution
- backticks
- `${...}` expansion
- arithmetic expansion
- glob-dependent source behavior
- escaped-space token tricks
- general variables

Backslash byte interpretation belongs to `printf`, not to the file tokenizer.

## Command Dispatch

Shared bootstrap source must not rely on ambient `PATH` lookup.

Dot-sourced paths must contain `/`:

```sh
. ./lib/foo.dsh
```

Project commands must also be explicit paths:

```sh
./patch-elf ./patch-elf-modular
```

## Reserved Future Features

The following features are reserved for future profiles and are not part of the
current `dud-sh` source profile:

- `exec`
- FD redirection
- `$0`
- `$#`
- `shift`
- pipelines
- functions
- variables
- command substitution
- loops
- `if`
- `case`
- `test`
- `exit`
- `return`

Do not introduce these forms into shared bootstrap source without an explicit
owner decision and a corresponding policy update.
