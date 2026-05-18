# HTML Document Policy

HTML documents carry:
- content
- low level layout

Good HTML:
- uses simple semantic elements
- supports many readers and renderers

It should be:
- Useful
- Legible
- Accessible
- As small as possible
- Readable as plain text

HTML documents are not meant to be checked into Git.

They are generated from other source files.

An HTML document is usually just:
- a transient file
- used for displaying content
- in a web browser

## Principles

Prefer semantic elements.

Prefer real text.

Prefer headings in order.

Prefer:
- Paragraphs
- Lists
- Links
- Tables
- Code blocks

Use elements for their actual jobs.

Prefer default behavior.

CSS is a last resort.

The following CSS exceptions are allowed:
```css
body {
  margin: 1rem;
}

article {
  max-width: 72ch;
}
```

Unlisted CSS requires a policy amendment.

Keep documents WYSIWYG.
- Otherwise add comments.

Headings are encouraged.

Links are encouraged.

Commas are discouraged.

The following are discouraged:
- Color
- Complex Layout
- Icons
- Motion

## Rules

Every document must declare a language.

Every document must declare a character set.

Every document must set a viewport.

If content is conceptually a list:
- it must be a real HTML list

Images must carry meaning.

Images must have meaningful alt text.

If alt text is noise, omit the image.

Links are document content when they make sense as links.

Every document must be readable in a text browser.

Every document must support screen readers.

The following do not belong in a 'document':

- Forms
- Controls
- Widgets
- Scripts
- Client-side state

They belong to an HTML app or program.

## Checks

Run an HTML validator.

Read the source.

Read the page in Lynx.

Read the page at 320 CSS pixels wide.

Navigate the headings.

Follow the links.

The raw HTML and rendered page:
- should tell the same story.
