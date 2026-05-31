#!/bin/sh
set -eu

test_tmp=$(mktemp -d "${TMPDIR:-/tmp}/dud-test-to-lexer-symbols.XXXXXX")
dud_sh=$PWD/.dud/dud-sh

cleanup_test_tmp() {
    rm -rf "$test_tmp"
}

trap cleanup_test_tmp EXIT HUP INT TERM

.dud/expect output '.# ..' "$(.dud/dud-sh --to-lexer-symbols -c 'a# b~')" \
    'argument source lexer symbols'
.dud/expect output '' "$(.dud/dud-sh --to-lexer-symbols -c '')" \
    'empty argument source lexer symbols'

stdin_expected=$(
    printf '.\n\n# .\n.'
)
stdin_actual=$(
    printf 'A\n\t# ~\200Z' | .dud/dud-sh --to-lexer-symbols -
)
.dud/expect output "$stdin_expected" "$stdin_actual" 'stdin lexer symbols'

normal_file="$test_tmp/to-lexer-symbols-normal"
printf 'x y#z' >"$normal_file"
.dud/expect output '. .#.' \
    "$(.dud/dud-sh --to-lexer-symbols "$normal_file")" \
    'file lexer symbols'

dash_file="$test_tmp/-to-lexer-symbols-dash"
printf 'dash# name' >"$dash_file"
dash_output=$(
    cd "$test_tmp"
    "$dud_sh" --to-lexer-symbols -- -to-lexer-symbols-dash
)
.dud/expect output '....# ....' "$dash_output" 'dash-leading file lexer symbols'
