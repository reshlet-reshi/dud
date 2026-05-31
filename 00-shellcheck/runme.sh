#!/bin/sh
set -eu

usage() {
    printf '%s\n' 'usage: ./00-shellcheck/runme.sh' >&2
}

shellcheck_dir=.dud/shellcheck-v0.11.0.linux.x86_64

if [ "$#" -ne 0 ]; then
    usage
    exit 2
fi

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dud-shellcheck.XXXXXX")
cleanup_tmp() { rm -rf "$tmp_dir"; }
trap cleanup_tmp EXIT HUP INT TERM

mkdir -p .dud

shellcheck=$shellcheck_dir/shellcheck-v0.11.0/shellcheck
if [ ! -x "$shellcheck" ]; then
    mkdir "$tmp_dir/shellcheck"
    tar -xJf 00-shellcheck/shellcheck-v0.11.0.linux.x86_64.tar.xz \
        -C "$tmp_dir/shellcheck"
    rm -rf "$shellcheck_dir"
    mv "$tmp_dir/shellcheck" "$shellcheck_dir"
fi

file_list=$tmp_dir/files
find . \
    \( \
        -path './.git' -o \
        -path './.dud' \
    \) -prune -o \
    -type f \
    -print >"$file_list"

status=0
newline='
'
has_sh_shebang() {
    path=$1
    prefix=$(dd if="$path" bs=18 count=1 2>/dev/null || true)
    case "$prefix" in
        '#!/bin/sh' | "#!/bin/sh$newline"* | \
        '#!/usr/bin/env sh' | "#!/usr/bin/env sh$newline"*) return 0 ;;
    esac
    return 1
}
is_shell_script() {
    path=$1
    name=${path##*/}
    case "$name" in
        *.sh) return 0 ;;
        *.*) return 1 ;;
    esac
    has_sh_shebang "$path"
}
run_shellcheck() {
    path=$1
    "$shellcheck" -x -s sh -- "$path"
}

while IFS= read -r path; do
    if is_shell_script "$path"; then
        run_shellcheck "$path" || status=1
    fi
done <"$file_list"

if [ "$status" -ne 0 ]; then
    exit "$status"
fi
