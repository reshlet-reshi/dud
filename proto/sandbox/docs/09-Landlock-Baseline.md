# Landlock Baseline

Install Landlock in the trusted loader before final seccomp.

For the initial `exit`-only baseline, Landlock is mostly redundant.

seccomp denies filesystem and network syscalls. 

It becomes very valuable once syscalls are added back.

Baseline Landlock policy:

```text
handle all supported filesystem rights
add no allow rules
restrict self
```

Meaning:

```text
future filesystem access denied by default
```

When network Landlock rights are available, deny-by-default.

Important caveats:

```text
Landlock does not replace seccomp.
Landlock does not stop CPU spin.
Landlock does not stop arbitrary non-filesystem syscalls.
Landlock does not save you from already-open fds.
Close fds before jumping.
```

As the sandbox grows, use this pairing:

```text
seccomp:
  which syscalls exist?

Landlock:
  which filesystem/network objects may those syscalls touch?
```
