# 04 Generic Runner Contract

Status: Initial implementation generated and committed.

The owner is manually reviewing and editing the generated generic runner.

Checkpoint 05 should wait until the owner says the runner contract is ready.

Substantial review edits may become a follow-up checkpoint before step 05.

## Checkpoint Commit

Commit message: `add generic policy runbook runner`

The initial commit used this message.

## Manual Review Hold

Review edits must keep `tools/run-policy.py` generic.

Review edits must keep punctuation-specific rule logic out of the runner.

Runner behavior should stay limited to policy runbook plumbing.

If review changes the public runner interface, update later subplans first.

## Files To Touch

* Add `tools/run-policy.py`.
* Update `tools/README.md`.
* Update `policy/punctuation-policy.md` only for runner contract examples.
* Do not move punctuation detection logic into the policy yet.
* Do not delete `.stash/policy/report-punctuation-policy.py`.

## Behavior Change

Implement a generic runner that understands policy runbook plumbing.

The runner should accept:

```sh
python3 tools/run-policy.py --policy policy/punctuation-policy.md --file PATH --output PATH
python3 tools/run-policy.py --policy policy/punctuation-policy.md --self-test
```

The runner should validate the `doc-profile` marker.

The runner should extract marked `TYPE=code-runme` sections.

The runner should execute the runbook code in a deterministic local Python
namespace.

The runner should pass target file path, output path, and self-test mode to
the runbook code through a tiny documented interface.

The runner should not contain punctuation-specific rule logic.

If no runnable section exists yet, `--self-test` should report a clear
contract error.

If no runnable section exists yet, normal scan mode should report a clear
contract error.

## Verification Commands

```sh
git status --short --branch
git diff --check
python3 tools/run-policy.py --policy policy/punctuation-policy.md --self-test
python3 tools/run-policy.py --policy policy/punctuation-policy.md --file policy/punctuation-policy.md --output .tmp/runbook-contract-report.md
PYTHONDONTWRITEBYTECODE=1 python3 .stash/policy/report-punctuation-policy.py --self-test
```

The first two runner commands may fail with the planned contract error until
checkpoint 05.

They must not fail with a traceback.

## Stop If

Stop if `tools/run-policy.py` needs to know punctuation rule names.

Stop if runner execution cannot be limited to marked `code-runme` sections.

Stop if the runner interface needs more required flags than the two planned
commands.

## Later Subplan Notes

Checkpoint 05 should make the runner commands succeed by adding runbook code.

Checkpoint 06 should make `--self-test` meaningful and complete.
