# Negative Test Suite for Baseline

Create hostile test blobs/programs that attempt:

```text
exit(0)
exit(7)
write(1, ...)
read(0, ...)
open("/target")
open("/etc/passwd")
getpid()
mmap()
mprotect()
brk()
clone()
execve()
socket()
ioctl()
ptrace()
unshare()
mount()
infinite loop
segfault
illegal instruction
return from entrypoint
```

Expected strict baseline:

```text
exit(0)
  succeeds

exit(7)
  either succeeds with status 7, if arbitrary exit codes are allowed,
  or dies, if enforcing exit(status == 0)

everything else
  killed, denied, timed out, or normalized to failure

stdout/stderr
  no bytes emitted

host filesystem
  no mutation

network
  no traffic

long-running loop
  killed by timeout/cgroup
```
