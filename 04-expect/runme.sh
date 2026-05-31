#!/bin/sh
set -eu

usage() {
    printf '%s\n' 'usage: ./04-expect/runme.sh' >&2
}

if [ "$#" -ne 0 ]; then
    usage
    exit 2
fi

mkdir -p .dud

if [ ! -x .dud/smoke-cc ]; then
    ./01-smoke-cc/runme.sh
fi

if [ ! -x .dud/musl-cc ] ||
    [ ! -x .dud/x86_64-linux-musl-native/bin/x86_64-linux-musl-gcc ]
then
    ./02-musl-cc/runme.sh
fi

.dud/musl-cc -static -std=c11 -Wfatal-errors 04-expect/main.c -o .dud/expect
./04-expect/test/main.sh
