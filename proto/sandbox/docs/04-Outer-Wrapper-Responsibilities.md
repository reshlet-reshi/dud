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

Skeleton shape:

```sh
#!/bin/sh
set -eu

loader=$1
bwrap=$2
target=$3

exec 3<"$loader"
exec 4<"$target"

loader_size=$(wc -c <"$loader")
target_size=$(wc -c <"$target")

# Leave room for tmpfs metadata and page rounding.
rootfs_size=$((loader_size + target_size + 1024 * 1024))

"$bwrap" \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
    --unshare-net \
    --unshare-uts \
    --unshare-cgroup \
    --disable-userns \
    --assert-userns-disabled \
    --uid 65534 \
    --gid 65534 \
    --hostname x \
    --die-with-parent \
    --new-session \
    --as-pid-1 \
    --cap-drop ALL \
    --clearenv \
    --size "$rootfs_size" --tmpfs / \
    --perms 0555 --file 3 /init \
    --perms 0444 --file 4 /target \
    --remount-ro / \
    --chdir / \
    --argv0 init \
    -- \
    /init /target \
    </dev/null >/dev/null 2>/dev/null &
sandbox_pid=$!

(
    sleep 1
    kill "$sandbox_pid" 2>/dev/null || exit 0
    sleep 1
    kill -s KILL "$sandbox_pid" 2>/dev/null || true
) &
watchdog_pid=$!

set +e
wait "$sandbox_pid" 2>/dev/null
status=$?
set -e
kill "$watchdog_pid" 2>/dev/null || true
exit "$status"
```

Do not use `systemd-run`.

prefer this shape:

```sh
/path/to/run-sandbox.sh \
    --loader /path/to/loader \
    --bwrap /path/to/bwrap \
    --target "$target"
```

Timeout/cgroup policy is necessary.

a target can spin forever without making syscalls.

## TODO

need a way to do more cgroups type things that is not bound to systemd-run
