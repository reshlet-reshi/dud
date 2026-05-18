# AGENTS.md

This repository is `dud`.

Status: Binding

## Purpose

This root file is the small operational entrypoint for agents. Keep broad
research, drafts, and policy experiments out of this file unless the owner
explicitly promotes them into binding policy.

The current policy-research pivot lives under
`for-agents/research/policy-research/`. That directory is advisory research
context unless a live policy surface explicitly promotes something from it.

## Workflow

- Inspect the current branch and `git status` before editing repository files.
- If on `main`, create or ask for an agent branch before changing repository
  files.
- Read this file and any nearer `AGENTS.md` before editing under a subtree.
- Keep edits scoped, understandable, and consistent with nearby files.
- Do not revert user changes unless explicitly requested.
- Avoid destructive git commands unless clearly requested.
- Avoid GitHub operations unless the owner explicitly asks.

## Work Areas

- In-progress untracked experiments go under repository root `.stash/`.
- Transient scratch and test temporaries go under repository root `.tmp/`.
- Files promoted out of `.stash/` must be reviewed as ordinary repo content.

## Tools

- Prefer `rg` or `rg --files` for searching.
- Use `apply_patch` for manual file edits.
- Use ASCII by default unless the file already needs another character set.
- Network access is restricted in the shell environment.
- Request escalation when sandboxing, network access, GUI use, or approval
  policy requires it.
