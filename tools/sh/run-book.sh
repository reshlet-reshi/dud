# shellcheck shell=sh

set -eu

fail() {
  for line do
    printf '%s\n' "run-book.sh: $line" >&2
  done
  exit 1
}

if [ "$#" -lt 3 ]; then
  fail \
    "missing required arguments." \
    "usage: sh tools/sh/run-book.sh path/to/cd path/to/fence-cat.awk path/to/runbook.md [args...]"
fi

run_dir=$1
extractor=$2
runbook=$3
shift 3

if [ ! -d "$run_dir" ]; then
  fail "missing run directory: $run_dir"
fi
if ! cd -P "$run_dir" 2>/dev/null; then
  fail "could not cd to run directory: $run_dir"
fi

if [ ! -f "$extractor" ]; then
  fail "missing awk extractor: $extractor"
fi
if [ ! -r "$extractor" ]; then
  fail "unreadable awk extractor: $extractor"
fi

if [ ! -f "$runbook" ]; then
  fail "missing runbook: $runbook"
fi
if [ ! -r "$runbook" ]; then
  fail "unreadable runbook: $runbook"
fi

tmp_dir=

# shellcheck disable=SC2329 # invoked by the EXIT trap
cleanup_tmp() {
  if [ -n "$tmp_dir" ]; then
    rm -rf "$tmp_dir" || :
  fi
}
trap 'cleanup_tmp' EXIT

tmp=

old_umask=$(umask)
umask 077
i=0
while [ "$i" -lt 100 ]; do
  candidate="/tmp/dud-run-book.$$.$i"
  if mkdir "$candidate" 2>/dev/null; then
    tmp_dir=$candidate
    tmp=$tmp_dir/script.sh
    break
  fi
  i=$((i + 1))
done
umask "$old_umask"

if [ -z "$tmp_dir" ]; then
  fail "could not create a private temp directory under /tmp"
fi

if ! awk -v token=sh -f "$extractor" "$runbook" >"$tmp"; then
  fail "could not extract shell from runbook: $runbook"
fi

if sh "$tmp" "$@"; then
  status=0
else
  status=$?
fi

exit "$status"
