# shellcheck shell=sh

set -eu

fail() {
  for line do
    printf '%s\n' "help.sh: $line" >&2
  done
  exit 1
}

script_path=$0

if [ -L "$script_path" ]; then
  fail \
    "Script-path is a symbolic link." \
    "Directory-of script-path is ambiguous." \
    "Please use a direct path." \
    "script-path was: $script_path"
fi

case $script_path in
  */*) ;;
  *)
    fail \
      "Script-path does not contain a slash." \
      "Directory-of script-path is ambiguous." \
      "Please use a direct path" \
      "script-path was: $script_path"
    ;;
esac

script_dir=${script_path%/*}
if [ -z "$script_dir" ]; then
  script_dir=/
fi
case $script_dir in
  -*) script_dir=./$script_dir ;;
esac

if ! cd -P "$script_dir" 2>/dev/null; then
  fail "could not cd to script directory: $script_dir"
fi

runner=tools/sh/run-book.sh
if [ ! -f "$runner" ]; then
  fail "missing adjacent shell runner: $(pwd -P)/$runner"
fi
if [ ! -r "$runner" ]; then
  fail "unreadable adjacent shell runner: $(pwd -P)/$runner"
fi

extractor=tools/awk/fence-cat.awk
if [ ! -f "$extractor" ]; then
  fail "missing adjacent awk extractor: $(pwd -P)/$extractor"
fi
if [ ! -r "$extractor" ]; then
  fail "unreadable adjacent awk extractor: $(pwd -P)/$extractor"
fi

runbook=help.md
if [ ! -f "$runbook" ]; then
  fail "missing adjacent help.md: $(pwd -P)/$runbook"
fi
if [ ! -r "$runbook" ]; then
  fail "unreadable adjacent help.md: $(pwd -P)/$runbook"
fi

if sh "./$runner" . "$extractor" "$runbook" "$@"; then
  status=0
else
  status=$?
fi

exit "$status"
