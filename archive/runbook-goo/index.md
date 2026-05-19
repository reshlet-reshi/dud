# Runbook Migration Plans

Status: Experimental scratch

## Goal

Migrate the punctuation policy from a prose policy plus standalone Python
reporter into a tracked policy runbook.

The final source of truth should be `policy/punctuation-policy.md`.

A generic runner at `tools/run-policy.py` should execute marked runbook code.

The old scratch reporter at `.stash/policy/report-punctuation-policy.py`
should remain available as a parity oracle until the cutover is proven.

After parity is accepted, delete the old scratch reporter.

## Chosen Architecture

Policy prose remains the main reading experience.

Executable support lives in marked `TYPE=code-runme` sections inside the
policy runbook.

Illustrative code, if needed, lives in `TYPE=code-example` sections.

The generic runner extracts and executes runbook sections.

The generic runner must not contain punctuation-specific rule logic.

Each reportable rule gets a stable rule ID.

Each rule ID maps to a category, check behavior, suggested repair, and known
weak spots.

Reporter output is review evidence, not automatic truth.

## Checkpoint Order

Completed checkpoints are archived under `archive/`.

Active checkpoint numbering remains stable.

4. `04-generic-runner-contract.md`
5. `05-embed-punctuation-checks.md`
6. `06-embed-report-and-tests.md`
7. `07-parity-and-cutover.md`
8. `08-delete-old-reporter.md`

## Completed Checkpoint Archive

1. `archive/01-promote-policy-home.md`
2. `archive/02-profile-and-marker-syntax.md`
3. `archive/03-rule-id-inventory.md`

## Current Manual Review

Checkpoint 04 generated and committed the first generic runner baseline.

The owner is manually reviewing and editing `tools/run-policy.py`.

Checkpoint 05 should not begin until the owner says the runner contract is
ready.

Substantial runner review edits may become a follow-up checkpoint before
checkpoint 05.

Each active subplan is intended to become one local checkpoint commit.

Later subplans may be revised after findings from earlier checkpoints.

Do not skip the parity checkpoint before deleting the old reporter.

## Revision Rule

Treat these subplans as staged guidance, not immutable doctrine.

If implementation reveals a better boundary, update the later subplans before
continuing.

Keep each checkpoint small enough to review with `git show --stat` and
`git show --word-diff`.

If a checkpoint changes the public runner interface, update every later
subplan that references that interface before proceeding.

## Common Verification

Run these checks after every checkpoint unless the subplan gives a narrower
replacement.

```sh
git status --short --branch
git diff --check
python3 tools/run-policy.py --policy policy/punctuation-policy.md --self-test
```

Before the runner exists, replace the runner self-test with the old oracle:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 .stash/policy/report-punctuation-policy.py --self-test
```

## Stop Conditions

Stop and revise the active or later subplan if a checkpoint requires
punctuation-specific behavior in `tools/run-policy.py`.

Stop if the runbook output cannot be compared to the old reporter output.

Stop if the policy prose becomes unreadable as policy prose.

Stop if `.stash/policy/report-punctuation-policy.py` must be deleted before
parity is demonstrated.
