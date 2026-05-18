# Prompt: Generate A Reader-Friendly Repo Diff HTML

Generate an HTML diff report for the current repository state.

## Output

Write the report to:

```text
$PROJECT_ROOT/.tmp/current-repo-diff.html
```

Here, `$PROJECT_ROOT` means the output of:

```sh
git rev-parse --show-toplevel
```

Create `.tmp/` if it does not already exist. Do not modify tracked files while
generating the report.

## Required Inspection

Before writing the report, inspect the repo state with:

```sh
git status --short --branch
git diff --stat
git diff --name-status
git diff
```

Also detect untracked, non-ignored files from `git status --short --branch`.
Ignored files under `.tmp/` should not be included in the reported repo diff
unless the user explicitly asks for ignored scratch artifacts too.

## Report Shape

Make the HTML reader-mode and screen-reader friendly.

Use one semantic `<article>` as the main document body. Prefer real prose
paragraphs for summaries and explanations. Avoid a layout that is mostly cards,
headings, or list-only sections when the document is meant to be read
continuously.

The report should contain these sections, in this order:

1. `Current Repo Diff`
2. `Reader-Friendly Summary`
3. `Changed Files`
4. `Linear Diff Summary`
5. `Tracked Raw Diff`
6. `Untracked New File Content`, only if relevant

## Reader-Friendly Summary

Summarize the current worktree in prose:

- current branch
- number of modified tracked files
- number of added, deleted, renamed, or untracked files
- the broad purpose of the changes, inferred from the diff
- any important caveats, such as untracked files not appearing in `git diff`

Do not claim tests or validation were run unless they were actually run.

## Changed Files

Include a simple table with these columns:

- Status
- File
- Reader summary

Use explicit status text such as `Modified`, `Added`, `Deleted`, `Renamed`, or
`Untracked new file`; do not rely on color alone.

## Linear Diff Summary

For each changed file, add a heading with the file path and one or more prose
paragraphs summarizing the meaningful change. Explain removals and additions in
plain language.

For untracked text files, summarize what the new file contains. For binary
files or very large text files, state that the content was not embedded and
summarize metadata instead.

## Raw Diff

Include a raw diff section for tracked changes using the output of:

```sh
git diff
```

Escape HTML-sensitive characters inside the raw diff, including `&`, `<`, and
`>`. Keep the raw diff inside a `<pre><code>` block.

For untracked text files that are small enough to read comfortably, include
their full content under `Untracked New File Content` in `<pre><code>` blocks.
For large or binary untracked files, include a prose note instead of embedding
the content.

## Accessibility Rules

If you include any visual diff table, also include the first-class linear
reader view described above. The linear reader view must be ordinary visible
document content, not a browser-specific reading-mode fallback.

Visual-only redundant regions may be marked `aria-hidden="true"` only when an
equivalent reader-friendly version is present and the hidden region has no
focusable or interactive controls.

Label additions, removals, and context in text. Do not rely on color alone.

## Styling

Use simple inline CSS in the HTML document. Keep it quiet and readable:

- responsive max-width article
- readable prose font size and line height
- monospace blocks for raw diff content
- high-contrast colors
- no decorative visual clutter

## Verification

After writing the file, verify:

```sh
test -f .tmp/current-repo-diff.html
git check-ignore -v .tmp/current-repo-diff.html
```

Then report the output path and a brief summary of what the generated diff
contains. Open the file in Chrome only if the user asks.
