#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/.." && pwd)"

venv_dir="${repo_root}/.tmp/python-tools-venv"
wheel_dir="${repo_root}/vendor/python-tools/wheels"
requirements="${repo_root}/vendor/python-tools/requirements.txt"

if ! command -v python3 >/dev/null 2>&1; then
  printf '%s\n' 'error: python3 is required' >&2
  exit 1
fi

if [ ! -d "${wheel_dir}" ]; then
  printf 'error: missing wheelhouse: %s\n' "${wheel_dir}" >&2
  exit 1
fi

if [ ! -f "${requirements}" ]; then
  printf 'error: missing requirements file: %s\n' "${requirements}" >&2
  exit 1
fi

if [ ! -x "${venv_dir}/bin/python" ]; then
  python3 -m venv "${venv_dir}"
fi

"${venv_dir}/bin/python" -m pip install \
  --no-index \
  --find-links "${wheel_dir}" \
  -r "${requirements}"

cd "${repo_root}"

"${venv_dir}/bin/python" -m mypy --config-file mypy.ini
"${venv_dir}/bin/python" -m ruff check --config ruff.toml tools
