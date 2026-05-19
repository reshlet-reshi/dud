# 06 Embed Report And Tests

## Checkpoint Commit

Commit message: `embed punctuation report tests`

## Files To Touch

* Update `policy/punctuation-policy.md`.
* Update `tools/run-policy.py` only to support generic self-test execution.
* Do not delete `.stash/policy/report-punctuation-policy.py`.

## Behavior Change

Move report rendering into a `TYPE=code-runme` section in the policy runbook.

Move the old embedded unittest coverage into the policy runbook.

Keep fixtures close to the rules they exercise when that improves auditability.

Ensure `--self-test` runs the runbook tests through the generic runner.

Ensure normal scan mode writes the Markdown report at the requested output
path.

Report output should include:

* target path
* maximum visible length
* total finding count
* summary by category
* findings with rule ID, category, line, evidence, and suggested repair

## Verification Commands

```sh
git status --short --branch
git diff --check
python3 tools/run-policy.py --policy policy/punctuation-policy.md --self-test
python3 tools/run-policy.py --policy policy/punctuation-policy.md --file policy/punctuation-policy.md --output .tmp/runbook-policy-report.md
sed -n '1,160p' .tmp/runbook-policy-report.md
PYTHONDONTWRITEBYTECODE=1 python3 .stash/policy/report-punctuation-policy.py --self-test
```

## Stop If

Stop if self-tests require punctuation-specific logic in the generic runner.

Stop if report output drops line numbers, categories, or repair suggestions.

Stop if fixtures make the policy unreadable as policy prose.

## Later Subplan Notes

Checkpoint 07 should compare old and new reports on the promoted policy and
the active meta-policy research report.

