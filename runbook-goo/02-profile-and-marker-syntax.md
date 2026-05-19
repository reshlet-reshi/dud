# 02 Profile And Marker Syntax

## Checkpoint Commit

Commit message: `define policy runbook markers`

## Files To Touch

* Update `policy/punctuation-policy.md`.
* Do not change `tools/`.
* Do not change `.stash/policy/report-punctuation-policy.py`.

## Behavior Change

Add the document profile marker to the top of the policy runbook.

Use this marker shape:

```md
<!-- doc-profile: TYPE=policy-runbook, VER=v0.x -->
```

Define `VER` as a machine-friendly token matching `v<major>.<minor>` or
`v<major>.x`.

Replace the old `TYPE=code` policy with `TYPE=code-example` and
`TYPE=code-runme`.

Keep `TYPE=table` and `TYPE=html` as available not-prose types.

Require `WHY` for `code-example`, `table`, and `html`.

Do not require `WHY` for `code-runme`.

State that `code-runme` sections are bound by their section heading and rule
bindings.

Keep policy prose readable and one sentence or list item per source line.

## Verification Commands

```sh
git status --short --branch
git diff --check
rg -n "doc-profile|policy-runbook|VER|code-example|code-runme|TYPE=code" policy/punctuation-policy.md
PYTHONDONTWRITEBYTECODE=1 python3 .stash/policy/report-punctuation-policy.py --file policy/punctuation-policy.md --output .tmp/punctuation-policy-promoted-report.md
sed -n '1,80p' .tmp/punctuation-policy-promoted-report.md
```

## Stop If

Stop if the old reporter reports unexpected findings on the promoted policy
because the marker syntax is ambiguous.

Stop if the policy requires `WHY` for `code-runme`.

Stop if the document profile marker cannot be represented as ordinary
Markdown without making the file unreadable.

## Later Subplan Notes

Later runner work should enforce the profile marker.

Later embedded code sections should use `TYPE=code-runme`.

