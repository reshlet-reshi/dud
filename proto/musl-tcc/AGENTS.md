# proto/musl-tcc instructions

When changing tracked musl-tcc inputs under this directory, increment
`proto/musl-tcc/.stamp`.

Bootstrap smoke tests live under `proto/musl-tcc/test`; changing them
also requires incrementing `proto/musl-tcc/.stamp`.

Do not update `.stamp` for generated files under the caller-supplied musl-tcc
work directory.
