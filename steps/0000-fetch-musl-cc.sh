#!/bin/sh
set -eu

. ./lib/set-musl-cc-tarball.sh

if ! ./lib/should-fetch-musl-cc.sh; then
    exit 0
fi

mkdir -p "$(dirname "$musl_cc_tarball")"

musl_cc_url=\
'https://more.musl.cc/11.2.1/x86_64-linux-musl/'\
'x86_64-linux-musl-cross.tgz'

path_to_curl=$1
"$path_to_curl" -fL "$musl_cc_url" -o "$musl_cc_tarball"
