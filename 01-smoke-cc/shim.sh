#!/bin/sh
set -eu

usage() {
    printf '%s\n' 'usage: ./.dud/smoke-cc CC [CC_ARG...]' >&2
}

if [ "$#" -lt 1 ]; then
    usage
    exit 2
fi

cc=$1
shift
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dud-smoke-cc.XXXXXX")
cleanup_tmp() { rm -rf "$tmp_dir"; }
trap cleanup_tmp EXIT HUP INT TERM

smoke_src=$tmp_dir/return-0.c
smoke_exe=$tmp_dir/return-0
cat >"$smoke_src" <<'EOF'
int main(void) {
    return 0;
}
EOF
"$cc" "$@" "$smoke_src" -o "$smoke_exe"
"$smoke_exe"
