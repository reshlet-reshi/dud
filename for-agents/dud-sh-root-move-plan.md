# dud-sh Root Move Plan

Status: implemented

This note records the accepted direction implemented by the root move PR.

## Direction

The repository remains `dud`. The current `dud-sh` stage-0 work moved to the
repository root for now, because it is the only active project surface.

The move promoted the previous `src/dud-sh/` content instead of adding
parallel copies:

- `src/dud-sh/language.md` moved to `language.md`.
- `src/dud-sh/README.md` content folded into root `README.md`.
- `src/dud-sh/AGENTS.md` policy folded into root `AGENTS.md`.
- Active paths changed from `src/dud-sh/...` to root-relative paths such as
  `language.md`, `bin/`, `lib/`, `test/`, and `test.py`.

After those moves, empty `src/dud-sh/` and `src/` directories were removed
from the working tree. No `.gitkeep` or other placeholder was added.

## Future Layout Notes

Root `README.md` continues to describe `docs/` as the intended future
top-level project docs directory, absent until real tracked content exists.

Root `README.md` also describes `src/` as an intended future
multi-project or source tree, absent until real tracked content exists.

Root `AGENTS.md` is the single active policy file for current `dud-sh` work
until a future subtree needs its own nearer `AGENTS.md`.

## Research References

Historical research under `for-agents/research/` should remain unchanged. Old
`src/dud-sh/...` paths in research preserve the context that existed when the
research was written.

The move PR fixed active project and policy references, but did not rewrite
archived research just to chase path churn.
