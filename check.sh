#!/bin/sh
set -eu

tmp=$(mktemp -d "${TMPDIR:-/tmp}/dud-musl-cc.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

MUSL_CC_TARBALL="$tmp/x86_64-linux-musl-cross.tgz"
export MUSL_CC_TARBALL

sh -n steps/0000-fetch-musl-cc.sh
./steps/0000-fetch-musl-cc.sh
