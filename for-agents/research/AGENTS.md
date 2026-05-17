# AGENTS.md

These rules apply under `for-agents/research/`.

## Purpose

Files here preserve source-backed investigations and seed artifacts for later
project decisions. They are evidence and reasoning, not binding policy by
themselves.

## Naming

There is no standing research naming convention yet. Name future files for
their actual role and topic. Do not create a numbered convention until there is
an actual repeated pattern to abstract.

The current `AGENTS-seed-*.md` names describe the historical two-stage seed
that produced the initial `AGENTS.md` policy:

```text
AGENTS-seed-0.md  initial handoff/prompt
AGENTS-seed-1.md  source-backed report
```

Do not extend this sequence unless adding another artifact to that same AGENTS
seed chain.

## Artifact Rules

- Start source-backed artifacts with enough context for a future agent to
  understand the question without reading the whole chat.
- Separate assumptions, recommendations, open questions, and sources.
- Use ordinary inline Markdown links for citations.
- Prefer primary sources for standards, licenses, executable formats,
  instruction encodings, syscall numbers, and tool behavior.
- If sources disagree, record the disagreement and recommend the conservative
  choice.
- Do not copy substantial third-party text or generated code into reports.

## Follow-Up Rules

Treat existing artifacts as historical. If an artifact needs a material update,
prefer a clearly named addendum or new artifact that links to the original.
Small typo, link, or formatting repairs are fine when they do not alter the
recorded conclusion.

When an artifact is accepted, promote only the operational decision into the
appropriate policy/doc file and link back to the source artifact.
