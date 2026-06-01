#!/bin/sh
set -eu

usage() {
    printf '%s\n' \
        'usage: proto/dud-sh/runme.sh --dud-sh-dir DIR --cc CC --expect EXPECT --out-dir DIR' >&2
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

dud_sh_dir=
cc=
expect=
out_dir=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --dud-sh-dir)
            [ "$#" -ge 2 ] || usage_error 'missing value for --dud-sh-dir'
            dud_sh_dir=$2
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
        -h | --help)
            usage
            exit 0
            ;;
        *)
            usage_error "unknown argument: $1"
            ;;
    esac
done

[ -n "$dud_sh_dir" ] || usage_error 'missing required --dud-sh-dir'
[ -n "$cc" ] || usage_error 'missing required --cc'
[ -n "$expect" ] || usage_error 'missing required --expect'
[ -n "$out_dir" ] || usage_error 'missing required --out-dir'

if [ ! -d "$dud_sh_dir" ]; then
    fail "missing dud-sh directory: $dud_sh_dir"
fi
require_command_path 'C compiler' "$cc"
require_command_path expect "$expect"

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dud-sh.XXXXXX")
cleanup_tmp() { rm -rf "$tmp_dir"; }
trap cleanup_tmp EXIT HUP INT TERM

mkdir -p "$out_dir"
out_dir=$(
    CDPATH=
    cd "$out_dir" &&
        pwd
)

dud_sh_tmp=$tmp_dir/dud-sh
dud_sh=$out_dir/dud-sh
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
    "$dud_sh_dir/main.c" \
    "$dud_sh_dir/action.c" \
    "$dud_sh_dir/clib/io.c" \
    "$dud_sh_dir/clib/str.c" \
    "$dud_sh_dir/clib/exit.c" \
    "$dud_sh_dir/fopen_argv.c" \
    "$dud_sh_dir/lex.c" \
    -o "$dud_sh_tmp"
cp "$dud_sh_tmp" "$dud_sh"
chmod 755 "$dud_sh"

"$dud_sh_dir/test/main.sh" \
    --dud-sh "$dud_sh" \
    --expect "$expect" \
    --test-dir "$dud_sh_dir/test"
