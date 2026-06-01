# Baseline Threat Model

Assume the target code may be malicious.

It should not be able to:

```text
read host files
write host files
use network
use IPC
talk to host services
read environment variables
use inherited fds
write stdout/stderr
open /proc or /dev
spawn processes or threads
exec anything
create namespaces
mount anything
gain capabilities
allocate unbounded memory
consume unbounded CPU forever
make syscalls other than exit
```

It may still:

```text
burn CPU until killed by outer timeout/cgroup
encode information in timing
encode information in exit status, if arbitrary exit codes are allowed
read memory still mapped in its own address space
```

Therefore the trusted loader must not keep secrets in memory before jumping.
