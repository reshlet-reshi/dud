# Beautiful HTML Policy

HTML exists to carry meaning.

Beautiful HTML lets the browser do ordinary browser work. It uses elements for
what they mean, then allows many readers and renderers to present that meaning
well.

This policy does not require every page to look like the beautiful document.
It asks every page to satisfy the same spirit: useful, honest, legible,
accessible, small where possible, and readable when viewed without decoration.

## Principles

Prefer semantic elements.

Prefer real text.

Prefer headings in order.

Prefer paragraphs, lists, links, tables, and forms for their actual jobs.

Prefer default behavior until default behavior fails the user.

Prefer CSS as an enhancement, not as a requirement for meaning.

## Rules

Every document must declare a language.

Every document must declare a character set.

Every responsive document must set a viewport.

Headings must describe the structure of the document.

Links must make sense as links.

Lists must be lists.

Images must have text alternatives when they carry meaning.

Color, layout, icons, and motion must not be the only carriers of meaning.

The document must remain readable in a text browser or reader view unless the
page has a clear interactive purpose that makes this impossible.

## Checks

Run an HTML validator.

Read the source.

Read the page in Lynx.

Read the page at 320 CSS pixels wide.

Navigate the headings.

Follow the links.

Ask whether the raw HTML and rendered page tell the same story.

## Exceptions

Interactive applications may need scripts, controls, and richer layout.

Even then, the first useful layer should be ordinary HTML whenever possible.
The expensive layer should earn its place by adding behavior, not by repairing
missing meaning.

## Source Spirit

The beautiful document works because the source, Lynx output, and iPhone-width
render agree with each other. The HTML says what the document is. The renderers
do not have to guess.

