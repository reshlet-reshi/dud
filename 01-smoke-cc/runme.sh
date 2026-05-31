#!/bin/sh
set -eu

usage() {
    printf '%s\n' 'usage: ./01-smoke-cc/runme.sh' >&2
}

if [ "$#" -ne 0 ]; then
    usage
    exit 2
fi

mkdir -p .dud
cp 01-smoke-cc/shim.sh .dud/smoke-cc
chmod 755 .dud/smoke-cc
