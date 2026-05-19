# 01 Promote Policy Home

## Checkpoint Commit

Commit message: `promote punctuation policy runbook home`

## Files To Touch

* Add `policy/punctuation-policy.md`.
* Add `policy/README.md`.
* Add `tools/README.md`.
* Optionally update root `README.md` with one short pointer to `policy/`.
* Do not add `tools/run-policy.py` yet.
* Do not delete `.stash/policy/punctuation-policy.md`.
* Do not delete `.stash/policy/report-punctuation-policy.py`.

## Behavior Change

Promote the punctuation policy draft from scratch space into a tracked policy
home.

Copy the current `.stash/policy/punctuation-policy.md` content into
`policy/punctuation-policy.md`.

Keep the promoted policy explicitly experimental until the runner migration is
complete.

Explain in `policy/README.md` that tracked policy runbooks live under
`policy/`.

Explain in `tools/README.md` that generic helper tooling belongs under
`tools/`.

Keep `.stash/` as incubation and oracle storage only.

## Verification Commands

```sh
git status --short --branch
git diff --check
diff -u .stash/policy/punctuation-policy.md policy/punctuation-policy.md
PYTHONDONTWRITEBYTECODE=1 python3 .stash/policy/report-punctuation-policy.py --self-test
git status --short --ignored=matching .stash/policy/punctuation-policy.md .stash/policy/report-punctuation-policy.py
```

## Stop If

Stop if the promoted policy differs from the scratch policy before intentional
runbook syntax changes.

Stop if `for-agents/` becomes the home for live tools.

Stop if the old reporter fails its self-test.

## Later Subplan Notes

Later checkpoints should edit `policy/punctuation-policy.md`.

The scratch copy may remain as historical incubation until cleanup.

