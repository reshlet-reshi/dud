# Non-Negotiable Invariants

Keep these true unless the whole project goal changes:

```text
rootless preferred
fail closed if namespaces are unavailable
no host root for target
no target capabilities
no target execve
no host filesystem binds in baseline
no /proc in baseline
no /dev in baseline
no inherited environment
no inherited fds
no host service sockets
stdout/stderr discarded unless explicitly added
final seccomp installed immediately before jump
final target policy much smaller than loader setup policy
outer timeout always present
```

The philosophy:

```text
bwrap builds an empty world.
The trusted loader prepares exactly one computation.
Landlock constrains objects.
Seccomp constrains syscalls.
RLIMITs/cgroups constrain resources.
The target gets only what the current test says it needs.
```