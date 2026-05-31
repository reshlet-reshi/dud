#!/bin/sh
set -eu

usage() {
    printf '%s\n' 'usage: 99-experiments/expect/test/main.sh --expect EXPECT' >&2
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

absolute_path() {
    absolute_path_value=$1

    case "$absolute_path_value" in
        /*)
            printf '%s\n' "$absolute_path_value"
            ;;
        */*)
            absolute_path_dir=${absolute_path_value%/*}
            absolute_path_base=${absolute_path_value##*/}
            absolute_path_dir=$(
                CDPATH=
                cd "$absolute_path_dir" &&
                    pwd
            )
            printf '%s/%s\n' "$absolute_path_dir" "$absolute_path_base"
            unset absolute_path_dir absolute_path_base
            ;;
        *)
            command -v "$absolute_path_value"
            ;;
    esac

    unset absolute_path_value
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

expect=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --expect)
            [ "$#" -ge 2 ] || usage_error 'missing value for --expect'
            expect=$2
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

[ -n "$expect" ] || usage_error 'missing required --expect'
require_command_path expect "$expect"
expect=$(absolute_path "$expect")

test_tmp=$(mktemp -d "${TMPDIR:-/tmp}/dud-test-expect.XXXXXX")
stdout_file=$test_tmp/stdout
stderr_file=$test_tmp/stderr
exit_with=$test_tmp/exit-with
stderr_exit=$test_tmp/stderr-exit

cleanup_test_tmp() {
    rm -rf "$test_tmp"
}

write_helpers() {
    cat >"$exit_with" <<'EOF'
#!/bin/sh
exit "$1"
EOF

    cat >"$stderr_exit" <<'EOF'
#!/bin/sh
printf '%s\n' "$1" >&2
exit "$2"
EOF

    chmod +x "$exit_with" "$stderr_exit"
}

run_expect() {
    set +e
    "$expect" "$@" >"$stdout_file" 2>"$stderr_file"
    run_status=$?
    set -e
}

assert_status() {
    label=$1
    expected=$2
    shift 2

    run_expect "$@"
    if [ "$run_status" -ne "$expected" ]; then
        fail "$label: expected status $expected, got $run_status"
    fi
}

assert_stdout_empty() {
    label=$1

    if [ -s "$stdout_file" ]; then
        fail "$label: expected empty stdout"
    fi
}

assert_stderr_empty() {
    label=$1

    if [ -s "$stderr_file" ]; then
        fail "$label: expected empty stderr"
    fi
}

assert_stderr() {
    label=$1
    expected=$2
    actual=$(cat "$stderr_file")

    if [ "$actual" != "$expected" ]; then
        fail "$label: expected stderr [$expected], got [$actual]"
    fi
}

assert_stderr_starts() {
    label=$1
    expected_prefix=$2
    actual=$(cat "$stderr_file")

    case "$actual" in
        "$expected_prefix"*) ;;
        *) fail "$label: expected stderr prefix [$expected_prefix], got [$actual]" ;;
    esac
}

trap cleanup_test_tmp EXIT HUP INT TERM

write_helpers

assert_status 'output equal status' 0 \
    output same same 'output equal'
assert_stdout_empty 'output equal stdout'
assert_stderr_empty 'output equal stderr'

assert_status 'output mismatch status' 1 \
    output expected actual 'output label'
assert_stderr \
    'output mismatch stderr' \
    'output label: expected "expected", got "actual"'

assert_status 'status equal exit' 0 \
    status 7 "$exit_with" 7
assert_stdout_empty 'status equal stdout'
assert_stderr_empty 'status equal stderr'

assert_status 'status mismatch exit' 1 \
    status 0 "$exit_with" 7
assert_stderr_starts \
    'status mismatch stderr' \
    'expected exit 0, got 7: '

assert_status 'status missing command maps to 127' 0 \
    status 127 "$test_tmp/no-such-command"

assert_status 'error equal stderr' 0 \
    error 4 hello "$stderr_exit" hello 4
assert_stdout_empty 'error equal stdout'
assert_stderr_empty 'error equal stderr'

assert_status 'error wrong status' 1 \
    error 0 hello "$stderr_exit" hello 4
assert_stderr_starts \
    'error wrong status stderr' \
    'expected exit 0, got 4: '

assert_status 'error wrong stderr' 1 \
    error 4 hello "$stderr_exit" bye 4
assert_stderr_starts \
    'error wrong stderr' \
    'expected stderr "hello", got "bye": '

assert_status 'usage no args' 2
assert_status 'usage unknown mode' 2 nope
assert_status 'usage malformed status' 2 status nope "$exit_with" 0
assert_status 'usage too few args' 2 error 0 expected
