#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

shellcheck_bin="${repo_root}/vendor/shellcheck/linux-x86_64/shellcheck"

if [ ! -x "${shellcheck_bin}" ]; then
  printf 'error: missing executable ShellCheck binary: %s\n' "${shellcheck_bin}" >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  printf '%s\n' 'error: git is required' >&2
  exit 1
fi

is_shell_shebang() {
  local path="$1"
  local first_line
  local prefix

  prefix="$(LC_ALL=C head -c 2 -- "${path}" 2>/dev/null || true)"
  [ "${prefix}" = '#!' ] || return 1

  IFS= read -r first_line < "${path}" || return 1
  [[ "${first_line}" =~ ^#!.*(^|/|[[:space:]])(sh|bash|dash|ksh)([[:space:]]|$) ]]
}

cd "${repo_root}"

shell_files=()
while IFS= read -r -d '' path; do
  if [[ "${path}" == *.sh ]] || { [[ -x "${path}" ]] && is_shell_shebang "${path}"; }; then
    shell_files+=("${path}")
  fi
done < <(git ls-files -z)

if [ "${#shell_files[@]}" -eq 0 ]; then
  printf '%s\n' 'no tracked shell files found'
  exit 0
fi

"${shellcheck_bin}" "${shell_files[@]}"
