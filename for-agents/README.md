# Agent-Facing Docs

This directory stores context intended mainly for agents working on `dud`.
Examples include research prompts, handoffs, investigation reports, and notes
that explain why a future policy or implementation change might exist.

Files here are advisory unless a decision is promoted into a reviewed policy
surface such as `AGENTS.md`, a README, or a durable project doc.

## Editor Icon

Material Icon Theme gives `.agents` and `agents` folders its robot folder icon
by default. This directory is named `for-agents` for clarity, so editors need a
local folder association to give it the same treatment:

```json
{
  "material-icon-theme.folders.associations": {
    "for-agents": "robot"
  }
}
```

Keep that setting in local VS Code workspace or user settings. This repository
ignores `.vscode/` so editor preferences do not become project policy.

## Layout

```text
github-workflow.md  binding branch, PR, and cleanup workflow for agents
pr-8-cleanup-helper-followup.md
                    follow-up notes from the closed cleanup-helper PR
research/        research prompts, reports, and source-backed investigations
```

Use `for-agents/AGENTS.md` for local editing rules.
