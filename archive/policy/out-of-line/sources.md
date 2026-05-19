# Sources

Back to [Sources](../research-agent-policy-markdown-html-meta-policy.md#sources).

## Official agent-policy sources

- [OpenAI Developers, *Custom instructions with AGENTS.md*](https://developers.openai.com/codex/guides/agents-md). Discovery order, overrides, fallback filenames, and verification guidance.
- [GitHub Docs, *Adding repository custom instructions for GitHub Copilot*](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions). Repository-wide, path-specific, and agent instructions; nearest `AGENTS.md` precedence.
- [GitHub Docs, *About customizing GitHub Copilot responses*](https://docs.github.com/en/copilot/customizing-copilot/about-customizing-github-copilot-chat-responses). Precedence order, short self-contained statements, and scope selection.
- [Anthropic Claude Code Docs, *How Claude remembers your project*](https://docs.anthropic.com/en/docs/claude-code/memory). When to add `CLAUDE.md`, what belongs there, scope levels, imports from `AGENTS.md`, and load order.
- [AGENTS.md project site](https://agents.md/) and [AGENTS.md repository](https://github.com/openai/agents.md). Open format overview and examples.

## Markdown sources

- [*CommonMark Spec* version 0.31.2](https://spec.commonmark.org/0.31.2/). Why a spec is needed; conformance-test framing; Markdown as readable plain text.
- [*GitHub Flavored Markdown Spec*](https://github.github.com/gfm/). GFM as a strict superset of CommonMark; post-processing and sanitization.
- [GitHub Docs, *Basic writing and formatting syntax*](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax). Relative links, section links, image syntax and alt text.
- [GitHub Docs, *Creating and highlighting code blocks*](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-and-highlighting-code-blocks). Fenced code blocks, blank-line readability, syntax highlighting.

## HTML and accessibility sources

- [MDN, *`<article>`: The article contents element*](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/article). Self-contained content and heading guidance.
- [MDN, *`lang` HTML global attribute*](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/lang). Programmatically determinable language.
- [MDN, *`aria-hidden` attribute*](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-hidden). Accessibility-tree removal and focusable-element warning.
- [W3C WAI, *Page Structure Tutorial*](https://www.w3.org/WAI/tutorials/page-structure/) and [*Headings*](https://www.w3.org/WAI/tutorials/page-structure/headings/). Structure, navigation, heading ranks, and avoiding skipped levels.
- [W3C WAI, *Images Tutorial*](https://www.w3.org/WAI/tutorials/images/). Purpose-based alt text and null alt for decorative images.
- [W3C WCAG Understanding, *Info and Relationships*](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships) and [*Use of Color*](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html). Preserve semantics across presentations; do not rely on color alone.
- [MDN, *`<meta>`*](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/meta) and [*Viewport meta tag*](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/meta/name/viewport). Character encoding and viewport behavior.
- [W3C Validator help](https://validator.w3.org/docs/help.html) and [Nu Html Checker](https://validator.w3.org/nu/). Validation as syntax checking, not full quality approval.

## Policy-writing and testing sources

- [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174). Requirement levels, sparing use, and uppercase clarification.
- [OpenAI API docs, *Working with evals*](https://platform.openai.com/docs/guides/evals). Explicit criteria and testing as essential to reliable applications.

## Empirical research

- [Lulla et al., *On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents*](https://arxiv.org/abs/2601.20404). Runtime and token reductions associated with `AGENTS.md`.
- [Gloaguen et al., *Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?*](https://arxiv.org/abs/2602.11988). Evidence that overloaded context files can reduce success and increase cost.
- [Galster et al., *Configuring Agentic AI Coding Tools: An Exploratory Study*](https://arxiv.org/abs/2602.14690). Context files dominate configuration; `AGENTS.md` emerging as interoperable standard.
- [Treude, Baltes, and Cheong, *Operationalizing Ethics for AI Agents*](https://arxiv.org/abs/2605.05584). Context files as developer-authored governance layers.
