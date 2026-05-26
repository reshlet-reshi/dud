# 03-musl-tcc instructions

When changing tracked musl-tcc inputs under this directory, increment
`03-musl-tcc/.stamp`.

Bootstrap smoke tests live under `03-musl-tcc/test`; changing them also requires
incrementing `03-musl-tcc/.stamp`.

Do not update `.stamp` for generated files under `.init/musl-tcc-build`.
