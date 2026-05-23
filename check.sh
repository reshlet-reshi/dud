#!/bin/sh
set -eu

tmp=$(mktemp -d "${TMPDIR:-/tmp}/dud-musl-cc.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

path_to_curl=./lib/mock-curl.sh

MUSL_CC_TARBALL="$tmp/x86_64-linux-musl-cross.tgz"
export MUSL_CC_TARBALL
curl_calls="$tmp/curl-calls"
export curl_calls

sh -n steps/0000-fetch-musl-cc.sh
./steps/0000-fetch-musl-cc.sh "$path_to_curl"
test "$(wc -l <"$curl_calls")" -eq 1
test -e "$MUSL_CC_TARBALL"

./steps/0000-fetch-musl-cc.sh "$path_to_curl"
test "$(wc -l <"$curl_calls")" -eq 1
