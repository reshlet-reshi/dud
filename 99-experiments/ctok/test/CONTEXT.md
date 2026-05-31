# 99-experiments/ctok/test context doc

## Context policy

- Read this before changing `99-experiments/ctok/test/main`, coverage reporting, or this
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

- `99-experiments/ctok/test/main` orchestrates ctok behavior cases and coverage checks.
- The root `runme` script no longer runs ctok; use
  `./99-experiments/ctok/runme` for standalone ctok builds/tests.
- `99-experiments/ctok/runme` builds `99-experiments/ctok/main.c` into `.dud/ctok` and then runs
  `./99-experiments/ctok/test/main`.
- The ctok runme script bootstraps `.dud/musl-cc` and `.dud/expect` when
  needed because root `./runme` no longer prepares ctok.
- Shared exact-output assertions use `.dud/expect`, built from
  `04-expect/main.c`, instead of sourcing the old expect shell helper.
- `main` now orchestrates ctok behavior cases, coverage compile/run, the adjusted
  line coverage gate, reporter fixture tests, and the coverage reporter call.
- `99-experiments/ctok/test/coverage-report` owns gcov stdout parsing, `main.c.gcov`
  parsing, normalized model validation, parser-integrity checks, and report
  formatting.
- `99-experiments/ctok/test/coverage-report-test` owns fixture-driven reporter tests.
- Coverage details are always printed; there is no `CTOK_COVERAGE_DETAIL` gate.
- Adjusted line coverage remains the only coverage-quality gate.
- Branch, call, condition, and prime-path coverage are report-only metrics.
- Parser-integrity failures are hard failures when the reporter cannot prove it
  parsed gcov data consistently.

## Working Rules

- Do not reintroduce the old top-level preflight `sh -n` list unless
  explicitly changing how the ShellCheck bootstrap/lint path works.
- Do not write random files to `.dud/`; use `$test_tmp`, `TMPDIR`, or `/tmp`.
- Avoid `shellcheck disable`.
- Keep logical coverage allowlist entries stable unless intentionally changing
  them. If line numbers drift, update line numbers only and preserve snippets
  and reasons.

## Terms

- Metric summary: file-level gcov totals parsed from `gcov` stdout, such as
  `Branches executed:100.00% of 388`.
- Detail rows: per-source rows from `main.c.gcov`, such as branch, call,
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

- Split coverage reporting out of `99-experiments/ctok/test/main` into
  `99-experiments/ctok/test/coverage-report` and `99-experiments/ctok/test/coverage-report-test`.
- Introduced a normalized gcov model and separated parsing, validation, and
  formatting.
- Hardened condition attribution with per-source pending-miss accounting.
- Hardened prime-path function/path pairing with strict next-row validation.
- Expanded parser fixtures for `branch N never executed`, misplaced condition
  misses, prime-path sorting, and prime-path alignment.
- Clarified metric validation around exact totals versus rounded percentage
  consistency.
- Ported the shared `expect_output`, `expect_status`, and `expect_error`
  helpers from the old expect shell helper to the compiled
  `04-expect/main.c` utility.
- Generated project outputs live in `.dud/`; the generated TCC install lives
  under `.dud/musl-tcc/`.
- Source-local runme scripts no longer accept a compiler argument; they compile
  with `.dud/musl-cc` directly.
- The old `src/runme` wrapper has been removed; use the source-local runme scripts
  directly.

## Turn Log Rules

- Add a new `### Turn N` whenever work resumes on `99-experiments/ctok/test/main`,
  coverage reporting, or this context doc.
- Record user intent, decisions made, files touched, tests run, and remaining
  concerns.
- Keep entries concise and chronological.

## Turns

### Turns 1-13 compacted

- Established this context process, moved tests/sources under `src/foo/test`
  and `src/foo/main.c`, split coverage reporting into `coverage-report` plus
  fixtures, and ported exact-output helpers to `04-expect/main.c`.
- Source-local runme scripts own their built executables and test runs; the
  current state above is the source of truth for paths and gates.

### Turn 14

- User asked to rename canonical entrypoints from `build` to `runme`, without
  compatibility wrappers.
- Top-level and source-local runme scripts now preserve the previous behavior
  while using runme paths and usage text.

### Turn 15

- User asked to rename the generated root to `.dud/`.
- Scripts, tests, wrappers, ignore rules, and docs now use `.dud/`; top-level
  `./runme --clean` also removes the stale legacy root.
- Tests run: planned `sh -n` sweep, `./runme --clean`, absence checks for both
  generated roots, fresh `./runme`, generated-output checks, and stale-reference
  scan.

### Turn 16

- User asked to remove the compiler argument from source runme paths.
- Top-level and source-local runme scripts now hardcode `.dud/musl-cc` for
  source builds.

### Turn 17

- User asked to inline `./src/runme`.
- Top-level `runme` now calls the source-local runme scripts directly, and the
  `src/runme` wrapper was removed.

### Turn 18

- User asked to rename the musl-tcc install directory from `.dud/bootstrap-tcc`
  to `.dud/musl-tcc`.

### Turn 19

- User asked to move the musl-tcc bootstrap step into `03-musl-tcc`.

### Turn 20

- User asked to move expect, ctok, and dud-sh into numbered top-level
  directories: `04-expect`, `99-experiments/ctok`, and `99-experiments/dud-sh`.

### Turn 21

- User asked to move ctok and dud-sh under `99-experiments/` and unhook them
  from root `./runme`.
- Updated ctok paths in runme/test/coverage scripts and kept generated ctok
  output at `.dud/ctok`.
- Made ctok runme bootstrap its musl compiler and expect-test dependencies when
  run standalone.
