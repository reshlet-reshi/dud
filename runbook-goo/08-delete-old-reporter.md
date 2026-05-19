# 08 Delete Old Reporter

## Checkpoint Commit

Commit message: `delete old punctuation reporter`

## Files To Touch

* Delete `.stash/policy/report-punctuation-policy.py`.
* Delete obsolete `.tmp` reports only if they are part of the active cleanup
  task.
* Update references that still treat the old reporter as current.
* Do not delete `policy/punctuation-policy.md`.
* Do not delete `tools/run-policy.py`.

## Behavior Change

Remove the old scratch reporter after the runbook runner has proven parity.

The punctuation policy runbook becomes the maintained source of lint behavior.

The generic runner remains the maintained execution entrypoint.

Any remaining references to the old reporter should describe it as deleted
historical scratch, or should be removed.

## Verification Commands

```sh
git status --short --branch
git diff --check
test ! -e .stash/policy/report-punctuation-policy.py
python3 tools/run-policy.py --policy policy/punctuation-policy.md --self-test
python3 tools/run-policy.py --policy policy/punctuation-policy.md --file for-agents/research/policy-research/research-agent-policy-markdown-html-meta-policy.md --output .tmp/runbook-main-report.md
rg -n "report-punctuation-policy.py|old reporter|scratch reporter" .
```

The final `rg` may find historical migration plans.

Only live docs and current instructions must stop pointing to the old
reporter as usable tooling.

## Stop If

Stop if `tools/run-policy.py` cannot run self-tests.

Stop if the active meta-policy report cannot be scanned.

Stop if live docs still tell users to run the deleted reporter.

## Later Subplan Notes

No later subplan is required.

Future work may polish the runbook prose or generalize the runner for other
policy profiles.

