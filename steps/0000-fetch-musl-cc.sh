#!/bin/sh
set -eu

. ./lib/set-musl-cc-tarball.sh
mkdir -p "$(dirname "$musl_cc_tarball")"

musl_cc_url=\
'https://more.musl.cc/11.2.1/x86_64-linux-musl/'\
'x86_64-linux-musl-cross.tgz'

curl -fL "$musl_cc_url" -o "$musl_cc_tarball"
