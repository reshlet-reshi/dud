# 07 Parity And Cutover

## Checkpoint Commit

Commit message: `cut over punctuation policy runner`

## Files To Touch

* Update `policy/punctuation-policy.md`.
* Update `policy/README.md`.
* Update `tools/README.md`.
* Optionally update root `README.md` with the new runner command.
* Do not delete `.stash/policy/report-punctuation-policy.py` yet.

## Behavior Change

Run the old reporter and the runbook runner against known targets.

Use at least these targets:

* `policy/punctuation-policy.md`
* `for-agents/research/policy-research/research-agent-policy-markdown-html-meta-policy.md`
* `.stash/policy/runbook-policy-notes.md` if it still exists

Compare finding counts and categories.

Compare representative finding previews and suggested repairs.

Document any intentional differences in the policy runbook or a short cutover
note.

Switch documented usage from the old scratch reporter to:

```sh
python3 tools/run-policy.py --policy policy/punctuation-policy.md --file PATH --output PATH
```

Keep the old reporter available for one final cleanup checkpoint.

## Verification Commands

```sh
git status --short --branch
git diff --check
python3 tools/run-policy.py --policy policy/punctuation-policy.md --self-test
python3 tools/run-policy.py --policy policy/punctuation-policy.md --file for-agents/research/policy-research/research-agent-policy-markdown-html-meta-policy.md --output .tmp/runbook-main-report.md
PYTHONDONTWRITEBYTECODE=1 python3 .stash/policy/report-punctuation-policy.py --file for-agents/research/policy-research/research-agent-policy-markdown-html-meta-policy.md --output .tmp/old-main-report.md
sed -n '1,120p' .tmp/runbook-main-report.md
sed -n '1,120p' .tmp/old-main-report.md
rg -n "report-punctuation-policy.py|tools/run-policy.py|punctuation-policy.md" README.md policy tools .stash/policy/runbook-migration-plans
```

## Stop If

Stop if parity differences are unexplained.

Stop if documented usage still points readers to the old scratch reporter as
the primary command.

Stop if the runbook cannot lint the active meta-policy report.

## Later Subplan Notes

After this checkpoint, the old reporter is obsolete but still present for
review.

Checkpoint 08 should delete it.

