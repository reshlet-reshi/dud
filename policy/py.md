# Python Policy

Status: Experimental

This policy applies to tracked Python in this repository.

It also applies to executable Python inside policy runbooks.

Tracked Python edits must pass mypy before they are staged or committed.

Tracked Python edits must pass Ruff before they are staged or committed.

Executable runbook Python must pass mypy before project execution.

Executable runbook Python must pass Ruff before project execution.

Bootstrap commands are exempt when they install the checking tools.

That exemption ends once the vendored tools are available.

## Tools

Mypy is the type checker.

Ruff is the Python linter.

Pinned tool requirements live in `vendor/python-tools/requirements.txt`.

Vendored wheels will live in `vendor/python-tools/wheels/`.

The wheelhouse is present.

Ordinary checks should use `tools/check-python.sh`.

## Required Checks

Run mypy with the repository config.

Use `python3 -m mypy --config-file mypy.ini`.

Run Ruff with the repository config.

Use `python3 -m ruff check --config ruff.toml tools`.

After the wheelhouse exists, ordinary checks must not require network access.

Use `tools/check-python.sh` for the ordinary repository check.

## Bootstrap Boundary

The first bootstrap step may use network or system tooling.

The bootstrap step may create `.tmp/python-tools-venv`.

After bootstrap, checks should use only vendored wheels.

Helper scripts should install from `vendor/python-tools/wheels/`.

Helper scripts should not download packages during ordinary checks.
