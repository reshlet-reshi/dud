# help.md

This `runbook` contains the real
[`implementation`](https://www.vocabulary.com/dictionary/implementation)
of help.md

## what is a `runbook`

- See [`runbooks.md`](docs/runbooks.md)

## advice

- See [`markdown.md`](docs/markdown.md)
- See [`shell.md`](docs/shell.md)

We metion `bootstrapping` in this file.
- See [www.bootstrappable.org](https://www.bootstrappable.org/)

## implementation

### turn on "strict mode"

Before this `runbook` does anything real, it asks `sh` to be a little strict.

- `-e` means: if a `command` fails, stop there.
- `-u` means: if we use a `variable` we did not set, stop there.

This is useful because mistakes should fail early, close to where they happen.

```sh
set -e
set -u
```

### we do not support `arguments` right now

For now, `help.sh` accepts no `arguments`.

That means, you do not `call` it like:
- sh help.sh foo bar

you `call` it like:
- sh ./help.sh

```sh
if [ "$#" -ne 0 ]; then
  printf '%s\n' 'help.sh does not accept arguments yet.' >&2
  printf '%s\n' 'Run sh ./help.sh with no arguments.' >&2
  exit 2
fi
```

# Teapot

With no arguments, print current placeholder.

```sh
printf '%s\n' "418 I'm a teapot"
```
