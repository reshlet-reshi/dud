#!/bin/sh
set -eu

# usage/args check

usage() {
    printf '%s\n' 'usage: ./runme.sh' >&2
}

if [ "$#" -ne 0 ]; then
    usage
    exit 2
fi

# ensure ignored dir

mkdir -p .dud

# shellcheck all

./00-shellcheck/runme.sh

# smoke-cc

cp 01-smoke-cc/script.sh .dud/smoke-cc
chmod 755 .dud/smoke-cc

# musl-cc

./02-musl-cc/runme.sh
