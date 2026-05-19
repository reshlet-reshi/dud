# Runbook Policy Notes

Status: Experimental scratch

This note explores a stronger model for project policy documents.

The core thesis is that a binding policy should be a runbook.

A runbook policy is not merely a statement of taste.

It is an inspection recipe that tells a reviewer how to find likely failures.

The policy should also define the report that carries those failures.

## Model

The chosen model is a literate linter.

The policy document stays readable to humans.

It also carries stable rule intent for tools.

That intent may be expressed as rule labels or finding names.

It may also be expressed as examples or checks.

The tool turns that intent into reported evidence.

The report does not replace judgment.

It makes judgment cheaper, repeatable, and easier to audit.

## Promotion Threshold

Advisory policy is prose.

Binding policy is prose plus executable evidence.

Promotion should be costly on purpose.

A claim should not become binding merely because it sounds wise.

A binding claim should have a stable rule ID.

A binding claim should have nearby runnable support.

A binding claim should have passing and failing examples.

A binding claim should have a report category.

A binding claim should have repair guidance.

If a claim cannot produce evidence, keep it advisory.

If a claim can only produce partial evidence, say so in the runbook.

The policy should name the human judgment boundary.

## Advisory Policy

Advisory policy should be minimized.

It still has a role.

It can explain rationale.

It can record taste.

It can preserve unsettled tradeoffs.

It can incubate possible future rules.

Advisory text should not impersonate binding text.

Advisory text should not carry hidden requirements.

When advice becomes enforceable, promote it into a rule contract.

## Binding Rule Contract

A binding rule should read like future lint output.

The wording should survive being quoted in a finding.

The wording should say what is required.

The wording should avoid broad taste claims.

The rule should define the local evidence a reporter can show.

The rule should define the suggested repair a reporter can show.

The rule should define at least one passing case.

The rule should define at least one failing case.

The executable check should live near the rule it supports.

The examples should live near the rule they explain.

That nearness is part of the review model.

Reviewers should not need to trust a distant tool by memory.

## Document Profile

Runbook policy documents should start with a document profile marker.

The marker shape is `doc-profile` with `TYPE=policy-runbook`.

The marker also includes `VER`.

The `VER` token should match `v<major>.<minor>` or `v<major>.x`.

Examples include `v0.1` and `v0.x`.

The marker tells tooling which lint rules apply.

It also tells readers what kind of document they are reading.

## Runbook Sections

Policy prose remains the main reading experience.

Executable linter support belongs in marked not-prose sections.

Those sections should not interrupt the main policy argument.

Marked sections should be nearby enough to audit the rule they support.

There are two code-like runbook section types.

`code-example` is illustrative code that explains policy intent.

`code-runme` is executable code that a reporter or harness may run.

`table` and `html` remain available for non-code not-prose material.

Use `WHY` when a not-prose section explains or preserves context.

`WHY` should be a machine-friendly rule or purpose token.

`code-runme` does not require `WHY`.

Executable code may instead be identified by section heading and rule binding.

## Roles

`AGENTS.md` is the small operational router for agents.

Policy documents are runbooks that define rules and checks.

Reporters and linters produce findings from runbook logic.

Humans decide edge cases, promotion, and final acceptance.

## Rule Shape

A policy rule should answer four questions.

Each reportable policy rule should have a stable rule ID.

The rule ID should be stable enough for reports and tests.

The rule ID should map to a report category.

The rule ID should map to check behavior.

The rule ID should map to a suggested repair.

* What is required?
* How can likely violations be detected?
* What report category names the finding?
* What repair should the report suggest?

The rule should prefer checkable structure over broad taste claims.

The rule should say where deterministic checking is expected to be weak.

The rule should name known false positives and false negatives when useful.

## Reporter Shape

A reporter should emit evidence, not verdicts.

Each finding should include a line number.

Each finding should include a category.

Each finding should include local evidence.

Each finding should include a suggested repair.

A clean report is not proof of correctness.

A clean report is evidence that deterministic checks passed.

## Punctuation Example

The punctuation policy is the current motivating example.

It defines a prose profile.

It defines delimiter roles for `.`, `:`, `;`, and `,`.

It defines old citation paragraphs and inline prose links as findings.

It defines not-prose section markers.

Its reporter scans Markdown and emits line-based findings.

That makes the policy more than advice.

It becomes a runbook for inspecting prose shape.

It does not yet have a document profile marker.

It does not yet have stable rule IDs.

It still uses coarse `TYPE=code` rather than split code types.

It currently requires `WHY` for all not-prose sections.

It does not yet bind rules to marked executable sections.

## Authority

Reporter output is evidence for review.

Reporter output is not automatic truth.

When prose policy and reporter behavior disagree, record the disagreement.

Then decide which artifact should change.

Patch the reporter, patch the policy, or accept an exception.

The policy should make that judgment point visible.

The linter should be humble enough to be corrected.

## Partially Checkable Rules

Some important rules are only partly checkable.

Those rules may still become binding.

They must be honest about their deterministic proxy.

They must say what the reporter can detect.

They must say what the reporter cannot detect.

They must say where human review enters.

A clean report for a partial rule is narrow evidence.

It is not proof that the whole rule was satisfied.
