# AGENTS.md

These rules apply under `for-agents/`.

## Purpose

This tree holds agent-facing documentation and context: prompts, handoffs,
research reports, workflow docs, decision notes, follow-up notes, and other
material that helps agents understand the project. It is not a runtime,
bootstrap, generated-output, local-tool-configuration, or helper-tooling tree.

Most files here are advisory context. A file under `for-agents/` is binding
only when it says it is binding and is referenced from a reviewed policy
surface such as root `AGENTS.md`, a nearer subtree `AGENTS.md`, a README, or a
durable project doc.

Project policy becomes binding only when promoted into reviewed files such as
root `AGENTS.md`, a nearer subtree `AGENTS.md`, READMEs, or durable project
docs.

## Placement Rules

- Keep prompts, handoffs, research reports, workflow docs, decision notes, and
  follow-up notes under `for-agents/`.
- Do not put executable helper scripts, shell libraries, runtime/bootstrap
  source, tests, generated artifacts, or local tool-specific configuration
  guidance under `for-agents/`.
- Future agent helper tooling needs its own reviewed placement decision before
  adding files.

## Editing Rules

- Preserve historical agent artifacts unless the task explicitly asks to revise
  them.
- Prefer adding a follow-up note or clearly named new artifact over rewriting
  an old prompt/report.
- Do not include secrets, private tokens, credentials, or local machine details
  that are not needed for future agents.
- Keep links relative when pointing inside the repo.
- Keep external citations in ordinary Markdown links.
- If a note records a decision, link to the PR or file where that decision was
  promoted into binding policy.

## Status Labels

Use plain text status near the top of new agent-facing notes when useful:

```text
Status: draft
Status: accepted
Status: superseded by PATH
Status: archived
```

Do not mark research as accepted unless the owner or a merged PR has clearly
accepted it.

## Promotion Rule

Research and handoffs may guide changes, but do not implement broad policy
from them silently. Promote decisions by updating the actual policy surface
through the active workflow in `github-workflow.md`.

When promoting a decision, cite the source artifact and keep the promoted text
shorter and more operational than the research that motivated it.
