#!/bin/sh
set -eu

usage() {
    printf '%s\n' 'usage: ./99-experiments/ctok/runme.sh' >&2
}

if [ "$#" -ne 0 ]; then
    usage
    exit 2
fi

if [ ! -x .dud/musl-cc ]; then
    ./01-smoke-cc/runme.sh
    ./02-musl-cc/runme.sh
fi

if [ ! -x .dud/expect ]; then
    ./04-expect/runme.sh
fi

mkdir -p .dud
.dud/musl-cc -static -std=c11 -Wfatal-errors \
    99-experiments/ctok/main.c \
    -o .dud/ctok
./99-experiments/ctok/test/main.sh
