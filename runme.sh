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
cp 01-smoke-cc/script.sh .dud/smoke-cc
chmod 755 .dud/smoke-cc
./02-musl-cc/runme.sh
