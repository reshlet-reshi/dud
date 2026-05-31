# Milestones

## Milestone 0: direct sanity check

Run a raw `_start -> exit(0)` static binary under simple bwrap.

this is to validate host support.

This may still need `execve` in seccomp if applying bwrap-level seccomp.

This is only a smoke test, not the final architecture.

## Milestone 1: trusted loader baseline

Implement:

```text
bwrap -> /init loader -> map raw target -> final seccomp exit-only -> jump
```

Pass tests:

```text
exit0 succeeds
write/open/getpid/mmap/clone/socket fail
loop times out
no stdout/stderr
```

## Milestone 2: Landlock deny-all

Add Landlock in loader.

Pass same tests.

if open syscalls are later enabled:

- Verify adding accidental `/tmp` or `/target` path does not become usable
    - ... without matching Landlock rules

## Milestone 3: resource controls

Add:

```text
outer timeout
optional systemd cgroup wrapper
inner RLIMITs
tmpfs sizing
```

Pass:

```text
infinite loop killed
memory burner killed
fd spam impossible
core dumps absent
```

## Milestone 4: first intentional relaxation

Example: read-only input.

Preferred design:

```text
loader reads input into memory
target receives pointer/length
target still cannot open/read arbitrary files
```

If using Linux-style syscalls:

```text
add read/openat/fstat/close only as needed
add Landlock read-only rule for /input
negative tests for /etc, /target, /tmp
```

## Milestone 5: output channel, if needed

Add one bounded output mechanism.

Prefer:

```text
pre-opened output fd
size-limited pipe or file
seccomp allows write only as narrowly as possible
```

Do not add broad stdout/stderr casually.

## Milestone 6: larger app support

Only after the baseline is solid:

```text
implement minimal static ELF loader
add controlled mmap/brk
add auxv/argv/env only as needed
add libc syscall cluster cautiously
consider /proc stubs instead of real /proc
```

The larger the app, the more the sandbox becomes a compatibility container. 

Keep the baseline profile as a regression target.
