# AGENTS.md

Captured artifact notice: this file is preserved as research input under
`for-agents/research/policy-research/current/`. It is not live repository
policy. Follow the live `AGENTS.md` files outside this captured tree.

This repository is `dud`.

## Ambient Policy Duplicates

Some rules below intentionally duplicate ambient session, tool, and sandbox
policy so this repository has a durable local reminder of them. These local
duplicates are not an attempt to disable, replace, or hide ambient policy.

Known duplicated ambient rules in this file include: work with user changes
instead of reverting them; avoid destructive git commands unless requested;
prefer `rg`; use `apply_patch` for manual edits; keep edits scoped and follow
existing patterns; default to ASCII; respect writable-root and sandbox limits;
treat shell network access as restricted; request escalation with a brief
justification when sandboxing or GUI use requires it; and keep persistent
approval rules narrowly scoped.

## Workflow

- Inspect the current branch and `git status` before editing repository files.
- If on `main`, create or ask for an agent branch before changing repository
  files.
- Read this file and any nearer `AGENTS.md` before editing under a subtree.
- Keep local changes understandable. While workbench mode is active, larger
  local edits and checkpoint commits are allowed.
- Avoid touching GitHub while in workbench mode. Do not push, pull, fetch,
  open or update PRs/issues, request reviewers, or use `gh` or the GitHub
  connector unless the owner explicitly asks.

## Workspace And Editing Constraints

- Filesystem writes are allowed in the workspace and writable roots, including
  `/tmp`, subject to the active sandbox.
- Do not revert user changes unless explicitly requested.
- Do not use destructive commands such as `git reset --hard` or
  `git checkout --` unless clearly requested.
- Prefer `rg` or `rg --files` for searching.
- Use `apply_patch` for manual file edits.
- Keep edits scoped and follow existing project patterns.
- Use ASCII by default when editing or creating files unless there is a clear
  reason otherwise.

## Local Work Areas

- In-progress untracked experiments go under repository root `.stash/`.
- Transient scratch, generated previews, and test temporaries that are safe to
  delete at any time go under repository root `.tmp/`.
- Tools and tests should create these directories before writing to them.

## Human-Facing Generated Documents

- When generating HTML or other prose documents for the owner to read, prefer
  screen-reader and reader-mode friendly structure.
- Use semantic article-style markup and real paragraphs for prose summaries.
  Avoid layouts that are mostly cards, headings, or list-only sections when
  the document is meant to be read continuously.
- For generated side-by-side or otherwise visual diffs, include a first-class
  linear reader view in ordinary visible prose or semantic blocks.
- Do not rely on a browser-specific reading-mode fallback attribute. Make the
  reader-friendly version normal document content that reading mode can
  extract.
- Redundant visual-only diff views may be marked `aria-hidden="true"` only
  when an equivalent reader-friendly version is present and the hidden region
  contains no focusable or interactive controls.
- Label additions, removals, and context in text. Do not rely on color alone
  to convey diff meaning.

## Tool And Approval Policy

- Network access is restricted in the shell environment.
- If an important command fails because of sandboxing or likely network
  restriction, request escalation and retry with justification.
- Opening GUI apps, including Chrome, requires explicit escalation.
- Escalation requests must briefly explain the action and may include a
  narrowly scoped reusable prefix rule when appropriate.
- Do not request overly broad persistent approval rules.
