#!/bin/sh
set -eu

usage() {
    printf '%s\n' \
        'usage: 99-experiments/expect/runme.sh --expect-dir DIR --cc CC --out-dir DIR' \
        >&2
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

absolute_dir() {
    absolute_dir_value=$1
    absolute_dir_result=$(
        CDPATH=
        cd "$absolute_dir_value" &&
            pwd
    )
    printf '%s\n' "$absolute_dir_result"
    unset absolute_dir_value absolute_dir_result
}

expect_dir=
cc=
out_dir=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --expect-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --expect-dir'
            expect_dir=$2
            shift 2
            ;;
        --cc)
            [ "$#" -ge 2 ] || usage_error 'missing value for --cc'
            cc=$2
            shift 2
            ;;
        --out-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --out-dir'
            out_dir=$2
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

[ -n "$expect_dir" ] || usage_error 'missing required --expect-dir'
[ -n "$cc" ] || usage_error 'missing required --cc'
[ -n "$out_dir" ] || usage_error 'missing required --out-dir'

if [ ! -d "$expect_dir" ]; then
    fail "missing expect directory: $expect_dir"
fi
expect_dir=$(absolute_dir "$expect_dir")

if [ ! -f "$expect_dir/main.c" ]; then
    fail "missing expect source: $expect_dir/main.c"
fi
if [ ! -x "$expect_dir/test/main.sh" ]; then
    fail "missing executable expect test runner: $expect_dir/test/main.sh"
fi

require_command_path 'C compiler' "$cc"

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/expect.XXXXXX")
cleanup_tmp() { rm -rf "$tmp_dir"; }
trap cleanup_tmp EXIT HUP INT TERM

mkdir -p "$out_dir"
out_dir=$(absolute_dir "$out_dir")

expect_tmp=$tmp_dir/expect
expect=$out_dir/expect
"$cc" \
    -static \
    -std=c11 \
    -Wfatal-errors \
    "$expect_dir/main.c" \
    -o "$expect_tmp"
cp "$expect_tmp" "$expect"
chmod 755 "$expect"

"$expect_dir/test/main.sh" --expect "$expect"
