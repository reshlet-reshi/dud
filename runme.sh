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
./03-musl-tcc/runme.sh
./04-expect/runme.sh \
    --expect-dir ./04-expect \
    --cc ./.dud/musl-cc \
    --out-dir ./.dud
