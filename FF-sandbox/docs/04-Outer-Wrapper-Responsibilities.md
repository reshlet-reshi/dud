# Outer Wrapper Responsibilities

The outer wrapper should:

```text
open loader and target as fds
compute tmpfs size
invoke bwrap
redirect stdio to /dev/null
apply wall-clock timeout
normalize/report exit status
```

Skeleton:

```sh
#!/usr/bin/env bash
set -euo pipefail

loader=${SANDBOX_LOADER:-./loader}
target=${1:?usage: run-sandbox ./target-blob}

exec {loader_fd}<"$loader"
exec {target_fd}<"$target"

loader_size=$(stat -c '%s' -- "$loader")
target_size=$(stat -c '%s' -- "$target")

# Leave room for tmpfs metadata and page rounding.
rootfs_size=$((loader_size + target_size + 1024 * 1024))

run_bwrap=(
  bwrap
  --unshare-user
  --unshare-ipc
  --unshare-pid
  --unshare-net
  --unshare-uts
  --unshare-cgroup
  --disable-userns
  --assert-userns-disabled
  --uid 65534
  --gid 65534
  --hostname x
  --die-with-parent
  --new-session
  --as-pid-1
  --cap-drop ALL
  --clearenv
  --size "$rootfs_size" --tmpfs /
  --perms 0555 --file "$loader_fd" /init
  --perms 0444 --file "$target_fd" /target
  --remount-ro /
  --chdir /
  --argv0 init
  --
  /init /target
)

exec timeout --foreground --kill-after=1s 1s \
  "${run_bwrap[@]}" \
  </dev/null >/dev/null 2>/dev/null
```

Do not use `systemd-run`.

prefer this shape:

```sh
timeout --foreground --kill-after=1s 1s /path/to/run-sandbox "$target"
```

Timeout/cgroup policy is necessary.

a target can spin forever without making syscalls.

## TODO

need a way to do more cgroups type things that is not bound to systemd-run
