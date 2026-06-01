# sandbox

Standalone proof baseline for a hostile raw x86-64 target.

The first runnable shape is:

```text
outer runner -> bwrap sandbox -> trusted static loader -> raw target bytes
```

The target is not an ELF program. It is a raw code blob whose entrypoint is
byte 0. The loader maps the bytes, closes inherited file descriptors, installs
final seccomp, switches to a clean stack, and jumps.

Milestone 1 is intentionally strict:

```text
allow:
  exit(status == 0)

kill:
  everything else
```

There is no `/proc`, no `/dev`, no host filesystem bind, no network, no
environment, no inherited file descriptors, and no stdout/stderr channel for
the target. The only intended result is exit status plus unavoidable timing.

## Build and Test

```sh
./proto/sandbox/runme.sh \
    --sandbox-dir ./proto/sandbox \
    --cc ./.dud/x86_64-linux-musl-native/bin/x86_64-linux-musl-gcc \
    --out-dir ./.dud/experiments/sandbox \
    --bwrap /usr/bin/bwrap \
    --nasm /usr/bin/nasm
```

This builds:

```text
OUT_DIR/loader
OUT_DIR/targets/*.bin
```

Temporary build scratch is created with `mktemp` under `${TMPDIR:-/tmp}`.
The sandbox runner does not bootstrap the compiler; pass an existing compiler
with `--cc`.

Target sources are neutral flat x86-64 Intel-ish `.asm` files. `runme.sh`
can assemble them with `--asm-script SCRIPT`, `--fasm FASM`, `--nasm NASM`,
or `--as AS --objcopy OBJCOPY`.

## Run One Blob

```sh
proto/sandbox/scripts/run-sandbox.sh \
    --loader ./.dud/experiments/sandbox/loader \
    --bwrap /usr/bin/bwrap \
    --target ./.dud/experiments/sandbox/targets/exit0.bin
```

The runner uses strict `bwrap` namespace flags. On this host, strict bwrap
works outside the Codex sandbox, but user namespace creation is blocked inside
the Codex command sandbox.
