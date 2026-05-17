# Archived GitHub PR Workflow

Status: archived

This file records the previous immediate commit-and-PR workflow. It is not
binding. The current binding workflow lives in `github-workflow.md`.

## Historical Content

This was the binding workflow for Codex-authored branches, pull requests, and
post-merge cleanup in this repository.

## Identity

- Use the `reshi-codex` GitHub account for commits, pushes, and pull requests.
- Create pull requests with `gh`, not the GitHub connector, so GitHub records
  the PR author as `reshi-codex`.
- If `gh auth status` does not show `reshi-codex` as the active account, stop
  before pushing or opening a PR.

## Starting Work

- Begin from a clean `main` that is up to date with `origin/main`.
- Create a branch named `codex-<short-description>`.
- Keep each PR small and coherent.
- Before staging, inspect `git status --short --branch` and the diff.
- Stage only files that belong to the current PR.

## Commit And PR

- Use one intentional commit unless checkpointing is explicitly requested.
- Commit as `reshi-codex`.
- Run the smallest relevant validation before committing.
- Open a draft PR with `gh pr create`.
- Include a concise PR body with:
  - summary
  - what changed
  - validation
  - notes or risks

## After Owner Acceptance

Do not clean up a branch until the PR is safely merged.

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

- Never delete a branch unless the corresponding PR is verified merged.
- Never use a force push for the normal PR flow.
- Never merge directly to `main`.
- Do not use the GitHub connector to create PRs while it is authenticated as
  the owner account.
