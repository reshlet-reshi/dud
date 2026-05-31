# 99-experiments/musl-tcc instructions

When changing tracked musl-tcc inputs under this directory, increment
`99-experiments/musl-tcc/.stamp`.

Bootstrap smoke tests live under `99-experiments/musl-tcc/test`; changing them
also requires incrementing `99-experiments/musl-tcc/.stamp`.

Do not update `.stamp` for generated files under the caller-supplied musl-tcc
work directory.
