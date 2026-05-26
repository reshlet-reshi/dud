# src/ctok/test context doc

## Context policy

- Read this before changing `src/ctok/test/main`, coverage reporting, or this
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

- `src/ctok/test/main` orchestrates ctok behavior cases and coverage checks.
- The top-level `init` script calls source-local init scripts directly; they
  compile with `.init/musl-cc`.
- `src/ctok/init` builds `src/ctok/main.c` into `.init/ctok` and then runs
  `./src/ctok/test/main`.
- Shared exact-output assertions use `.init/expect`, built from
  `src/expect/main.c`, instead of sourcing the old expect shell helper.
- `main` now orchestrates ctok behavior cases, coverage compile/run, the adjusted
  line coverage gate, reporter fixture tests, and the coverage reporter call.
- `src/ctok/test/coverage-report` owns gcov stdout parsing, `main.c.gcov`
  parsing, normalized model validation, parser-integrity checks, and report
  formatting.
- `src/ctok/test/coverage-report-test` owns fixture-driven reporter tests.
- Coverage details are always printed; there is no `CTOK_COVERAGE_DETAIL` gate.
- Adjusted line coverage remains the only coverage-quality gate.
- Branch, call, condition, and prime-path coverage are report-only metrics.
- Parser-integrity failures are hard failures when the reporter cannot prove it
  parsed gcov data consistently.

## Working Rules

- Do not reintroduce the old top-level preflight `sh -n` list unless
  explicitly changing how the ShellCheck bootstrap/lint path works.
- Do not write random files to `.init/`; use `$test_tmp`, `TMPDIR`, or `/tmp`.
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

- Split coverage reporting out of `src/ctok/test/main` into
  `src/ctok/test/coverage-report` and `src/ctok/test/coverage-report-test`.
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
  `src/expect/main.c` utility.
- Generated project outputs live in `.init/`; the generated TCC install lives
  under `.init/musl-tcc/`.
- Source-local init scripts no longer accept a compiler argument; they compile
  with `.init/musl-cc` directly.
- The old `src/init` wrapper has been removed; use the source-local init scripts
  directly.

## Turn Log Rules

- Add a new `### Turn N` whenever work resumes on `src/ctok/test/main`,
  coverage reporting, or this context doc.
- Record user intent, decisions made, files touched, tests run, and remaining
  concerns.
- Keep entries concise and chronological.

## Turns

### Turns 1-13 compacted

- Established this context process, moved tests/sources under `src/foo/test`
  and `src/foo/main.c`, split coverage reporting into `coverage-report` plus
  fixtures, and ported exact-output helpers to `src/expect/main.c`.
- Source-local init scripts own their built executables and test runs; the
  current state above is the source of truth for paths and gates.

### Turn 14

- User asked to rename canonical entrypoints from `build` to `init`, without
  compatibility wrappers.
- Top-level and source-local init scripts now preserve the previous behavior
  while using init paths and usage text.

### Turn 15

- User asked to rename the generated root to `.init/`.
- Scripts, tests, wrappers, ignore rules, and docs now use `.init/`; top-level
  `./init --clean` also removes the stale legacy root.
- Tests run: planned `sh -n` sweep, `./init --clean`, absence checks for both
  generated roots, fresh `./init`, generated-output checks, and stale-reference
  scan.

### Turn 16

- User asked to remove the compiler argument from source init paths.
- Top-level and source-local init scripts now hardcode `.init/musl-cc` for
  source builds.

### Turn 17

- User asked to inline `./src/init`.
- Top-level `init` now calls the source-local init scripts directly, and the
  `src/init` wrapper was removed.

### Turn 18

- User asked to rename the musl-tcc install directory from `.init/bootstrap-tcc`
  to `.init/musl-tcc`.

### Turn 19

- User asked to move the musl-tcc bootstrap step into `03-musl-tcc`.
