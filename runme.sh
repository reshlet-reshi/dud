#!/bin/sh
set -eu

usage() {
    printf '%s\n' 'usage: ./runme.sh' >&2
}

if [ "$#" -ne 0 ]; then
    usage
    exit 2
fi

mkdir -p .dud

./00-shellcheck/runme.sh
./01-smoke-cc/runme.sh
./02-musl-cc/runme.sh
