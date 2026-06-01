#!/bin/sh
set -eu

usage() {
    printf '%s\n' \
        'usage: proto/ctok/runme.sh --ctok-dir DIR --cc CC --expect EXPECT --out-dir DIR --coverage yes|no [coverage tool paths]' \
        '' \
        'coverage tool paths, required with --coverage yes:' \
        '  --coverage-cc CC --gcov GCOV --awk AWK --sed SED --grep GREP --cut CUT --tr TR --wc WC' \
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

ctok_dir=
cc=
expect=
out_dir=
coverage=
coverage_cc=
gcov=
awk=
sed=
grep=
cut=
tr=
wc=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --ctok-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --ctok-dir'
            ctok_dir=$2
            shift 2
            ;;
        --cc)
            [ "$#" -ge 2 ] || usage_error 'missing value for --cc'
            cc=$2
            shift 2
            ;;
        --expect)
            [ "$#" -ge 2 ] || usage_error 'missing value for --expect'
            expect=$2
            shift 2
            ;;
        --out-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --out-dir'
            out_dir=$2
            shift 2
            ;;
        --coverage)
            [ "$#" -ge 2 ] || usage_error 'missing value for --coverage'
            coverage=$2
            shift 2
            ;;
        --coverage-cc)
            [ "$#" -ge 2 ] || usage_error 'missing value for --coverage-cc'
            coverage_cc=$2
            shift 2
            ;;
        --gcov)
            [ "$#" -ge 2 ] || usage_error 'missing value for --gcov'
            gcov=$2
            shift 2
            ;;
        --awk)
            [ "$#" -ge 2 ] || usage_error 'missing value for --awk'
            awk=$2
            shift 2
            ;;
        --sed)
            [ "$#" -ge 2 ] || usage_error 'missing value for --sed'
            sed=$2
            shift 2
            ;;
        --grep)
            [ "$#" -ge 2 ] || usage_error 'missing value for --grep'
            grep=$2
            shift 2
            ;;
        --cut)
            [ "$#" -ge 2 ] || usage_error 'missing value for --cut'
            cut=$2
            shift 2
            ;;
        --tr)
            [ "$#" -ge 2 ] || usage_error 'missing value for --tr'
            tr=$2
            shift 2
            ;;
        --wc)
            [ "$#" -ge 2 ] || usage_error 'missing value for --wc'
            wc=$2
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

[ -n "$ctok_dir" ] || usage_error 'missing required --ctok-dir'
[ -n "$cc" ] || usage_error 'missing required --cc'
[ -n "$expect" ] || usage_error 'missing required --expect'
[ -n "$out_dir" ] || usage_error 'missing required --out-dir'
[ -n "$coverage" ] || usage_error 'missing required --coverage'

case $coverage in
    yes | no)
        ;;
    *)
        usage_error 'expected --coverage yes or --coverage no'
        ;;
esac

if [ "$coverage" = yes ]; then
    [ -n "$coverage_cc" ] || usage_error 'missing required --coverage-cc'
    [ -n "$gcov" ] || usage_error 'missing required --gcov'
    [ -n "$awk" ] || usage_error 'missing required --awk'
    [ -n "$sed" ] || usage_error 'missing required --sed'
    [ -n "$grep" ] || usage_error 'missing required --grep'
    [ -n "$cut" ] || usage_error 'missing required --cut'
    [ -n "$tr" ] || usage_error 'missing required --tr'
    [ -n "$wc" ] || usage_error 'missing required --wc'
fi

if [ ! -d "$ctok_dir" ]; then
    fail "missing ctok directory: $ctok_dir"
fi
ctok_dir=$(absolute_dir "$ctok_dir")

if [ ! -f "$ctok_dir/main.c" ]; then
    fail "missing ctok source: $ctok_dir/main.c"
fi
if [ ! -x "$ctok_dir/test/main.sh" ]; then
    fail "missing executable ctok test runner: $ctok_dir/test/main.sh"
fi

require_command_path 'C compiler' "$cc"
require_command_path expect "$expect"

if [ "$coverage" = yes ]; then
    require_command_path 'coverage C compiler' "$coverage_cc"
    require_command_path gcov "$gcov"
    require_command_path awk "$awk"
    require_command_path sed "$sed"
    require_command_path grep "$grep"
    require_command_path cut "$cut"
    require_command_path tr "$tr"
    require_command_path wc "$wc"
fi

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/ctok.XXXXXX")
cleanup_tmp() { rm -rf "$tmp_dir"; }
trap cleanup_tmp EXIT HUP INT TERM

mkdir -p "$out_dir"
out_dir=$(absolute_dir "$out_dir")

ctok_tmp=$tmp_dir/ctok
ctok=$out_dir/ctok
"$cc" \
    -static \
    -std=c11 \
    -Wfatal-errors \
    -Wall \
    -Wextra \
    -Wpedantic \
    -Werror \
    -Wmissing-prototypes \
    -Wstrict-prototypes \
    -Wold-style-definition \
    "$ctok_dir/main.c" \
    -o "$ctok_tmp"
cp "$ctok_tmp" "$ctok"
chmod 755 "$ctok"

if [ "$coverage" = yes ]; then
    "$ctok_dir/test/main.sh" \
        --ctok "$ctok" \
        --ctok-dir "$ctok_dir" \
        --expect "$expect" \
        --test-dir "$ctok_dir/test" \
        --coverage "$coverage" \
        --coverage-cc "$coverage_cc" \
        --gcov "$gcov" \
        --awk "$awk" \
        --sed "$sed" \
        --grep "$grep" \
        --cut "$cut" \
        --tr "$tr" \
        --wc "$wc"
else
    "$ctok_dir/test/main.sh" \
        --ctok "$ctok" \
        --ctok-dir "$ctok_dir" \
        --expect "$expect" \
        --test-dir "$ctok_dir/test" \
        --coverage "$coverage"
fi
