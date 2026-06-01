# dud-sh

Small shell experiment currently focused on lexer-symbol output.

## Build and Test

```sh
./99-experiments/dud-sh/runme.sh \
    --dud-sh-dir ./99-experiments/dud-sh \
    --cc ./.dud/x86_64-linux-musl-native/bin/x86_64-linux-musl-gcc \
    --expect ./.dud/expect \
    --out-dir ./.dud/experiments/dud-sh
```

This builds:

```text
OUT_DIR/dud-sh
```

Temporary build and test scratch is created with `mktemp` under
`${TMPDIR:-/tmp}`. The runner does not bootstrap the compiler or `expect`;
pass existing executable paths with `--cc` and `--expect`.
