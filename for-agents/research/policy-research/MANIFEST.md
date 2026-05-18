# Policy Research Fileset

This fileset supports a deep research prompt about agent policy, Markdown
policy, plain HTML documents, and meta-policy for the `dud` repository.

The handoff prompt is not included in this fileset. The owner will provide the
prompt separately and attach the tar archive that contains this directory.

## Layout

```text
policy-research-fileset/
  MANIFEST.md
  current/
  snapshots/
  experiments/
```

## Exact Archive Inventory

This inventory is expected to match:

```sh
tar -tf policy-research-fileset.tar
```

```text
policy-research-fileset/
policy-research-fileset/current/
policy-research-fileset/current/README.md
policy-research-fileset/current/AGENTS.md
policy-research-fileset/current/for-agents/
policy-research-fileset/current/for-agents/README.md
policy-research-fileset/current/for-agents/AGENTS.md
policy-research-fileset/current/for-agents/research/
policy-research-fileset/current/for-agents/research/README.md
policy-research-fileset/current/for-agents/research/AGENTS-seed-1.md
policy-research-fileset/current/for-agents/research/AGENTS.md
policy-research-fileset/current/for-agents/research/AGENTS-seed-0.md
policy-research-fileset/current/html.md
policy-research-fileset/current/language.md
policy-research-fileset/snapshots/
policy-research-fileset/snapshots/html-v1-committed.md
policy-research-fileset/experiments/
policy-research-fileset/experiments/bd/
policy-research-fileset/experiments/bd/bd-code.md
policy-research-fileset/experiments/bd/BeautifulDocument.html
policy-research-fileset/experiments/bd/bd-policy.md
policy-research-fileset/experiments/bd/bd-design.md
policy-research-fileset/experiments/prompts/
policy-research-fileset/experiments/prompts/ideas/
policy-research-fileset/experiments/prompts/ideas/policy-summary/
policy-research-fileset/experiments/prompts/ideas/policy-summary/policy-summary-example.html
policy-research-fileset/experiments/prompts/show-md-as-html-prompt.md
policy-research-fileset/experiments/prompts/repo-diff-prompt.md
policy-research-fileset/MANIFEST.md
```

## Current Repository Context

These files are copied from the current working tree.

```text
current/AGENTS.md
  Current root repository agent policy. This is a binding policy surface in the
  repository.

current/README.md
  Current project overview and bootstrap path context.

current/language.md
  Current `dud-sh` language policy and source profile.

current/html.md
  Current uncommitted v2 HTML Document Policy. Treat this as the owner's current
  attempt to make the HTML policy stricter and more policy-like.

current/for-agents/AGENTS.md
current/for-agents/README.md
  Current rules and context for the advisory agent-facing documentation tree.

current/for-agents/research/AGENTS.md
current/for-agents/research/README.md
  Current rules and context for source-backed research artifacts.

current/for-agents/research/AGENTS-seed-0.md
current/for-agents/research/AGENTS-seed-1.md
  Prior deep-research handoff and report. Use these as structural precedent, not
  as the topic under review.
```

## Snapshots

```text
snapshots/html-v1-committed.md
  Snapshot of the committed baseline HTML policy from:
  git show HEAD:html.md
```

## Local Experiments

These files came from `.stash/`, which is local scratch/experiment space. They
are not binding policy.

```text
experiments/bd/bd-policy.md
experiments/bd/bd-design.md
experiments/bd/bd-code.md
  Faux "Beautiful Document" policy experiments. These are intentionally loose
  and gestural; critique their usefulness as policy.

experiments/bd/BeautifulDocument.html
  Hand-authored example HTML document used as an aesthetic and policy seed.

experiments/prompts/show-md-as-html-prompt.md
experiments/prompts/repo-diff-prompt.md
  Local prompt experiments involving Markdown-to-HTML and reader-friendly HTML
  output.

experiments/prompts/ideas/policy-summary/policy-summary-example.html
  Local example of a generated policy-summary HTML document.
```

## Notes For Research

Use `current/html.md` as the v2 HTML policy and
`snapshots/html-v1-committed.md` as the v1 baseline.

Root `AGENTS.md` and nearer `AGENTS.md` files are current policy surfaces.
Files under `experiments/` are examples and sketches only.
