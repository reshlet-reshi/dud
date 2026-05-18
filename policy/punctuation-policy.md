<!-- doc-profile: TYPE=policy-runbook, VER=v0.x -->

# Punctuation Policy Runbook

Status: Experimental

This policy is a tracked runbook draft for the meta-policy research report.

It is not binding project policy yet.

It defines punctuation roles for deterministic cleanup reports.

## Document Profile

The first source line is the document profile marker.

The marker identifies this file as a policy runbook.

`TYPE=policy-runbook` means tooling should treat this file as a runbook.

`VER` is a machine-friendly profile version token.

The `VER` value must match `v<major>.<minor>` or `v<major>.x`.

Examples include `v0.1` and `v0.x`.

The marker tells tooling which runbook profile applies.

## Scope

The policy applies to prose-profile Markdown documents.

The prose profile allows headings, one-line paragraphs, and one-line bullets.

It also allows nested bullets, citation blocks, inline code, and links.

The prose profile forbids soft-wrapped paragraphs and list items.

The policy ignores punctuation inside protected spans.

Protected spans include inline code, paths, link targets, URLs, and file names.

The preferred maximum prose sentence length is 79 visible characters.

Visible text means rendered-ish text.

Markdown formatting markers are ignored.

Markdown link targets are ignored.

Markdown link labels are counted because readers see them.

## Source Newlines

Prose paragraphs may not contain internal single line breaks.

Prose list items may not contain internal single line breaks.

The only allowed prose paragraph separator is exact token `\n\n`.

A physical newline in prose is structural syntax, not a wrapping opportunity.

Long prose must be rewritten, split, listed, or sectioned.

Long prose must not be hidden by source word wrapping.

One-line bullets are allowed.

Nested one-line bullets are allowed.

Soft-wrapped list item continuations are not allowed.

If a list item needs continuation text, make that continuation a nested bullet.

If a nested bullet is not appropriate, restructure the section.

## Periods

`.` ends a Markdown paragraph sentence.

When a prose sentence is split, the result should normally be new paragraphs.

The result should not be soft-wrapped source lines.

Periods inside protected spans are not sentence endings for this policy.

## Colons

`:` introduces structured material.

A long sentence with a prose colon should usually become structure.

Extract the lead-in into a heading or short paragraph.

Move the introduced material into paragraphs or a Markdown list.

Do not use a colon to hide a long list or multi-clause argument.

## Semicolons

`;` separates sentence-level clauses.

In long prose, semicolon clauses should become separate sentences.

They may also become separate paragraphs or Markdown list items.

Semicolons are not grammar errors by themselves.

They signal that a long sentence probably has several sentence-level thoughts.

## Commas

`,` separates list elements.

In long prose, commas should either separate true list items.

Otherwise, rewrite the prose into shorter sentences.

If commas join clauses instead, treat that as a category error.

Long comma-only sentences should be reviewed first for list conversion.

If no true list is present, split or rewrite by hand.

## Links

Links should not live inside ordinary prose sentences.

Citations should be moved into a citation block.

The citation block should use a `See` heading.

The `See` heading should be one level below the current parent heading.

The `See` heading should not contain a colon.

The `See` heading should be followed by one Markdown link per bullet.

The heading structure performs the introduction.

Do not write `See:` as a prose sentence prefix.

## Not-Prose Sections

Not-prose material is allowed only in a dedicated not-prose section.

Not-prose material means fenced code blocks, Markdown tables, and raw HTML.

Every not-prose section needs a marker comment immediately before its heading.

The marker includes a `TYPE` value.

The marker may include a `WHY` value.

The not-prose section heading must be one level below its parent heading.

Allowed `TYPE` values are `code-example`, `code-runme`, `table`, and `html`.

`code-example` is illustrative code that explains policy intent.

`code-runme` is executable code that a generic runner may execute.

`table` is Markdown table material.

`html` is raw HTML material.

The `WHY` value is an arbitrary but machine-friendly reason token.

The `WHY` token may contain only ASCII letters, digits, underscores, and hyphens.

The policy validates the shape of `WHY`, not its vocabulary.

`WHY` is required for `code-example`, `table`, and `html`.

`WHY` is optional for `code-runme`.

`code-runme` sections are identified by heading and later rule bindings.

Use a prose-only summary near a not-prose section when readers need context.

The summary should make sense without parsing the not-prose block.

## Deterministic Finding Categories

The reporter should classify findings into these categories:

* Long no-delimiter sentence
* Long comma-only sentence
* Long colon sentence
* Long semicolon sentence
* Mixed delimiter sentence
* Inline prose link
* Old `See:` citation paragraph
* Soft-wrapped prose paragraph
* Multiline list item
* Unmarked fenced code block
* Unmarked Markdown table
* Unmarked raw HTML block
* Invalid `not-prose` marker
* `not-prose` marker not immediately followed by a heading
* `not-prose` heading not one level below its parent heading

Reporter findings are suggestions only.

They should not be auto-applied without human review.
