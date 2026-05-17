# Agent-Facing Docs

This directory stores documentation and context intended mainly for agents
working on `dud`. Examples include research prompts, handoffs, investigation
reports, workflow docs, and notes that explain why a future policy or
implementation change might exist.

This is a docs-only tree. Do not place executable helpers, runtime/bootstrap
source, generated artifacts, tests, or local tool-specific configuration here.
Files here are advisory unless they explicitly say they are binding and are
referenced from a reviewed policy surface such as `AGENTS.md`, a README, or a
durable project doc.

## Layout

```text
github-workflow.md  binding branch, PR, and cleanup workflow for agents
pr-8-cleanup-helper-followup.md
                    follow-up notes from the closed cleanup-helper PR
research/        source-backed investigations and seed artifacts
```

Use `for-agents/AGENTS.md` for local editing rules.
