#!/bin/sh
set -eu

out=${MUSL_CC_TARBALL:-vendor/musl-cc/x86_64-linux-musl-cross.tgz}
mkdir -p "$(dirname "$out")"
curl -fL https://more.musl.cc/11.2.1/x86_64-linux-musl/x86_64-linux-musl-cross.tgz -o "$out"
