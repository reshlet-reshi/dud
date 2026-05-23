#!/bin/sh
set -eu

printf 'curl\n' >>"$curl_calls"

while [ "$#" -gt 0 ]; do
    case "$1" in
        -o)
            shift
            : >"$1"
            ;;
    esac
    shift
done
