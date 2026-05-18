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

## Runner Contract

`tools/run-policy.py` validates the document profile marker.

The runner executes only marked `code-runme` sections.

Runnable policy code must define `runbook_main(context)`.

The runner provides paths and mode through `context`.

The runner contains plumbing only.

Punctuation rule logic belongs in this runbook.

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

## Rule Inventory

The rule inventory is the source of truth for categories and repairs.

Each subsection heading is the Rule ID.

The `Category` field is the report category.

### punct-long-no-delimiter

* Category: Long no-delimiter sentence
* Required behavior: Long prose needs punctuation or restructuring.
* Check: Flag prose over 79 visible chars with no `:`, `;`, or `,`.
* Suggested repair: Rewrite by hand into multiple shorter sentences.
* Known false positives: Long literal labels may be intentional.
* Known false negatives: Protected spans may hide reader-visible complexity.

### punct-long-comma-only

* Category: Long comma-only sentence
* Required behavior: Commas in long prose should separate true list items.
* Check: Flag prose over 79 visible chars with `,` but no `:` or `;`.
* Suggested repair: Convert true comma lists to bullets.
* Known false positives: Appositives may look like lists.
* Known false negatives: Lists split across short sentences may escape review.

### punct-long-colon

* Category: Long colon sentence
* Required behavior: Colons in long prose should introduce structure.
* Check: Flag prose over 79 visible chars with `:` and no `;` or `,`.
* Suggested repair: Extract the lead-in into structure.
* Known false positives: Short labels before prose may be acceptable.
* Known false negatives: Colon-like meaning can appear without `:`.

### punct-long-semicolon

* Category: Long semicolon sentence
* Required behavior: Semicolons in long prose should split clauses.
* Check: Flag prose over 79 visible chars with `;` and no `:` or `,`.
* Suggested repair: Split clauses into sentences, paragraphs, or bullets.
* Known false positives: Formal lists may use semicolons intentionally.
* Known false negatives: Clause joins can use commas or conjunctions.

### punct-long-mixed-delimiter

* Category: Mixed delimiter sentence
* Required behavior: Mixed delimiters in long prose should become structure.
* Check: Flag prose over 79 visible chars with mixed `:`, `;`, or `,`.
* Suggested repair: Apply the repair for each delimiter role.
* Known false positives: Dense examples may be intentionally compact.
* Known false negatives: Protected spans may hide mixed delimiter prose.

### punct-inline-prose-link

* Category: Inline prose link
* Required behavior: Links should not live in ordinary prose sentences.
* Check: Flag Markdown links outside a `See` section.
* Suggested repair: Move the link into a citation or asset block.
* Known false positives: Navigation lists may intentionally use links.
* Known false negatives: Bare URLs may need a separate URL rule.

### punct-old-see-citation

* Category: Old `See:` citation paragraph
* Required behavior: Citation blocks should use a nested `See` heading.
* Check: Flag prose lines that start with `See:`.
* Suggested repair: Replace with a nested `See` heading and link bullets.
* Known false positives: Quoted source text may start with `See:`.
* Known false negatives: Other citation prefixes may escape review.

### punct-soft-wrap-prose

* Category: Soft-wrapped prose paragraph
* Required behavior: Prose paragraphs may not contain single line breaks.
* Check: Flag adjacent prose lines without a blank separator.
* Suggested repair: Separate prose lines with `\n\n` or rewrite shorter.
* Known false positives: Unrecognized not-prose may look like prose.
* Known false negatives: Soft wraps inside protected blocks are ignored.

### punct-multiline-list-item

* Category: Multiline list item
* Required behavior: List items must stay on one source line.
* Check: Flag a bullet followed by non-bullet continuation text.
* Suggested repair: Use nested one-line bullets or restructure.
* Known false positives: Unrecognized block content may follow a bullet.
* Known false negatives: Long one-line bullets may need other rules.

### punct-unmarked-code-block

* Category: Unmarked fenced code block
* Required behavior: Fenced code must live in marked not-prose sections.
* Check: Flag fences outside a matching marked not-prose section.
* Suggested repair: Mark as `code-example` or `code-runme`.
* Known false positives: Fence-like prose may look like code.
* Known false negatives: Indented code blocks are not covered yet.

### punct-unmarked-markdown-table

* Category: Unmarked Markdown table
* Required behavior: Markdown tables must live in marked not-prose sections.
* Check: Flag table lines outside a `TYPE=table` section.
* Suggested repair: Move the table under a marked `TYPE=table` section.
* Known false positives: Pipe-heavy prose may look like a table.
* Known false negatives: Table-like prose without leading pipes is ignored.

### punct-unmarked-raw-html

* Category: Unmarked raw HTML block
* Required behavior: Raw HTML must live in marked not-prose sections.
* Check: Flag raw HTML lines outside a `TYPE=html` section.
* Suggested repair: Move the HTML under a marked `TYPE=html` section.
* Known false positives: XML-like examples may be mistaken for HTML.
* Known false negatives: Multi-line HTML attributes may escape review.

### punct-invalid-not-prose-marker

* Category: Invalid `not-prose` marker
* Required behavior: Not-prose markers must match the runbook marker shape.
* Check: Flag marker-like comments with invalid fields or values.
* Suggested repair: Use a valid marker for the section type.
* Known false positives: Historical quoted markers may be intentional.
* Known false negatives: Malformed comments without the prefix are ignored.

### punct-not-prose-marker-without-heading

* Category: `not-prose` marker not immediately followed by a heading
* Required behavior: A marker must immediately precede its section heading.
* Check: Flag markers whose next line is not a heading.
* Suggested repair: Place the marker immediately before the heading.
* Known false positives: Quoted marker examples may be intentional.
* Known false negatives: Extra comments between marker and heading may vary.

### punct-not-prose-heading-level

* Category: `not-prose` heading not one level below its parent heading
* Required behavior: Not-prose headings must be one level below the parent.
* Check: Flag marked section headings at any other level.
* Suggested repair: Make the heading one level below its parent.
* Known false positives: Documents with unusual heading schemes may vary.
* Known false negatives: Missing parent context near file start may be fuzzy.

## Deterministic Finding Categories

The reporter should classify findings using the rule inventory.

Future reporters should emit rule IDs with categories.

Reporter findings are suggestions only.

They should not be auto-applied without human review.
