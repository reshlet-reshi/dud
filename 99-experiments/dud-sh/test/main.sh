#!/bin/sh
set -eu

usage() {
    printf '%s\n' \
        'usage: 99-experiments/dud-sh/test/main.sh --dud-sh DUD_SH --expect EXPECT --test-dir DIR' >&2
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

dud_sh=
expect=
test_dir=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --dud-sh)
            [ "$#" -ge 2 ] || usage_error 'missing value for --dud-sh'
            dud_sh=$2
            shift 2
            ;;
        --expect)
            [ "$#" -ge 2 ] || usage_error 'missing value for --expect'
            expect=$2
            shift 2
            ;;
        --test-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --test-dir'
            test_dir=$2
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

[ -n "$dud_sh" ] || usage_error 'missing required --dud-sh'
[ -n "$expect" ] || usage_error 'missing required --expect'
[ -n "$test_dir" ] || usage_error 'missing required --test-dir'

dud_sh=$(absolute_path "$dud_sh")
expect=$(absolute_path "$expect")

if [ ! -x "$dud_sh" ]; then
    fail "missing executable dud-sh: $dud_sh"
fi

if [ ! -x "$expect" ]; then
    fail "missing executable expect: $expect"
fi

if [ ! -d "$test_dir" ]; then
    fail "missing test directory: $test_dir"
fi

test_tmp=$(mktemp -d "${TMPDIR:-/tmp}/dud-test-dud-sh.XXXXXX")

cleanup_test_tmp() {
    rm -rf "$test_tmp"
}

trap cleanup_test_tmp EXIT HUP INT TERM

"$expect" error 2 '???' "$dud_sh"
"$expect" error 2 '???' "$dud_sh" --to-lexer-symbols
"$expect" error 2 '???' "$dud_sh" -c ':'
"$expect" error 1 '!!!' \
    "$dud_sh" --to-lexer-symbols "$test_tmp/no-such-file"

"$test_dir/to-lexer-symbols.sh" \
    --dud-sh "$dud_sh" \
    --expect "$expect"
