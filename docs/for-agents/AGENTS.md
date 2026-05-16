# AGENTS.md

These rules apply under `docs/for-agents/`.

## Purpose

This tree holds agent-facing context: prompts, handoffs, research reports,
decision notes, and other material that helps agents understand the project.
It is not automatically binding project policy.

Project policy becomes binding only when promoted into reviewed files such as
root `AGENTS.md`, a nearer subtree `AGENTS.md`, READMEs, or durable project
docs.

## Editing Rules

- Preserve historical agent artifacts unless the task explicitly asks to revise
  them.
- Prefer adding a follow-up note or new research directory over rewriting an
  old prompt/report.
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
from them silently. Promote decisions in small PRs that update the actual
policy surface.

When promoting a decision, cite the source artifact and keep the promoted text
shorter and more operational than the research that motivated it.
