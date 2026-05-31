#!/bin/sh
set -eu

repo_dir=$(
    CDPATH=
    cd "$(dirname "$0")/.."
    pwd
)

exec "$repo_dir/.dud/x86_64-linux-musl-native/bin/x86_64-linux-musl-gcc" \
    -Wall \
    -Wextra \
    -Wpedantic \
    -Werror \
    -Wmissing-prototypes \
    -Wstrict-prototypes \
    -Wold-style-definition \
    "$@"
