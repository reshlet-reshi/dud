# AGENTS.md

These rules apply under `for-agents/research/`.

## Purpose

Research files hold source-backed investigations for later project decisions.
They are evidence and reasoning, not binding policy by themselves.

## File Shape

Create one prompt/report pair per research pass directly under
`for-agents/research/`:

```text
research-prompt-N.md
short-topic-report-inline-citations.md
```

Use the next integer after the largest existing `research-prompt-N.md` file.
Keep the prompt/handoff and final report together as sibling files.

## Report Rules

- Start reports with enough context for a future agent to understand the
  question without reading the whole chat.
- Separate assumptions, recommendations, open questions, and sources.
- Use ordinary inline Markdown links for citations.
- Prefer primary sources for standards, licenses, executable formats,
  instruction encodings, syscall numbers, and tool behavior.
- If sources disagree, record the disagreement and recommend the conservative
  choice.
- Do not copy substantial third-party text or generated code into reports.

## Follow-Up Rules

Treat existing research as historical. If a report needs a material update,
prefer a new research pass or an addendum file that links to the original.
Small typo, link, or formatting repairs are fine when they do not alter the
recorded conclusion.

When research is accepted, promote only the operational decision into the
appropriate policy/doc file and link back to the research source.
