# Per-Relaxation Checklist

For every proposed 

- syscall, 
- capability, 
- mount, 
- fd, 
- env var, 
- device, 
- namespace share, 
- or host service:

```text
Proposed addition:
  what exactly?

Needed for:
  specific operation, not vague compatibility

Phase:
  bwrap setup / loader setup / hostile target

Can it be pre-opened or precomputed?
  yes/no

Smallest form:
  single fd, single file, single syscall, single path, read-only if possible

Object constraint:
  Landlock rule, fd mode, bind mode, path allowlist

Syscall constraint:
  seccomp delta

Resource constraint:
  cgroup, RLIMIT, tmpfs size, fd limit, pids limit

Information exposed:
  what can target learn?

Write/mutation channel:
  what can target change or emit?

Authority amplification:
  can this enable: 
    - exec, 
    - mount, 
    - namespace creation, 
    - ptrace, 
    - caps, 
    - devices, 
    - ioctls?

Violation behavior:
  kill process, EPERM, timeout, normalized failure?

Negative tests:
  neighboring actions that must still fail

Decision:
  deny / setup-only / allow to target
```

Shortest version:

```text
Does this give hostile code a new 
    - object, 
    - syscall, 
    - resource, 
    - communication channel, 
    - or authority source?

If yes, what other layer constrains it?
```

Mapping:

```text
object access       -> Landlock / fd discipline / mount discipline
syscall vocabulary  -> seccomp
resource use        -> cgroups / RLIMITs / tmpfs size
communication       -> fd/env/socket/stdout policy
authority           -> caps / no_new_privs / disable-userns
```
