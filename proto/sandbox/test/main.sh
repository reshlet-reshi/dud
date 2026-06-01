#!/bin/sh
set -eu

usage() {
    printf '%s\n' \
        'usage: proto/sandbox/test/main.sh --runner RUNNER --loader LOADER --bwrap BWRAP --target-dir DIR' >&2
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

runner=
loader=
bwrap=
target_dir=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --runner)
            [ "$#" -ge 2 ] || usage_error 'missing value for --runner'
            runner=$2
            shift 2
            ;;
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
        --target-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --target-dir'
            target_dir=$2
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

[ -n "$runner" ] || usage_error 'missing required --runner'
[ -n "$loader" ] || usage_error 'missing required --loader'
[ -n "$bwrap" ] || usage_error 'missing required --bwrap'
[ -n "$target_dir" ] || usage_error 'missing required --target-dir'

test_tmp=$(mktemp -d "${TMPDIR:-/tmp}/dud-test-sandbox.XXXXXX")
stdout_file=$test_tmp/stdout
stderr_file=$test_tmp/stderr

cleanup_test_tmp() {
    rm -rf "$test_tmp"
}

run_target() {
    run_target_path=$1

    set +e
    "$runner" \
        --loader "$loader" \
        --bwrap "$bwrap" \
        --target "$run_target_path" \
        >"$stdout_file" 2>"$stderr_file"
    run_status=$?
    set -e

    unset run_target_path
}

assert_no_output() {
    assert_no_output_label=$1

    if [ -s "$stdout_file" ]; then
        fail "$assert_no_output_label: expected empty stdout"
    fi

    if [ -s "$stderr_file" ]; then
        fail "$assert_no_output_label: expected empty stderr"
    fi

    unset assert_no_output_label
}

expect_success() {
    expect_success_name=$1
    expect_success_target=$target_dir/$expect_success_name.bin

    run_target "$expect_success_target"
    if [ "$run_status" -ne 0 ]; then
        fail "$expect_success_name: expected status 0, got $run_status"
    fi
    assert_no_output "$expect_success_name"

    unset expect_success_name expect_success_target
}

expect_failure() {
    expect_failure_name=$1
    expect_failure_target=$target_dir/$expect_failure_name.bin

    run_target "$expect_failure_target"
    if [ "$run_status" -eq 0 ]; then
        fail "$expect_failure_name: expected nonzero status"
    fi
    assert_no_output "$expect_failure_name"

    unset expect_failure_name expect_failure_target
}

trap cleanup_test_tmp EXIT HUP INT TERM

if [ ! -x "$runner" ]; then
    fail "missing executable runner: $runner"
fi

if [ ! -x "$loader" ]; then
    fail "missing executable loader: $loader"
fi

if [ ! -d "$target_dir" ]; then
    fail "missing target directory: $target_dir"
fi

expect_success exit0

expect_failure exit7
expect_failure write_stdout
expect_failure read_stdin
expect_failure open_target
expect_failure open_etc_passwd
expect_failure getpid
expect_failure mmap
expect_failure mprotect
expect_failure brk
expect_failure clone
expect_failure execve
expect_failure socket
expect_failure ioctl
expect_failure ptrace
expect_failure unshare
expect_failure mount
expect_failure loop
expect_failure segfault
expect_failure illegal
expect_failure return
