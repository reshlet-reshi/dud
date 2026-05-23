# shellcheck shell=sh

expect_output() {
    expected=$1
    actual=$2
    label=$3

    if [ "$actual" != "$expected" ]
    then
        printf '%s: expected "%s", got "%s"\n' "$label" "$expected" "$actual" >&2
        exit 1
    fi
}

expect_status() {
    expected=$1
    shift

    set +e
    "$@" >/dev/null 2>/dev/null
    actual=$?
    set -e

    if [ "$actual" -ne "$expected" ]
    then
        printf 'expected exit %s, got %s: %s\n' "$expected" "$actual" "$*" >&2
        exit 1
    fi
}

expect_error() {
    expected_status=$1
    expected_error=$2
    shift 2

    set +e
    actual_error=$("$@" 2>&1 >/dev/null)
    actual_status=$?
    set -e

    if [ "$actual_status" -ne "$expected_status" ]
    then
        printf 'expected exit %s, got %s: %s\n' "$expected_status" "$actual_status" "$*" >&2
        exit 1
    fi

    if [ "$actual_error" != "$expected_error" ]
    then
        printf 'expected stderr "%s", got "%s": %s\n' "$expected_error" "$actual_error" "$*" >&2
        exit 1
    fi
}
