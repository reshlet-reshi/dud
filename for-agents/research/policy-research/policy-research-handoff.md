# Prompt: Research Agent Policy, Markdown, HTML, And Meta-Policy

Status: ready for handoff

## Attached Fileset

I am attaching this uncompressed tar archive:

```text
policy-research-fileset.tar
```

Before doing the research, unpack it and inspect the directory it contains:

```sh
tar -xf policy-research-fileset.tar
cd policy-research-fileset
```

Use `MANIFEST.md` as the canonical map of the fileset. Preserve the labels and
paths from the manifest when discussing local artifacts, so the report can be
traced back to the supplied files.

The handoff prompt is not inside the tar. The tar contains only the research
fileset.

## Purpose

Produce a source-backed research report for the `dud` project owner.

The owner is trying to become more intentional about repository policy. In this
repo, policy is encoded in Markdown files and interpreted by both humans and
coding agents. That creates a meta-policy problem:

- What makes a good agent policy file?
- What makes a good Markdown policy document?
- What makes good policy about writing policy?
- What plain HTML policy should exist if HTML is the main rendered backend for
  reading Markdown?

Critique the attached local artifacts harshly but fairly, then propose a better
policy-management scheme for agentic coding projects.

## Do

- Research current best practices and authoritative guidance for agent policy
  files, including `AGENTS.md`, coding-agent instructions, repository-local
  instruction layering, and agentic programming workflows.
- Research Markdown authoring for durable technical documentation and policy.
- Research plain HTML authoring for readable documents, including semantics,
  accessibility, low-CSS documents, reader-mode/text-browser behavior, and
  generated Markdown-to-HTML output.
- Research policy writing in software projects: scope, force, examples,
  exceptions, amendment flow, duplication, drift control, and testability.
- Critique the `bd-*.md` faux policy documents. Say what is strong, but be
  direct about vagueness, missing scope, weak force, missing examples,
  untestable claims, or vibes posing as rules.
- Critique `BeautifulDocument.html` as plain HTML and as a seed for policy.
  Comment on semantics, accessibility, source readability, markup quality,
  generated-vs-hand-authored tension, and whether it supports the policy claims
  it inspired.
- Compare `snapshots/html-v1-committed.md` and `current/html.md`. Evaluate
  whether v2 is better policy, stricter policy, clearer policy, or merely more
  dogmatic. Pay special attention to generated/transient HTML, links vs app
  controls, image policy, CSS allowlisting, checks, and amendment process.
- Evaluate the current root `AGENTS.md` and `for-agents/research/` precedent as
  examples of policy organization and research preservation.
- Propose a general scheme for managing policy in agentic coding projects. This
  should turn the loose thrust of the `bd-*.md` documents and `html.md` into a
  practical shape for a future `policy.md` or equivalent meta-policy file.

## Do Not

- Do not make a repo patch.
- Do not write final `policy.md`, `markdown.md`, or `html.md`.
- Do not rewrite `AGENTS.md`.
- Do not treat local experiments as binding.
- Do not assume the prettiest document is the best policy.
- Do not collapse all guidance into a single giant policy file without
  discussing tradeoffs.
- Do not ignore the owner's taste for small, direct, readable documents.
- Do not copy substantial third-party text into the report.

## Deliver

Write a source-backed report with ordinary Markdown citations.

Use this structure:

```text
1. Executive summary
2. Sources and method
3. Best practices found
   - agent policy / AGENTS.md
   - Markdown policy documents
   - plain HTML documents
   - policy about policy
4. Artifact critique
   - bd-policy.md
   - bd-design.md
   - bd-code.md
   - BeautifulDocument.html
   - html.md v1 vs v2
   - current AGENTS/research precedent
5. Proposed policy-management scheme
6. Proposed shape for policy.md
7. Decision matrix
8. Recommended next steps
9. Owner decision ballot
10. Sources
```

The proposed `policy.md` shape should be concrete enough for an implementer to
draft later, but it should not be a final file. Address at least:

- what belongs in root `AGENTS.md` vs `policy.md` vs topic policies such as
  `markdown.md` and `html.md`
- how binding and advisory documents should be labeled
- how a policy should state scope, intent, principles, rules, checks,
  exceptions, and amendment flow
- how much duplication with ambient/tool policy is useful
- how to distinguish rules, preferences, examples, and rationale
- how policy should stay readable by humans and useful to agents
- how policy should be tested or reviewed before promotion
- how research artifacts should be cited when policy is promoted

The decision matrix should compare at least three coherent schemes, such as:

```text
A. Minimal root AGENTS plus topic docs
B. Root AGENTS plus meta policy.md plus topic policies
C. Policy bundle with explicit status labels and promotion flow
```

Use different schemes if research suggests better alternatives.

The owner decision ballot should ask the smallest number of high-impact
questions needed to choose a scheme.

## Critique Standard

Be charitable about intent and severe about execution.

For each artifact, ask:

- Can a tired agent follow it?
- Can a new contributor find the rule that matters?
- Does it say when it applies?
- Does it say what to do?
- Does it separate rule from rationale?
- Does it include enough examples or checks?
- Does it duplicate another rule for a real reason?
- Does it create future maintenance burden?
- Does it reduce uncertainty more than it adds ceremony?

## Source Guidance

Use primary or official sources where possible.

Good source categories include:

- official `AGENTS.md` or coding-agent instruction docs
- CommonMark and GitHub Flavored Markdown specs
- HTML, accessibility, and web standards documentation
- respected software documentation and policy-writing guidance
- project documentation from tools that use layered local instructions

If sources disagree, record the disagreement and recommend the conservative
choice.

## Settled Choices For This Handoff

- The attached tar is the fileset for this research pass.
- `MANIFEST.md` is the canonical file map.
- `snapshots/html-v1-committed.md` is the v1 HTML policy baseline.
- `current/html.md` is the v2 HTML policy candidate.
- Files under `experiments/` are examples and sketches, not binding policy.
- The expected deliverable is a report and policy-management proposal, not a
  patch.
