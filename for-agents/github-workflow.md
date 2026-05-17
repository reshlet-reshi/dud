# GitHub Workflow

Status: temporary working-branch mode

This is the binding workflow for Codex-authored work while this temporary mode
is active. The previous immediate commit-and-PR workflow is archived in
`github-pr-workflow-archived.md` and is not binding.

## Current Mode

- Do not open pull requests by default.
- Do not turn each small local step into its own commit-and-PR cycle.
- Work on a non-`main` working branch where larger local edits and checkpoint
  commits are allowed.
- Later, when the owner asks, clean the working branch into a stream of small
  reviewed PRs, preferably one intentional commit per PR.

## Identity

- Use the `reshi-codex` GitHub account for commits, pushes, and pull requests.
- Create future pull requests with `gh`, not the GitHub connector, so GitHub
  records the PR author as `reshi-codex`.
- If `gh auth status` does not show `reshi-codex` as the active account, stop
  before pushing or opening a PR.

## Starting Work

- Inspect the current branch and `git status --short --branch` before editing.
- Never make ordinary working edits directly on `main`.
- If on `main`, create or switch to a working branch before editing.
- If already on a working branch, keep using it unless the owner asks for a
  different branch.
- Work with existing local changes. Do not reset, discard, or overwrite user
  changes unless the owner explicitly asks.

## Local Work And Commits

- Larger local edits are allowed while this mode is active.
- Checkpoint commits are allowed when they preserve useful state, even if they
  are not final PR-shaped commits.
- Commit messages may be practical and local, but should still describe the
  checkpoint honestly.
- Stage only files that belong to the current checkpoint.
- Run the smallest relevant validation at useful boundaries. If no check exists
  or a check is intentionally skipped, say so.
- Do not push, open a PR, or request reviewers unless the owner explicitly asks.

## Later PR Extraction

When the owner asks to turn local work into PRs:

1. Start from an up-to-date `main`.
2. Create a fresh PR branch for one coherent slice of the working branch.
3. Bring over only that slice.
4. Squash or amend it to one intentional commit unless the owner asks for a
   different shape.
5. Run the smallest relevant validation for that slice.
6. Open a draft PR with `gh pr create`.
7. Repeat for the next coherent slice.

## After Owner Acceptance

Do not clean up a PR branch until the PR is safely merged.

1. Verify the PR state is `MERGED`, for example with `gh pr view`.
2. Switch to `main`.
3. Fast-forward local `main` with `git pull --ff-only`.
4. Delete the local PR branch.
5. Check whether the remote PR branch still exists.
6. If the owner already deleted the remote branch on GitHub, do nothing
   remotely.
7. If the remote branch still exists after the PR is verified merged, delete it.
8. Run `git fetch --prune`.
9. Confirm `git status --short --branch` is clean and only expected branches
   remain.

## Important Boundaries

- Never merge directly to `main`.
- Never delete a branch unless the corresponding PR is verified merged or the
  owner explicitly asks for that branch deletion.
- Never use a force push unless the owner explicitly asks for that exact branch.
- Do not silently change public API/ABI, emitted ABI, language semantics,
  conformance expectations, dependencies, or legal files.
