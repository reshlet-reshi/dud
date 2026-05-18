# Prompt: Show One Markdown File As Reader-Friendly HTML

Render one Markdown file as a standalone HTML document for reading.

The generated HTML should follow `html.md` when that file exists in the
project root. Treat that file as the local HTML Document Policy.

The generated HTML should be good in two ways:

- useful and honest in a browser, text browser, or screen reader
- readable from source, as if maintained by hand

Prefer default browser behavior. CSS is a last resort.

## Inputs

The user should provide:

- the Markdown file path to render
- optionally, the output HTML path

If the output path is not provided, write to:

```text
$PROJECT_ROOT/.tmp/show-md.html
```

Here, `$PROJECT_ROOT` means the output of:

```sh
git rev-parse --show-toplevel
```

Create `.tmp/` if it does not already exist.

## Required Inspection

Before writing the HTML, inspect the Markdown file:

```sh
test -f PATH
sed -n '1,240p' PATH
wc -l PATH
```

If the file is longer than 240 lines, read additional relevant ranges before
rendering. Do not modify the source Markdown file.

Also inspect the local HTML policy when present:

```sh
test -f html.md && sed -n '1,180p' html.md
```

When this prompt and `html.md` disagree, prefer the spirit of `html.md`:
semantic elements, real text, ordered headings, real lists, default behavior,
little CSS, readable source, Lynx readability, and a useful 320 CSS pixel
render.

## Markdown Profile

Render a small documentation-oriented Markdown profile:

- ATX headings, `#` through `######`
- paragraphs
- bullet lists
- numbered lists
- inline code
- fenced code blocks
- indented code blocks
- blockquotes
- links
- thematic breaks
- GitHub Flavored Markdown pipe tables

Tables are a GitHub Flavored Markdown extension, not core CommonMark. Support
GFM-style pipe tables because they are useful for file summaries and diff
reports. Do not enable other GFM extensions unless the user explicitly asks.

When Markdown syntax is outside this profile, preserve it visibly as text
rather than guessing. Raw HTML in Markdown should be handled conservatively:
render only when simple and safe; otherwise escape it and preserve it visibly.

## Rendering Rules

Render the Markdown content into simple semantic HTML:

- headings become `<h1>` through `<h6>`
- paragraphs become `<p>` elements
- fenced and indented code blocks become `<pre><code>` blocks
- inline code becomes `<code>`
- bullet and numbered lists become `<ul>` or `<ol>`
- blockquotes become `<blockquote>`
- links become `<a href="...">`
- thematic breaks become `<hr>`
- GFM pipe tables become semantic `<table>` elements

Escape HTML-sensitive characters from Markdown text, including `&`, `<`, `>`,
and quotes. In generated examples, prefer explicit entities such as `&quot;`
over literal double quotes.

## HTML Source Style

Write HTML that is comfortable to maintain by hand.

Keep the source close to WYSIWYG. The raw HTML and rendered page should tell
the same story.

Wrap source lines around 80 columns where practical. It is fine to exceed that
limit for long URLs, long code lines, or places where wrapping would make the
source less clear.

Use comments sparingly. Add comments only when the source would otherwise stop
being WYSIWYG, or when a conversion choice needs explanation. Do not add a
comment before every rendered Markdown section.

Use comments to clarify structure, not to narrate every obvious tag.

## Report Shape

Make the HTML reader-mode and screen-reader friendly.

Use one semantic `<article>` as the main document body. The article should
start with the Markdown document's first heading if it has one. If the Markdown
has no heading, use the file basename as the `<h1>`.

Prefer real prose flow over decorative layout. Avoid cards, sidebars, or
list-only wrapper sections. The goal is for Chrome reading mode and screen
readers to find the document text naturally.

Use a plain page. Do not create cards, decorative frames, complex layout,
icons, motion, or color-dependent meaning.

## Links And Paths

Preserve external links as written.

For relative links, leave the `href` value relative to the output document only
if that will still be useful from `.tmp/`. If a relative link points inside the
repo and would break from `.tmp/`, rewrite it to a repo-root-relative file path
or add a parenthetical text note with the original target.

Do not fetch remote links while rendering.

## Styling

Start with no CSS.

Add CSS only when the document would otherwise fail a real check such as:

- readable source
- readable browser output
- readable 320 CSS pixel output
- accessible text browser output
- useful table or code block presentation

When CSS is needed, keep it small and functional. Prefer element selectors.
Avoid color palettes, decorative backgrounds, custom heading systems, paper
panels, or code-block ornamentation. Let the browser carry most presentation.

## Display Behavior

After verification, open the generated HTML in Chrome by default. This command
is part of showing the Markdown, not a decoration.

If opening Chrome requires GUI or sandbox escalation, request it with a brief
justification.

If the user explicitly asks not to open a browser, skip this step and report
that it was skipped.

## Verification

After writing the file, verify:

```sh
test -f OUTPUT
```

If the output is under `.tmp/`, also verify:

```sh
git check-ignore -v OUTPUT
```

Then report the output path, the Markdown file rendered, the checks run,
whether Chrome was opened, and any checks skipped.

Also verify the output against the HTML Document Policy when tools are
available:

```sh
tidy -qe OUTPUT
lynx -dump OUTPUT
```

If `.stash/tools/render-iphone-html.sh` exists and the output is local, render a 320
CSS pixel scroll review:

```sh
.stash/tools/render-iphone-html.sh OUTPUT .tmp/show-md-320x480.png
```

This writes the first 320 by 480 viewport screenshot, plus scroll-review
artifacts such as a full-height PNG, 480px slices, and a manifest when the
helper supports them.

Do not treat these commands as mere artifact generation. Inspect the Lynx text
output and the 320 CSS pixel render artifacts before accepting the HTML.

In the Lynx output, look for:

- missing text
- broken heading order
- lists that do not read as lists
- links that are unclear
- raw markup that leaked into prose
- spacing that makes the document hard to follow

In the 320 CSS pixel render artifacts, look for:

- horizontal overflow
- clipped text
- awkward wrapping
- overlapping content
- unreadable line lengths
- visual clutter introduced by the HTML

If either rendered output reveals a problem, revise the HTML and rerun the
relevant checks. Multiple rounds are allowed. Stop only when the source, Lynx
output, and 320 CSS pixel render tell the same story.

Report any skipped checks and why they were skipped.

## References

CommonMark 0.31.2 is the current core CommonMark specification:

```text
https://spec.commonmark.org/
```

GitHub Flavored Markdown defines tables as an extension:

```text
https://github.github.com/gfm/
```
