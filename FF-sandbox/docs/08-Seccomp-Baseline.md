# Seccomp Baseline

Final hostile-code seccomp profile:

```text
default:
  KILL_PROCESS

allow:
  exit
```

Optional stricter proof profile:

```text
allow:
  exit only when arg0 == 0
```

Practical runner profile:

```text
allow:
  exit with any status
```

Do not allow in baseline:

```text
read
write
open
openat
close
fstat
mmap
mprotect
brk
clone
clone3
fork
vfork
execve
execveat
socket
connect
accept
send
recv
ioctl
fcntl
ptrace
mount
unshare
setns
bpf
perf_event_open
userfaultfd
io_uring_setup
keyctl
prlimit64
```

The last seccomp goes inside the trusted loader immediately before the jump.

Add a bwrap-level seccomp profile as defense-in-depth for the trusted loader.

It must allow whatever syscalls the loader needs during setup.
