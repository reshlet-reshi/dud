# dud

`dud` is a bootstrap toolchain project. The first subproject is `dud-sh`,
a deliberately tiny `/bin/sh`-compatible command language for early bootstrap
work.

Current slogan:

```text
Shell temporarily hosts dsh.
Later dsh runs the same files itself.
```

The first milestone is the path from hosted `dud-sh`-compatible scripts to
`patch-elf`, then `patch-elf-modular`, and later a native `dud-sh` kernel path.
No implementation code is committed yet.

## Layout

```text
.bin/              intended future generated native artifact directory
.tmp/              intended future scratch and test temporary directory
docs/              project-level bootstrap and design notes
src/dud-sh/        first bootstrap subproject
```

See `docs/bootstrap-graph.md` and `src/dud-sh/README.md` for the current
scaffold.
