# 03 Rule ID Inventory

## Checkpoint Commit

Commit message: `inventory punctuation policy rule ids`

## Files To Touch

* Update `policy/punctuation-policy.md`.
* Do not change runner code.
* Do not change `.stash/policy/report-punctuation-policy.py`.

## Behavior Change

Assign a stable rule ID to every reportable finding category.

Use lowercase ASCII rule IDs with hyphens.

Prefix punctuation policy IDs with `punct-`.

Create a rule inventory section that maps each ID to:

* report category
* required behavior
* deterministic check behavior
* suggested repair
* known false positives or false negatives

Cover these existing categories:

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

Use the rule inventory as the source of truth for report categories and
suggested repairs.

Keep the existing prose sections, but update them to reference rule IDs where
that helps readers connect prose to checks.

## Verification Commands

```sh
git status --short --branch
git diff --check
rg -n "punct-|Rule ID|report category|suggested repair|false positive|false negative" policy/punctuation-policy.md
PYTHONDONTWRITEBYTECODE=1 python3 .stash/policy/report-punctuation-policy.py --file policy/punctuation-policy.md --output .tmp/punctuation-policy-promoted-report.md
sed -n '1,80p' .tmp/punctuation-policy-promoted-report.md
```

## Stop If

Stop if any existing reporter category lacks a rule ID.

Stop if two categories share one rule ID without an explicit reason.

Stop if rule IDs are likely to change during ordinary prose polish.

## Later Subplan Notes

The generic runner and embedded checks should emit rule IDs, not only category
strings.

Parity should compare both old categories and new rule IDs where possible.

