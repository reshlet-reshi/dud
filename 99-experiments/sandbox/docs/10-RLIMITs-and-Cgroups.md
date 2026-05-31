# RLIMITs and Cgroups

Use both inner and outer resource controls.

## Outer controls

Apply to the whole sandbox lifetime:

```text
wall-clock timeout
cgroup memory limit
cgroup pids/tasks limit
cgroup CPU policy
cgroup swap policy
```

Purpose:

```text
kill infinite loops
contain memory pressure
contain fork/thread bombs if process creation is later allowed
contain bwrap/loader bugs too
```

## Inner loader RLIMITs

Apply immediately before hostile code:

```text
RLIMIT_CORE   = 0       # no core dumps
RLIMIT_FSIZE  = 0       # no file growth
RLIMIT_CPU    = small   # coarse CPU seconds
RLIMIT_AS     = small   # address-space cap
RLIMIT_STACK  = small   # stack cap
RLIMIT_NPROC  = 0/1     # no process creation
RLIMIT_NOFILE = 0       # no future fds
```

RLIMITs are not enough by themselves. 

They complement cgroups and seccomp.
