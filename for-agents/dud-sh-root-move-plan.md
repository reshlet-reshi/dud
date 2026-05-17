# dud-sh Root Move Plan

Status: planned

This note records the accepted direction for a later move PR. It does not move
files, change active project policy, or alter the current source layout.

## Direction

The repository remains `dud`. The current `dud-sh` stage-0 work should move to
the repository root for now, because it is the only active project surface.

The later move PR should promote the current `src/dud-sh/` content instead of
adding parallel copies:

- `src/dud-sh/language.md` moves to `language.md`.
- `src/dud-sh/README.md` content folds into root `README.md`.
- `src/dud-sh/AGENTS.md` policy folds into root `AGENTS.md`.
- Active paths change from `src/dud-sh/...` to root-relative paths such as
  `language.md`, `bin/`, `lib/`, `test/`, and `test.py`.

After those moves, remove empty `src/dud-sh/` and `src/` directories from the
working tree. Do not add `.gitkeep` or another placeholder.

## Future Layout Notes

Root `README.md` should continue to describe `docs/` as the intended future
top-level project docs directory, absent until real tracked content exists.

Root `README.md` should also describe `src/` as an intended future
multi-project or source tree, absent until real tracked content exists.

Root `AGENTS.md` should become the single active policy file for current
`dud-sh` work until a future subtree needs its own nearer `AGENTS.md`.

## Research References

Historical research under `for-agents/research/` should remain unchanged. Old
`src/dud-sh/...` paths in research preserve the context that existed when the
research was written.

The later move PR should fix active project and policy references, but should
not rewrite archived research just to chase path churn.
