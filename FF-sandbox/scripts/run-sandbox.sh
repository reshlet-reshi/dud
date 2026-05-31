#!/bin/sh
set -eu

usage() {
    printf '%s\n' 'usage: FF-sandbox/scripts/run-sandbox.sh TARGET_BLOB' >&2
}

parse_nonnegative_size() {
    parse_nonnegative_size_value=$1

    case "$parse_nonnegative_size_value" in
        '' | *[!0-9]*)
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

if [ "$#" -ne 1 ]; then
    usage
    exit 2
fi

target=$1
loader=${SANDBOX_LOADER:-.init/ff-sandbox/loader}
timeout_duration=${SANDBOX_TIMEOUT:-1s}
kill_after=${SANDBOX_KILL_AFTER:-1s}
max_target_size=${SANDBOX_MAX_TARGET_SIZE:-1048576}

if ! parse_nonnegative_size "$max_target_size"; then
    printf '%s\n' 'SANDBOX_MAX_TARGET_SIZE must be a nonnegative integer' >&2
    exit 2
fi

if [ ! -r "$loader" ]; then
    printf 'missing readable loader: %s\n' "$loader" >&2
    exit 2
fi

if [ ! -r "$target" ]; then
    printf 'missing readable target: %s\n' "$target" >&2
    exit 2
fi

loader_size=$(stat -c '%s' -- "$loader")
target_size=$(stat -c '%s' -- "$target")

if [ "$target_size" -gt "$max_target_size" ]; then
    printf 'target too large: %s > %s\n' "$target_size" "$max_target_size" >&2
    exit 2
fi

rootfs_size=$((loader_size + target_size + 1024 * 1024))

exec 3<"$loader"
exec 4<"$target"

exec timeout --foreground --kill-after="$kill_after" "$timeout_duration" \
    bwrap \
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
    </dev/null >/dev/null 2>/dev/null

