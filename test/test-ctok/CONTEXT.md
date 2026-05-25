# test-ctok context doc

## Context policy

- Read this before changing `test/test-ctok/main`, coverage reporting, or this
  directory layout.
- Treat this as working memory, not append-only history. Keep it current,
  compact, and useful for the next turn.
- Update `Current State`, `TODO stack`, `Done`, and `Turns` when behavior,
  files, gates, or remaining work change.
- Move completed TODO items to `Done` in completion order.
- Compact old turns into state/TODOs/Done once they stop helping handoff.
- Keep this file below 8k; check `wc -c` after edits and compact before adding
  more history if it grows past that.

## Current State

- `test/test-ctok/main` is the moved former `test/test-ctok` script.
- The top-level `check` script calls `./test/test-ctok/main`.
- `main` now orchestrates ctok behavior cases, coverage build/run, the adjusted
  line coverage gate, reporter fixture tests, and the coverage reporter call.
- `test/test-ctok/coverage-report` owns gcov stdout parsing, `ctok.c.gcov`
  parsing, normalized model validation, parser-integrity checks, and report
  formatting.
- `test/test-ctok/coverage-report-test` owns fixture-driven reporter tests.
- Coverage details are always printed; there is no `CTOK_COVERAGE_DETAIL` gate.
- Adjusted line coverage remains the only coverage-quality gate.
- Branch, call, condition, and prime-path coverage are report-only metrics.
- Parser-integrity failures are hard failures when the reporter cannot prove it
  parsed gcov data consistently.

## Working Rules

- Do not add to the top-level `check` preflight `sh -n` list unless explicitly
  changing how that dynamic check works.
- Do not write random files to `.cache/`; use `$test_tmp`, `TMPDIR`, or `/tmp`.
- Avoid `shellcheck disable`.
- Keep logical coverage allowlist entries stable unless intentionally changing
  them. If line numbers drift, update line numbers only and preserve snippets
  and reasons.

## Terms

- Metric summary: file-level gcov totals parsed from `gcov` stdout, such as
  `Branches executed:100.00% of 388`.
- Detail rows: per-source rows from `ctok.c.gcov`, such as branch, call,
  condition, and `paths covered` rows.
- Parser integrity check: a hard failure because the reporter cannot prove the
  gcov data was parsed completely or consistently.
- Report-only coverage: printed coverage data without a threshold or allowlist
  gate.
- Normalized model: parsed gcov records before validation and report formatting.

## TODO stack

- Keep reporter fixtures ahead of parser changes.
  - Add fixtures before changing parsing rules or accepted gcov syntax.
  - Cover both successful formatting and parser-integrity failures.
  - Keep exact output assertions for alignment-sensitive blocks.

- Keep context process clean.
  - Add turns only for useful handoff context.
  - Compact stale turns into `Current State`, `TODO stack`, or `Done`.
  - Keep this file below the 8k compaction threshold after edits.

## Done

- Split coverage reporting out of `test/test-ctok/main` into
  `test/test-ctok/coverage-report` and `test/test-ctok/coverage-report-test`.
- Introduced a normalized gcov model and separated parsing, validation, and
  formatting.
- Hardened condition attribution with per-source pending-miss accounting.
- Hardened prime-path function/path pairing with strict next-row validation.
- Expanded parser fixtures for `branch N never executed`, misplaced condition
  misses, prime-path sorting, and prime-path alignment.
- Clarified metric validation around exact totals versus rounded percentage
  consistency.

## Turn Log Rules

- Add a new `### Turn N` whenever work resumes on `test/test-ctok/main`,
  coverage reporting, or this context doc.
- Record user intent, decisions made, files touched, tests run, and remaining
  concerns.
- Keep entries concise and chronological.

## Turns

### Turn 1

- Added the initial `Turns` section.

### Turn 2

- Expanded this into a working context doc with state, rules, terms, and TODO
  acceptance criteria.

### Turn 3

- Added `Context policy` for reading, updating, pruning, and using this file as
  working memory.

### Turn 4

- Normalized the doc for `AGENTS.md` use, added compaction guidance, clarified
  `Done`, and noted the uncommitted path-split state.

### Turn 5

- Logged the process/architecture review as TODOs and planned the
  split/normalized-model sweep.
- Remaining concern was avoiding more piecemeal parser hardening in `main`.

### Turn 6

- User asked to perform the split/normalized-model sweep as the next substantive
  `test/test-ctok/main` change.
- Moved expanded coverage reporting into `coverage-report`; added
  `coverage-report-test`; kept `main` as orchestration.
- Validated the normalized model before printing reports, so parser-integrity
  failures cannot follow a confident-looking report.
- Files touched: `test/test-ctok/main`, `test/test-ctok/coverage-report`,
  `test/test-ctok/coverage-report-test`, and this context doc.
- Tests run: `sh -n` for all three scripts,
  `./test/test-ctok/coverage-report-test`, `./test/test-ctok/main`, and
  `./check --no-clear`.
- Remaining concern: the reporter is still shell/awk-heavy; future parser edits
  should start with focused fixtures.
