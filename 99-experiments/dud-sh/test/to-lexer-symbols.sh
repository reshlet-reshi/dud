#!/bin/sh
set -eu

usage() {
    printf '%s\n' \
        'usage: 99-experiments/dud-sh/test/to-lexer-symbols.sh --dud-sh DUD_SH --expect EXPECT' >&2
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

dud_sh=$(absolute_path "$dud_sh")
expect=$(absolute_path "$expect")

if [ ! -x "$dud_sh" ]; then
    fail "missing executable dud-sh: $dud_sh"
fi

if [ ! -x "$expect" ]; then
    fail "missing executable expect: $expect"
fi

test_tmp=$(mktemp -d "${TMPDIR:-/tmp}/dud-test-to-lexer-symbols.XXXXXX")

cleanup_test_tmp() {
    rm -rf "$test_tmp"
}

trap cleanup_test_tmp EXIT HUP INT TERM

"$expect" output '.# ..' "$("$dud_sh" --to-lexer-symbols -c 'a# b~')" \
    'argument source lexer symbols'
"$expect" output '' "$("$dud_sh" --to-lexer-symbols -c '')" \
    'empty argument source lexer symbols'

stdin_expected=$(
    printf '.\n\n# .\n.'
)
stdin_actual=$(
    printf 'A\n\t# ~\200Z' | "$dud_sh" --to-lexer-symbols -
)
"$expect" output "$stdin_expected" "$stdin_actual" 'stdin lexer symbols'

normal_file="$test_tmp/to-lexer-symbols-normal"
printf 'x y#z' >"$normal_file"
"$expect" output '. .#.' \
    "$("$dud_sh" --to-lexer-symbols "$normal_file")" \
    'file lexer symbols'

dash_file="$test_tmp/-to-lexer-symbols-dash"
printf 'dash# name' >"$dash_file"
dash_output=$(
    cd "$test_tmp"
    "$dud_sh" --to-lexer-symbols -- -to-lexer-symbols-dash
)
"$expect" output '....# ....' "$dash_output" 'dash-leading file lexer symbols'
