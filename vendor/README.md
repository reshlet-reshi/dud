# Vendor

Vendored third-party artifacts live under `vendor/`.

`python-tools/` contains the pinned Python quality-tool wheelhouse.

The wheelhouse supports offline installation for mypy and Ruff.

Ordinary checks should use `tools/check-python.sh`.

Do not place local virtual environments under `vendor/`.

Use `.tmp/` for local tool environments and caches.

