# Common Add-Back Recipes

## Read-only input

Best:

```text
loader reads input before final lockdown
target receives pointer/length in memory
no openat for target
```

If target must open a path:

```text
bwrap exposes /input read-only
Landlock allows read-file on /input only
seccomp allows openat/read/close/fstat only as needed
no write
no directory traversal beyond intended path
```

## Output

If only exit code is intended:

```text
do not add output
stdout/stderr remain /dev/null
write syscall denied
```

If output becomes required:

```text
prefer one pre-opened output fd
allow write only to that fd if possible
limit size with RLIMIT_FSIZE or pipe reader
do not add writable host directories
```

## Temporary storage

Prefer:

```text
anonymous memory
fixed arena
bounded tmpfs
```

Avoid host `/tmp`.

If `/tmp` is required:

```text
empty tmpfs /tmp
tmpfs size cap
Landlock write/create only under /tmp
no host bind
```

## Randomness

Prefer:

```text
getrandom syscall
```

Over:

```text
/dev/urandom
```

## Time

Prefer:

```text
clock_gettime
```

Over:

```text
/proc
/dev
host services
```

## Dynamic memory

If needed:

```text
allow mmap/brk carefully
RLIMIT_AS
cgroup MemoryMax
deny PROT_EXEC mappings
deny mprotect adding PROT_EXEC
```

## Threads/processes

Default deny.

If eventually needed:

```text
allow clone/clone3 only with known flags
use pids cgroup
use RLIMIT_NPROC
ensure there is a real PID 1 reaper
decide whether exit or exit_group is required
```

## `/proc`

Default deny.

If required:

```text
mount proc only inside PID namespace
expect a large information surface
test what can be learned
consider whether a stub file is safer
```

## `/dev`

Default deny.

If required:

```text
add exact device only
avoid --dev /dev
avoid ttys
avoid GPUs
avoid fuse
avoid raw devices
```

## Network

Default deny.

If required:

```text
prefer proxy/helper outside sandbox
avoid full host networking
use network namespace
use seccomp to restrict socket families/types
use Landlock network restrictions where available
use egress allowlist outside if possible
```

## Host service sockets

Default deny.

Be extremely suspicious of:

```text
DBus
Wayland
X11
PulseAudio/PipeWire
SSH agent
GPG agent
Docker socket
Podman socket
systemd user bus
Kubernetes config/socket
cloud metadata service
```

These often carry more authority than ordinary files.
