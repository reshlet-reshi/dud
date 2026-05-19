#!/bin/sh
set -eu

if [ "$#" -ne 0 ]; then
  printf '%s\n' 'help.sh does not accept commands yet.' >&2
  printf '%s\n' 'Run ./help.sh with no arguments.' >&2
  exit 2
fi

printf '%s\n' "418 I'm a teapot"
