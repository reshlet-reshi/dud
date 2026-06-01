#!/bin/sh
set -eu

usage() {
    printf '%s\n' 'usage: ./clean.sh' >&2
}

if [ "$#" -ne 0 ]; then
    usage
    exit 2
fi

script_dir=$(
    CDPATH=
    cd "$(dirname "$0")" &&
        pwd
)

rm -rf "$script_dir/.dud"
