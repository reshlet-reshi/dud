#!/bin/sh
set -eu

usage() {
    printf '%s\n' \
        'usage: proto/sandbox/scripts/run-sandbox.sh --loader LOADER --bwrap BWRAP --target TARGET_BLOB [--timeout-seconds N] [--kill-after-seconds N] [--max-target-size BYTES]' >&2
}

usage_error() {
    printf '%s\n' "$1" >&2
    usage
    exit 2
}

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

require_command_path() {
    require_command_path_label=$1
    require_command_path_value=$2

    if ! command -v "$require_command_path_value" >/dev/null 2>&1; then
        printf 'missing executable %s: %s\n' \
            "$require_command_path_label" \
            "$require_command_path_value" >&2
        exit 1
    fi

    unset require_command_path_label require_command_path_value
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

loader=
bwrap=
target=
timeout_seconds=1
kill_after_seconds=1
max_target_size=1048576

while [ "$#" -gt 0 ]; do
    case "$1" in
        --loader)
            [ "$#" -ge 2 ] || usage_error 'missing value for --loader'
            loader=$2
            shift 2
            ;;
        --bwrap)
            [ "$#" -ge 2 ] || usage_error 'missing value for --bwrap'
            bwrap=$2
            shift 2
            ;;
        --target)
            [ "$#" -ge 2 ] || usage_error 'missing value for --target'
            target=$2
            shift 2
            ;;
        --timeout-seconds)
            [ "$#" -ge 2 ] || usage_error 'missing value for --timeout-seconds'
            timeout_seconds=$2
            shift 2
            ;;
        --kill-after-seconds)
            [ "$#" -ge 2 ] ||
                usage_error 'missing value for --kill-after-seconds'
            kill_after_seconds=$2
            shift 2
            ;;
        --max-target-size)
            [ "$#" -ge 2 ] || usage_error 'missing value for --max-target-size'
            max_target_size=$2
            shift 2
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            usage_error "unknown argument: $1"
            ;;
    esac
done

[ -n "$loader" ] || usage_error 'missing required --loader'
[ -n "$bwrap" ] || usage_error 'missing required --bwrap'
[ -n "$target" ] || usage_error 'missing required --target'

if ! parse_nonnegative_size "$max_target_size"; then
    usage_error '--max-target-size must be a nonnegative integer'
fi

if ! parse_nonnegative_size "$timeout_seconds"; then
    usage_error '--timeout-seconds must be a nonnegative integer'
fi

if ! parse_nonnegative_size "$kill_after_seconds"; then
    usage_error '--kill-after-seconds must be a nonnegative integer'
fi

require_command_path bwrap "$bwrap"

if [ ! -r "$loader" ]; then
    fail "missing readable loader: $loader"
fi

if [ ! -r "$target" ]; then
    fail "missing readable target: $target"
fi

loader_size=$(wc -c <"$loader")
target_size=$(wc -c <"$target")

if [ "$target_size" -gt "$max_target_size" ]; then
    printf 'target too large: %s > %s\n' "$target_size" "$max_target_size" >&2
    exit 2
fi

rootfs_size=$((loader_size + target_size + 1024 * 1024))

exec 3<"$loader"
exec 4<"$target"

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
    sleep "$timeout_seconds"
    kill "$sandbox_pid" 2>/dev/null || exit 0
    sleep "$kill_after_seconds"
    kill -s KILL "$sandbox_pid" 2>/dev/null || true
) &
watchdog_pid=$!

set +e
wait "$sandbox_pid" 2>/dev/null
status=$?
set -e

kill "$watchdog_pid" 2>/dev/null || true
wait "$watchdog_pid" 2>/dev/null || true

exit "$status"
