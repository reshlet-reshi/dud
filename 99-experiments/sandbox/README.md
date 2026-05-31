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
./99-experiments/sandbox/runme
```

This builds:

```text
.dud/experiments/sandbox/loader
.dud/experiments/sandbox/targets/*.bin
```

Temporary build scratch is created with `mktemp` under `${TMPDIR:-/tmp}`.

## Run One Blob

```sh
99-experiments/sandbox/scripts/run-sandbox.sh \
    .dud/experiments/sandbox/targets/exit0.bin
```

The runner uses strict `bwrap` namespace flags. On this host, strict bwrap
works outside the Codex sandbox, but user namespace creation is blocked inside
the Codex command sandbox.
