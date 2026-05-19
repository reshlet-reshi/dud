# 05 Embed Punctuation Checks

## Checkpoint Commit

Commit message: `embed punctuation checks in policy runbook`

## Files To Touch

* Update `policy/punctuation-policy.md`.
* Update `tools/run-policy.py` only if the generic runner interface has a bug.
* Do not delete `.stash/policy/report-punctuation-policy.py`.

## Behavior Change

Move Markdown profile parsing and finding detection into marked
`TYPE=code-runme` sections in `policy/punctuation-policy.md`.

Port these old reporter responsibilities into the runbook:

* visible text extraction
* protected span handling
* punctuation classification
* heading, bullet, marker, fence, table, and raw HTML recognition
* not-prose section state tracking
* finding construction
* scan behavior

Emit findings with:

* line number
* rule ID
* category
* visible length
* punctuation class
* preview
* suggested repair

Keep report rendering simple if checkpoint 06 has not happened yet.

Keep the old reporter as the parity oracle.

## Verification Commands

```sh
git status --short --branch
git diff --check
python3 tools/run-policy.py --policy policy/punctuation-policy.md --file policy/punctuation-policy.md --output .tmp/runbook-policy-report.md
PYTHONDONTWRITEBYTECODE=1 python3 .stash/policy/report-punctuation-policy.py --file policy/punctuation-policy.md --output .tmp/old-policy-report.md
sed -n '1,120p' .tmp/runbook-policy-report.md
sed -n '1,120p' .tmp/old-policy-report.md
```

## Stop If

Stop if runbook code must be copied into `tools/run-policy.py`.

Stop if the runbook cannot emit all existing old reporter categories.

Stop if output differs from the old reporter in a way that is not documented
in the checkpoint commit.

## Later Subplan Notes

Checkpoint 06 should move tests and report rendering into the runbook.

Checkpoint 07 should perform full parity comparisons on known targets.

