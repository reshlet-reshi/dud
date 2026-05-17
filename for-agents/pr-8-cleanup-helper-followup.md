# PR 8 Cleanup Helper Follow-Up

Status: draft

PR: https://github.com/reshlet-reshi/dud/pull/8
Closed: 2026-05-17, unmerged
Rejected branch: `codex-cleanup-merged-pr-helper`

## What PR 8 Tried To Do

PR 8 attempted to add the first host-side agent helper:
`src/for-agents/bin/cleanup-merged-pr`.

That path was part of the rejected proposal, not accepted placement policy.

The helper was meant to automate the safe post-merge cleanup workflow after the
owner accepted a PR:

- require a clean worktree, `git`, `gh`, and active GitHub login `reshi-codex`;
- verify the target PR state was `MERGED` and the base branch was `main`;
- read the PR head branch and object ID;
- fast-forward local `main`;
- delete the local PR branch only when it matched the merged PR head;
- delete the remote PR branch only when it still existed and matched the merged
  PR head;
- run `git fetch --prune` and print final status.

During review, the script was split into a small entry point plus a sourced
library, then given local shell documentation and source comments pointing back
to that documentation.

## Why It Was Closed

The owner closed the PR before merge so the repository can settle the policy
shape first. The closing comment said to restart by:

- codifying the `SEE` convention at a higher policy level;
- encoding stricter rules about what belongs in `for-agents`;
- making documentation files referenceable with shorter paths.

## Follow-Up Todo

- Decide and promote the source-reference convention before adding more helper
  scripts. The requested shape is `SEE path#anchor`, where `SEE` is a magic
  marker like `TODO` or `BUG`.
- Define where `SEE` paths are resolved from, and how docs can be referenced
  with short paths while staying unambiguous.
- Treat top-level `for-agents/` as docs-only. Do not put executable helpers,
  shell libraries, tests, generated artifacts, runtime/bootstrap source, or
  local tool-specific configuration there.
- Decide helper-tool placement separately before revisiting `cleanup-merged-pr`.
