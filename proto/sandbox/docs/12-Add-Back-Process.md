# Add-Back Process

Every relaxation must be classified by phase.

```text
Phase A: bwrap setup
Phase B: trusted loader setup
Phase C: hostile target after final lockdown
```

A permission only needed in Phase A or B should not survive into Phase C.

Example:

```text
loader needs openat to read /target
target does not need openat
therefore final seccomp denies openat
```

The recurring question:

```text
Can this be precomputed, pre-opened, copied, or mapped before the jump?
```

Prefer:

```text
trusted loader opens/maps object
hostile code gets no path syscall
```

Over:

```text
hostile code can open paths itself
```
