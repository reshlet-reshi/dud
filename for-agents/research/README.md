# Research

This directory stores agent research passes for `dud`.

Research files are meant to preserve the question asked, the source basis, the
recommendation, and unresolved tradeoffs. They help future agents avoid
repeating context-gathering work.

Research is advisory. A recommendation becomes project policy only after it is
promoted into a reviewed policy or project documentation file.

## Layout

Keep each research pass as a flat prompt/report pair:

```text
research-prompt-0.md
dud-agents-research-report-inline-citations.md
```

Use the next integer after the largest existing `research-prompt-N.md` file.
Keep the prompt or handoff next to the final report. Prefer report filenames
that describe the topic and citation style, for example
`dud-agents-research-report-inline-citations.md`.
