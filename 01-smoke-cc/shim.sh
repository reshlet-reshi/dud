#!/bin/sh
set -eu

usage() {
    printf '%s\n' 'usage: ./.init/smoke-cc CC' >&2
}

if [ "$#" -ne 1 ]; then
    usage
    exit 2
fi

cc=$1
repo_dir=$(
    CDPATH=
    cd "$(dirname "$0")/.."
    pwd
)
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/dud-smoke-cc.XXXXXX")
cleanup_tmp() { rm -rf "$tmp_dir"; }
trap cleanup_tmp EXIT HUP INT TERM

smoke_exe=$tmp_dir/return-0
"$cc" -static "$repo_dir/01-smoke-cc/return-0.c" -o "$smoke_exe"
"$smoke_exe"
