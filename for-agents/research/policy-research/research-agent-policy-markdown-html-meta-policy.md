# Research Agent Policy, Markdown, HTML, and Meta-Policy

## Executive summary

The strongest recommendation is **a small root `AGENTS.md`, plus a separate meta-policy `policy.md`, plus short topic policies such as `markdown.md` and `html.md`**. That structure fits the repo owner’s stated taste for small, direct, readable documents, while also matching how current agent ecosystems actually layer instructions. Official docs from OpenAI Codex, GitHub Copilot, and Claude Code all support repository-local instruction files, path-sensitive scoping, and layered precedence, but they do **not** use identical resolution semantics. The safe cross-tool choice is therefore: keep the root instructions short, keep topic doctrine out of the root unless it applies nearly everywhere, and push narrow rules downward into topic or subtree documents. ([OpenAI Codex: Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md), [GitHub Copilot: repository custom instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions), [Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory), [GitHub Copilot: customizing responses](https://docs.github.com/en/copilot/customizing-copilot/about-customizing-github-copilot-chat-responses))

The most important research disagreement is not whether local agent policy exists, but **how much of it should exist**. Official vendor docs encourage persistent project instructions, and Anthropic explicitly says to store facts the model should hold every session while moving multi-step or narrow-scope procedures into other mechanisms. GitHub says short, self-contained natural-language instructions work best. But recent empirical papers disagree on net benefit: one study found `AGENTS.md` associated with lower median runtime and fewer output tokens, while another found context files can lower task success and increase cost when they are overloaded with unnecessary requirements. The conservative conclusion is: **policy should be minimal, scoped, operational, and testable**. ([Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory), [GitHub Copilot: customizing responses](https://docs.github.com/en/copilot/customizing-copilot/about-customizing-github-copilot-chat-responses), [Lulla et al., *On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents*](https://arxiv.org/abs/2601.20404), [Gloaguen et al., *Evaluating AGENTS.md*](https://arxiv.org/abs/2602.11988), [Galster et al., *Configuring Agentic AI Coding Tools*](https://arxiv.org/abs/2602.14690))

On the local artifacts, the repo’s current instincts are often good, but the execution is uneven. The `bd-*.md` files are useful design notes and value statements, but they are not yet policy because they rarely say **who must do what, where, when, under what exception, and how compliance is checked**. `experiments/bd/BeautifulDocument.html` is a decent specimen page, but it is being asked to carry more policy authority than a single pleasant example can support. `snapshots/html-v1-committed.md` is the better policy seed because it states principles, rules, checks, and exceptions with less dogma. `current/html.md` improves a few operational points, especially around generated/transient HTML, but it also becomes more brittle, more aesthetic in disguise, and less honest about exceptions. The current `AGENTS.md` and `for-agents/research/` layout is the most mature part of the set: it is much closer to a workable policy system, though it still needs a cleaner taxonomy for binding versus advisory documents and a better promotion flow. Local artifacts per `MANIFEST.md`: `current/AGENTS.md`, `current/html.md`, `snapshots/html-v1-committed.md`, `experiments/bd/*`, `current/for-agents/*`, and `current/for-agents/research/*`.

My recommendation is therefore **Scheme B** in the decision matrix below: keep `AGENTS.md` as the binding operational entrypoint for agents, introduce `policy.md` as the short document that explains how policy works in this repo, and keep topic policies narrow and testable. Do **not** turn everything into one giant manifesto. Do **not** let experiments quietly become binding by vibe. Do **not** let HTML taste masquerade as HTML policy. ([OpenAI Codex: Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md), [GitHub Copilot: customizing responses](https://docs.github.com/en/copilot/customizing-copilot/about-customizing-github-copilot-chat-responses), [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119), [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174), [OpenAI: working with evals](https://platform.openai.com/docs/guides/evals))

## Sources and method

I unpacked the supplied archive, used `MANIFEST.md` as the canonical file map, and inspected the local artifacts the prompt named as decisive for this research pass. The local materials reviewed included the root `current/AGENTS.md`; `current/html.md`; `snapshots/html-v1-committed.md`; `experiments/bd/bd-policy.md`; `experiments/bd/bd-design.md`; `experiments/bd/bd-code.md`; `experiments/bd/BeautifulDocument.html`; and the `current/for-agents/` and `current/for-agents/research/` subtree precedent, including `AGENTS-seed-0.md` and `AGENTS-seed-1.md`. These local artifacts are treated here as repo evidence, not as binding truth by themselves.

External research prioritized primary and official sources: OpenAI Codex documentation on `AGENTS.md`; GitHub Copilot documentation on repository instructions, precedence, and path-scoped rules; Anthropic Claude Code documentation on `CLAUDE.md`, scope, and imports; CommonMark and GitHub Flavored Markdown specifications; MDN, WHATWG, and W3C/WAI accessibility guidance for HTML semantics; RFC 2119 and RFC 8174 for normative force language; and the W3C validator documentation. I also used recent empirical papers where they materially informed the tradeoff analysis, especially around the benefits and risks of repository-level context files for coding agents. ([OpenAI Codex: Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md), [GitHub Copilot: repository custom instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions), [Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory), [CommonMark 0.31.2](https://spec.commonmark.org/0.31.2/), [GitHub Flavored Markdown Spec](https://github.github.com/gfm/), [MDN: article element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/article), [W3C WAI: page structure](https://www.w3.org/WAI/tutorials/page-structure/), [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119), [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174), [W3C Validator help](https://validator.w3.org/docs/help.html), [Lulla et al.](https://arxiv.org/abs/2601.20404), [Gloaguen et al.](https://arxiv.org/abs/2602.11988), [Galster et al.](https://arxiv.org/abs/2602.14690))

One limitation matters. I inspected `BeautifulDocument.html` from source and against standards guidance, but I did **not** have a local `lynx` or `tidy` toolchain available in the environment for a live text-browser or validator pass. Where this affects the report, I say so explicitly rather than pretending to have run checks I did not run. That limitation does not materially change the policy conclusions, because the strongest findings here come from the document structure itself and from external standards, but it does mean the critique of rendered behavior is source-based rather than screenshot-based. ([W3C Validator help](https://validator.w3.org/docs/help.html), [W3C WAI: page structure](https://www.w3.org/WAI/tutorials/page-structure/), [WCAG: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships))

## Best practices found

### Agent policy / AGENTS.md

Current agent tooling converges on the idea that repository policy should be layered, local, and close to the work. Codex builds an instruction chain from broader to narrower scope, supports overrides and fallback filenames, and explicitly advises placing overrides as close as possible to specialized work. GitHub Copilot supports repository-wide instructions, path-specific instructions, and agent instructions such as `AGENTS.md`, with relevant instructions layered together and higher-precedence scopes taking priority. Claude Code likewise supports global, user, project, and local instructions, and it says project files should contain build/test commands, standards, architecture, naming conventions, and common workflows. ([OpenAI Codex: Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md), [GitHub Copilot: repository custom instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions), [Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory))

The tools differ in important ways, which means a repo should not assume one universal resolution model. Codex includes at most one instruction file per directory, supports `AGENTS.override.md`, and concatenates files from root to current working directory. Copilot says the nearest `AGENTS.md` in the directory tree takes precedence, but it also layers repository-wide and path-specific instructions. Claude concatenates discovered `CLAUDE.md` files up the directory tree and can also lazy-load subdirectory files when work enters those subtrees. The conservative cross-tool design is therefore: **make root policy portable and short; make nested policy sharply scoped; do not rely on one vendor’s override quirks to convey essential safety or correctness rules**. ([OpenAI Codex: Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md), [GitHub Copilot: repository custom instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions), [Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory))

Official guidance also points the same way on content quality. GitHub says custom instructions are most effective when they are **short, self-contained natural-language statements**, and Anthropic says `CLAUDE.md` should hold the things you would otherwise re-explain every session, while multi-step procedures or one-area-only guidance should move to a skill or path-scoped rule. The emerging open `AGENTS.md` convention similarly frames the file as “a README for agents” and recommends covering project overview, build/test commands, code style, testing, and security considerations, with nested files for subprojects when needed. ([GitHub Copilot: customizing responses](https://docs.github.com/en/copilot/customizing-copilot/about-customizing-github-copilot-chat-responses), [Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory), [AGENTS.md project site](https://agents.md/), [AGENTS.md GitHub repository](https://github.com/openai/agents.md))

The research literature makes the caution sharper. One 2026 study found `AGENTS.md` associated with lower median runtime and lower token use without evident loss of task completion behavior, while another found that context files can reduce success rates and raise costs when they add unnecessary requirements. A large survey also found that context files dominate configuration practice and that `AGENTS.md` is emerging as an interoperable standard, but that more advanced mechanisms are still shallowly adopted. The practical conclusion is not “more policy is better”; it is **“better-targeted policy is better”**. ([Lulla et al., *On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents*](https://arxiv.org/abs/2601.20404), [Gloaguen et al., *Evaluating AGENTS.md*](https://arxiv.org/abs/2602.11988), [Galster et al., *Configuring Agentic AI Coding Tools*](https://arxiv.org/abs/2602.14690), [Treude, Baltes, and Cheong, *Operationalizing Ethics for AI Agents*](https://arxiv.org/abs/2605.05584))

### Markdown policy documents

Markdown is attractive because it stays readable as plain text, but that same informality is why specification discipline matters. CommonMark exists because early Markdown descriptions were ambiguous and implementations diverged in important ways; CommonMark explicitly frames its examples as conformance tests. GitHub Flavored Markdown is a strict superset of CommonMark and adds its own post-processing and sanitization. For durable repo policy, that means a policy should target a clearly named Markdown dialect, avoid edge-case syntax that renders differently across engines, and prefer structures that are obvious in source and predictable in HTML. ([CommonMark 0.31.2](https://spec.commonmark.org/0.31.2/), [GitHub Flavored Markdown Spec](https://github.github.com/gfm/))

GitHub’s own documentation also supports a few durable authoring choices: use relative links for files in the repo because they are more robust for people who clone the repository; use alt text on images; use fenced code blocks with blank lines around them to improve raw readability; and rely on heading-generated anchors for section links instead of ad hoc anchor tricks where possible. Those are small practices, but they matter a lot in policy documents, where broken navigation and ambiguous examples create drift fast. ([GitHub: basic writing and formatting syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax), [GitHub: creating and highlighting code blocks](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-and-highlighting-code-blocks))

### Plain HTML documents

The most stable guidance is semantic and accessibility-first. MDN defines `<article>` as a self-contained composition intended to be independently reusable, and says each article should typically be identified by a heading. W3C’s page-structure guidance says well-structured content improves navigation and orientation, and its headings guidance says headings communicate organization, should be nested by rank, and skipping heading ranks should be avoided where possible. The `lang` attribute should be specified so page language is programmatically determinable. ([MDN: article element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/article), [W3C WAI: page structure](https://www.w3.org/WAI/tutorials/page-structure/), [W3C WAI: headings](https://www.w3.org/WAI/tutorials/page-structure/headings/), [MDN: lang global attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/lang))

Accessibility guidance also clarifies several specific policy questions that appear in the local HTML drafts. W3C says images need text alternatives that match their purpose, and decorative images should use null alt text rather than noisy prose. WCAG guidance says information and relationships conveyed visually should be preserved when presentation changes, and color should not be the only carrier of meaning. MDN says `aria-hidden="true"` removes content from the accessibility tree and should not be used on focusable elements or ancestors of focusable elements. These are concrete, testable rules; they are a much better basis for HTML policy than aesthetic preference. ([W3C WAI: images tutorial](https://www.w3.org/WAI/tutorials/images/), [WCAG: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships), [WCAG: Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html), [MDN: aria-hidden](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-hidden))

Validation belongs in the workflow, but it is not enough by itself. W3C describes validation as a kind of syntax-oriented quality control, “sort of like lint,” and explicitly warns that valid markup is not the same thing as a good page or full conformance. That maps well to repo policy: validating generated HTML is useful; it is not a substitute for checking whether the document remains legible, semantic, navigable, and faithful to its source. ([W3C Validator help](https://validator.w3.org/docs/help.html))

### Policy about policy

Software policy benefits from explicit force language, but the stronger lesson from standards writing is restraint. RFC 2119 and RFC 8174 define the meanings of `MUST`, `SHOULD`, and `MAY`, while also warning that such imperatives should be used sparingly and only when they are actually required. GitHub’s guidance on custom instructions goes in the same direction from a different angle: prefer short, self-contained statements and avoid conflicting instructions where possible. In practice, that means a repo meta-policy should define document classes, force levels, and amendment flow once, so that topic docs can stay concrete instead of re-litigating authority in every file. ([RFC 2119](https://www.rfc-editor.org/rfc/rfc2119), [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174), [GitHub Copilot: customizing responses](https://docs.github.com/en/copilot/customizing-copilot/about-customizing-github-copilot-chat-responses))

Policy also needs a promotion and testing story. Anthropic distinguishes persistent repeated facts from situation-specific skills; OpenAI’s evals documentation says evaluations are an essential component of building reliable applications and frames them around explicit data plus explicit testing criteria. The direct repo analogue is: do not promote a policy rule unless you can name **how it will be checked**, even if the check is only a human review question or a smoke test rather than full automation. ([Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory), [OpenAI: working with evals](https://platform.openai.com/docs/guides/evals))

## Artifact critique

### `experiments/bd/bd-policy.md`

This file has the right intuition and the wrong genre. Its strong line is the core value claim that HTML exists to carry meaning and should remain useful, legible, accessible, small where possible, and readable without decoration. That is a good policy *thesis*. But it is still mostly thesis. It does not define scope, authority, audience, exception handling, or testable checks, and it does not say whether it applies to hand-authored docs, generated previews, committed artifacts, temporary reports, or app-like HTML. A tired agent could quote it; a tired agent could not reliably comply with it. Local artifact: `experiments/bd/bd-policy.md`.

### `experiments/bd/bd-design.md`

This is the most self-aware of the trio about the difference between principles and surface decoration. It correctly separates durable design values from incidental styling choices and is especially good wherever it says some visual choices are “worth keeping” while others are not law. That is exactly the kind of distinction policy needs. But the file is still not policy: it has no verbs of action, no scoping language, no examples of compliant versus non-compliant output, no amendment path, and no checks. It teaches taste; it does not govern behavior. Local artifact: `experiments/bd/bd-design.md`.

### `experiments/bd/bd-code.md`

This one gets nearest to operational doctrine because it notices a real and important property: source should stay close enough to output that humans can predict the render. That is a useful generator-policy principle. But it still stops short of being a governing document. It does not define the allowed abstraction budget, when comments are required, what escaping failures matter most, or how to review a generated document for source/output drift. It is a strong rationale note and a weak executable policy. Local artifact: `experiments/bd/bd-code.md`.

### `experiments/bd/BeautifulDocument.html`

As plain HTML, this is a decent specimen. It has a DOCTYPE, a language declaration, a title, a viewport tag, one obvious `article`, real headings, paragraphs, a list, and ordinary link markup. The source is short, hand-readable, and roughly WYSIWYG from raw file to rendered page. That is real evidence in its favor. Those choices align with standard guidance about semantic structure, headings, language metadata, and independent article-like content. ([MDN: article element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/article), [MDN: lang global attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/lang), [W3C WAI: headings](https://www.w3.org/WAI/tutorials/page-structure/headings/), [W3C Validator help](https://validator.w3.org/docs/help.html))

But as a **seed for policy**, it is over-trusted. It demonstrates one small successful page, not a general HTML contract. It does not show images, tables, code blocks, inline semantics, duplicate visual views, `aria-hidden` usage, committed-versus-generated workflow, or Markdown-to-HTML conversion edge cases. It also quietly bakes in aesthetic choices that later documents should not mistake for law: card framing, shadow, radius, muted page background, a specific typographic mix, and a colored link style. Those may be fine in the specimen. They are not evidence that they belong in policy. Because the file is a successful example, it is tempting to reverse-engineer a constitution from it. That temptation should be resisted. A specimen is not a standard. Local artifact: `experiments/bd/BeautifulDocument.html`. ([WCAG: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships), [WCAG: Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html), [MDN: aria-hidden](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-hidden))

### `snapshots/html-v1-committed.md` versus `current/html.md`

The short version is: **v2 is stricter, but not consistently clearer; it is more operational in a few places and more dogmatic in several others.** V1 reads like a policy draft. V2 often reads like a reaction to a policy draft. V1 states principles, rules, checks, and exceptions in a way that still admits the existence of interactive HTML. V2 narrows the scope toward transient generated documents, but then smuggles in stylistic bans and absolutes that are too brittle for a general document policy. Local artifacts: `snapshots/html-v1-committed.md`, `current/html.md`.

| Topic | v1 | v2 | Judgment |
|---|---|---|---|
| Generated and transient HTML | Implicit | Explicitly says HTML is usually transient and not meant for Git | v2 adds a useful default, but it overstates it. “Usually transient” is workable; “not meant to be checked into Git” is too absolute for docs repos and committed artifacts. |
| Links vs app controls | Allows forms for their real jobs and has an explicit exception section for interactive apps | Says forms, controls, widgets, scripts, and client-side state do not belong in a “document” | v2 is cleaner **if** the scope is strictly “document HTML,” but it removed the exception machinery that made that claim honest. |
| Image policy | Says images need text alternatives when they carry meaning | Says images must carry meaning, must have meaningful alt text, and if alt text is noise omit the image | v1 is closer to WAI guidance. Decorative images can be legitimate with `alt=""`; “images must carry meaning” is too rigid. See [W3C WAI: images tutorial](https://www.w3.org/WAI/tutorials/images/). |
| CSS allowlisting | Principle-based: CSS as enhancement, not requirement for meaning | CSS is last resort; only a tiny allowlist is permitted without amendment | v2’s discipline is admirable but overfit to one aesthetic sample. Better to constrain by outcomes and checks than by two immortal CSS declarations. |
| Checks | Includes validation, text-browser/reader-view readability, narrow-view review, link-following, and source/render story | Keeps checks but drops the richer exception framing and “source spirit” explanation | V1 has the better governance voice. V2 needs stronger distinction between required checks and advisory review heuristics. |
| Amendment flow | Not explicit, but exceptions exist | Says unlisted CSS requires amendment | v2 invokes amendment without defining amendment. That is governance theater until `policy.md` exists. |

The single biggest substantive error in v2 is that it tries to solve governance gaps by adding content bans and tiny allowlists. That creates brittle rules that future maintainers will either ignore or keep amending around. The single biggest strength in v2 is that it notices an important scoping question: generated display HTML is not the same thing as an HTML application. That distinction belongs in the future system, but it belongs in a cleaner form. V1 is the better conceptual baseline; v2 contains a few operational clarifications worth salvaging; neither is ready to be the durable policy as written. ([W3C Validator help](https://validator.w3.org/docs/help.html), [WCAG: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships), [WCAG: Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html))

### Current `AGENTS.md` and `for-agents/research/` precedent

This is the healthiest part of the repo’s policy thinking. The root `current/AGENTS.md` is recognizably a binding operational document: it states that it applies to the entire repository, tells the agent to read nearer `AGENTS.md` files, and distinguishes binding local policy from historical archives. The subtree docs under `current/for-agents/` and `current/for-agents/research/` do something even more important: they make a clean distinction between **advisory evidence** and **binding policy**, and they already encode a promotion idea — research artifacts preserve question, source basis, and recommendation, but become policy only when promoted into reviewed policy or project docs. That is exactly the right direction. Local artifacts: `current/AGENTS.md`, `current/for-agents/README.md`, `current/for-agents/research/AGENTS.md`, `current/for-agents/research/README.md`.

The weakness is structural, not philosophical. The root `AGENTS.md` is doing too many jobs at once: workflow rules, ambient-policy duplication, generated document guidance, and links into subtree conventions. That is manageable today because the repo is still small. It will become a catch-all if topic doctrine keeps accreting there. The research precedent also needs one more piece of formalism: a standard status/provenance block on each artifact, so future promotions can point back to a stable research record without forcing readers to reverse-engineer whether something is historical, draft, accepted, or superseded. The seeds already demonstrate the shape of good preservation: question, assumptions, coherent option sets, decision matrix, ballot, and sources. The system now needs a proper policy ladder above that evidence layer. ([OpenAI Codex: Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md), [Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory))

## Proposed policy-management scheme

The recommended scheme is a **three-layer policy system**.

First, keep **root `AGENTS.md`** as the binding operational entrypoint for coding agents. Its job is to answer the immediate agent questions: what binds here, where do narrower rules live, what workflow rules always matter, what files are advisory versus historical, and what the agent must check before editing. It should stay small enough that an agent can load it every session without paying a comprehension tax. This matches official agent-tool guidance and avoids the context-file overload that recent research warns about. ([OpenAI Codex: Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md), [GitHub Copilot: customizing responses](https://docs.github.com/en/copilot/customizing-copilot/about-customizing-github-copilot-chat-responses), [Gloaguen et al., *Evaluating AGENTS.md*](https://arxiv.org/abs/2602.11988), [Lulla et al., *On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents*](https://arxiv.org/abs/2601.20404))

Second, add **root `policy.md`** as the short meta-policy. This file should not contain HTML doctrine or Markdown specifics. Its job is to define the repo’s policy system itself: document classes, force vocabulary, required anatomy of a policy file, duplication rules, promotion flow, review/testing expectations, and citation/provenance requirements when research is promoted. In other words, `policy.md` should answer “how policy works here,” so that `html.md`, `markdown.md`, and future topic files can just govern their topic. This is the missing piece in the current repo. It turns “policy vibes” into a reusable grammar.

Third, keep **topic policies** such as `markdown.md`, `html.md`, and `language.md` narrow, testable, and explicitly scoped. Each topic policy should say who it binds, what artifacts it applies to, what counts as a rule versus a preference versus rationale, what checks apply, and what exceptions exist. Topic docs should not restate the whole amendment process or the whole status taxonomy; they should import that meta-governance from `policy.md`. That keeps them small and direct.

This scheme also needs explicit document classes. I recommend four labels, used consistently in a short status block near the top of each governed file:

- **Binding**: enforceable project policy.
- **Advisory**: guidance that informs work but does not bind by itself.
- **Experimental**: sketches, examples, prompts, or candidate ideas not yet promoted.
- **Historical**: preserved records that explain past decisions but are not live doctrine.

That taxonomy is already implicit in `for-agents/research/`; it should become explicit repo-wide.

For multi-tool compatibility, the repo should choose **one canonical shared policy surface** and make other tool-specific files thin adapters. If `AGENTS.md` is canonical, then Claude should import or symlink it from `CLAUDE.md` when needed, exactly as Anthropic documents; Copilot-specific `.github/copilot-instructions.md` should be used only for Copilot-specific supplements or scoped hints, not as a second full constitution. The goal is one truth, many adapters — not one repo, three contradictory instruction systems. ([Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory), [GitHub Copilot: repository custom instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions), [OpenAI Codex: Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md))

Finally, promotion should be explicit. A local experiment does **not** become policy because it is pretty, persuasive, or was once useful in a prompt. Promotion should require a named decision, a cited research basis, and at least one concrete check. The repo already has the beginnings of this in `for-agents/research/`; `policy.md` should finish the job.

## Proposed shape for `policy.md`

`policy.md` should be short and concrete. It should look more like a constitution for repo policy management than like a style guide. It should probably stay under roughly one screenful per major section, with no topic-specific rabbit holes.

A good shape would be:

```text
# Policy System

Status: Binding
Scope: Repository-wide policy documents and their promotion
Audience: Humans and coding agents
Authority: Root policy governance for this repository
Related docs: AGENTS.md, markdown.md, html.md, for-agents/research/
Last reviewed: YYYY-MM-DD

## Purpose
What this file is for, and what it is not for.

## Document classes
Binding
Advisory
Experimental
Historical

## Where rules live
What belongs in root AGENTS.md
What belongs in policy.md
What belongs in topic policies
What belongs in subtree AGENTS.md files
What belongs in research and experiments

## Force and labeling
How to write rules
How to write preferences
How to write rationale
How to write examples
How to write checks
How to write exceptions
Optional BCP 14 language if used

## Required anatomy of a binding policy
Scope
Intent
Principles
Rules
Checks
Exceptions
Amendment
Status / provenance

## Duplication rules
When duplication with ambient/tool policy is useful
When duplication is harmful
How duplicate rules must justify themselves

## Promotion flow
How research or experiments become binding policy
Review expectations
What evidence must be cited
How supersession is recorded

## Testing and review
What kinds of checks are acceptable
When a human review question is enough
When a runnable check is expected

## Amendment flow
Who can amend
What changes need addenda
How changes are announced and linked
```

A few content choices inside that shape matter more than the headings.

**What belongs in root `AGENTS.md` versus `policy.md` versus topic policies.**  
Root `AGENTS.md` should contain only high-frequency operational rules and routing instructions: instruction precedence, required pre-edit checks, where nested policies live, branch/workflow rules, and a short status legend. `policy.md` should define the governance model. Topic policies should hold substantive doctrine for one subject area. If a rule is about “how policy works,” it belongs in `policy.md`. If it is about “how to write HTML documents,” it belongs in `html.md`. If it is about “what this agent must always do before editing anything,” it belongs in root `AGENTS.md`.

**How binding and advisory documents should be labeled.**  
Every policy-adjacent document should declare status near the top. That is better than relying on directory name alone. Example labels should be plain-English and visible to both humans and agents: `Status: Binding`, `Status: Advisory`, `Status: Experimental`, `Status: Historical`.

**How a policy should state scope, intent, principles, rules, checks, exceptions, and amendment flow.**  
This is the single biggest local gap. A binding policy should never force the reader to infer whether a sentence is law, explanation, or taste. The future standard should require explicit section labels or prefixes. For small readable docs, I recommend using visible labels such as **Rule**, **Preference**, **Rationale**, **Example**, **Check**, and **Exception**, rather than turning the prose into a forest of capitalized RFC verbs. If you do want RFC-style force language, define it once in `policy.md` using BCP 14 and use it sparingly. ([RFC 2119](https://www.rfc-editor.org/rfc/rfc2119), [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174))

**How much duplication with ambient or tool policy is useful.**  
Some duplication is useful when it removes ambiguity during actual repo work. The current root `AGENTS.md` is right to duplicate a few session-adjacent constraints when they are operationally important for this repo. But duplication should be deliberate and justified. A good rule for `policy.md` would be: duplicate ambient/tool constraints only when the duplicate changes agent behavior in this repo or reduces a likely local failure mode. Otherwise, point rather than repeat.

**How to distinguish rules, preferences, examples, and rationale.**  
Never leave this to tone. A future reader should be able to skim the doc and extract only the binding parts. The simplest format is a short section structure plus prefixed lines where needed:

- `Rule:` direct imperative
- `Preference:` taste or default
- `Rationale:` why the rule exists
- `Example:` non-binding illustration
- `Check:` how to review or test
- `Exception:` allowed carve-out and conditions

**How policy should stay readable by humans and useful to agents.**  
The empirical and official guidance agree on the broad direction: keep statements short, self-contained, and scoped to the place they matter. Put a policy near the artifacts it governs when locality helps. Do not write one mega-file that tries to preload a whole worldview into every session. Use root docs as indexes and routers; use topic docs as doctrine; use research docs as evidence. ([GitHub Copilot: customizing responses](https://docs.github.com/en/copilot/customizing-copilot/about-customizing-github-copilot-chat-responses), [Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory), [OpenAI Codex: Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md), [Gloaguen et al., *Evaluating AGENTS.md*](https://arxiv.org/abs/2602.11988))

**How policy should be tested or reviewed before promotion.**  
Every candidate binding rule should ship with at least one named check. For `html.md`, checks may include validation, heading/order inspection, keyboard/focus inspection where relevant, text-browser or text-extraction review, narrow-width review, and link checking. For `markdown.md`, checks may include render parity under the target engine, correct relative links, working intra-doc anchors, and source readability. For agent docs, checks may include a dry-run such as asking the tool to list active instruction sources or summarize loaded instructions. Where deeper reliability matters, use small eval-style test sets and explicit criteria, because reliable systems need explicit tests, not just plausible prose. ([W3C Validator help](https://validator.w3.org/docs/help.html), [OpenAI: working with evals](https://platform.openai.com/docs/guides/evals), [OpenAI Codex: Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md), [Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory))

**How research artifacts should be cited when policy is promoted.**  
Do not dump a bibliography into the middle of every binding policy. Instead, require a short provenance note in the policy header or amendment section, such as “Promoted from `for-agents/research/<artifact>.md` after review on YYYY-MM-DD.” If a specific rule came from a specific finding, that can be named in an amendment note or decision log. This preserves traceability without making the live policy unreadable.

## Decision matrix, recommended next steps, and owner decision ballot

### Decision matrix

| Scheme | Summary | Strengths | Risks | Fit for this repo |
|---|---|---|---|---|
| **Minimal root `AGENTS.md` plus topic docs** | Keep root `AGENTS.md` short and binding; put doctrine directly into `html.md`, `markdown.md`, etc.; no separate meta-policy. | Lowest ceremony, easy to explain, keeps docs small. | Status drift, inconsistent force language, ad hoc amendment flow, experiments can still blur into policy. | Good only if the repo stays very small and disciplined. |
| **Root `AGENTS.md` plus meta `policy.md` plus topic policies** | Root routes and governs agent behavior; `policy.md` defines how policy works; topic docs hold substantive rules. | Best balance of clarity, scalability, and readability; clean promotion path; easier to preserve research without bloating root docs. | One extra file to maintain; requires discipline to keep `policy.md` meta-only. | **Best fit now. Recommended.** |
| **Policy bundle with explicit status labels and promotion flow** | A more formal family of policy docs, possibly in a dedicated policy directory, with explicit statuses, index, amendment log, and decision records. | Strongest long-term governance; best for multi-subtree or multi-team repos; easiest to audit. | More ceremony and navigation overhead; may feel heavy for a small repo with strong owner taste for directness. | Good if the repo grows or more policies accumulate. |

The recommendation is **Scheme B**. It captures what is already working in the repo — local layering, preserved research, reviewed promotion — while solving the current weak point, which is the absence of a coherent meta-policy. It is also the conservative choice given the research disagreement on context-file bloat: it avoids turning the root instructions into a giant policy warehouse. ([OpenAI Codex: Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md), [Claude Code: memory](https://docs.anthropic.com/en/docs/claude-code/memory), [GitHub Copilot: customizing responses](https://docs.github.com/en/copilot/customizing-copilot/about-customizing-github-copilot-chat-responses), [Gloaguen et al., *Evaluating AGENTS.md*](https://arxiv.org/abs/2602.11988), [Lulla et al., *On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents*](https://arxiv.org/abs/2601.20404))

### Recommended next steps

First, formally adopt the document taxonomy in principle: binding, advisory, experimental, historical. This can be a decision before any file rewrites.

Second, make one narrow governance move before any topic rewrite: draft `policy.md` as **meta-policy only**. Do not put HTML rules into it. Do not rewrite `AGENTS.md` yet. Define the system first.

Third, treat `snapshots/html-v1-committed.md` as the better conceptual base for future HTML policy, and salvage only selected operational clarifications from `current/html.md`, especially the distinction between document HTML and application HTML. Do **not** inherit v2’s tiny CSS allowlist or decorative-image hostility unchanged.

Fourth, keep `experiments/bd/*` explicitly experimental. They are good seeds and examples. They are not binding policy candidates without a promotion pass.

Fifth, once `policy.md` exists, pilot the promotion flow on **one** topic only, preferably `html.md`. That will force the repo to prove whether the meta-policy is usable before more policy mass accumulates.

### Owner decision ballot

The smallest set of high-impact choices is:

- **Should root `AGENTS.md` remain a terse operational router, or should it continue to contain topic doctrine?**  
  My recommendation: router only, with short always-on rules.

- **Do you want a separate `policy.md` that defines how policy works in the repo?**  
  My recommendation: yes.

- **Should committed HTML be allowed as a durable artifact when it has a clear purpose, or should HTML be transient by default with explicit carve-outs?**  
  My recommendation: transient by default, committed by explicit purpose and scope.

- **Do you want binding policies to use visible labels such as Rule / Preference / Rationale / Check / Exception, rather than relying on tone?**  
  My recommendation: yes.

- **Should policy promotion require a named research artifact or decision note plus at least one concrete check?**  
  My recommendation: yes.

## Sources

### Official agent-policy sources

- [OpenAI Developers, *Custom instructions with AGENTS.md*](https://developers.openai.com/codex/guides/agents-md). Discovery order, overrides, fallback filenames, and verification guidance.
- [GitHub Docs, *Adding repository custom instructions for GitHub Copilot*](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions). Repository-wide, path-specific, and agent instructions; nearest `AGENTS.md` precedence.
- [GitHub Docs, *About customizing GitHub Copilot responses*](https://docs.github.com/en/copilot/customizing-copilot/about-customizing-github-copilot-chat-responses). Precedence order, short self-contained statements, and scope selection.
- [Anthropic Claude Code Docs, *How Claude remembers your project*](https://docs.anthropic.com/en/docs/claude-code/memory). When to add `CLAUDE.md`, what belongs there, scope levels, imports from `AGENTS.md`, and load order.
- [AGENTS.md project site](https://agents.md/) and [AGENTS.md repository](https://github.com/openai/agents.md). Open format overview and examples.

### Markdown sources

- [*CommonMark Spec* version 0.31.2](https://spec.commonmark.org/0.31.2/). Why a spec is needed; conformance-test framing; Markdown as readable plain text.
- [*GitHub Flavored Markdown Spec*](https://github.github.com/gfm/). GFM as a strict superset of CommonMark; post-processing and sanitization.
- [GitHub Docs, *Basic writing and formatting syntax*](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax). Relative links, section links, image syntax and alt text.
- [GitHub Docs, *Creating and highlighting code blocks*](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-and-highlighting-code-blocks). Fenced code blocks, blank-line readability, syntax highlighting.

### HTML and accessibility sources

- [MDN, *`<article>`: The article contents element*](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/article). Self-contained content and heading guidance.
- [MDN, *`lang` HTML global attribute*](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/lang). Programmatically determinable language.
- [MDN, *`aria-hidden` attribute*](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-hidden). Accessibility-tree removal and focusable-element warning.
- [W3C WAI, *Page Structure Tutorial*](https://www.w3.org/WAI/tutorials/page-structure/) and [*Headings*](https://www.w3.org/WAI/tutorials/page-structure/headings/). Structure, navigation, heading ranks, and avoiding skipped levels.
- [W3C WAI, *Images Tutorial*](https://www.w3.org/WAI/tutorials/images/). Purpose-based alt text and null alt for decorative images.
- [W3C WCAG Understanding, *Info and Relationships*](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships) and [*Use of Color*](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html). Preserve semantics across presentations; do not rely on color alone.
- [MDN, *`<meta>`*](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/meta) and [*Viewport meta tag*](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/meta/name/viewport). Character encoding and viewport behavior.
- [W3C Validator help](https://validator.w3.org/docs/help.html) and [Nu Html Checker](https://validator.w3.org/nu/). Validation as syntax checking, not full quality approval.

### Policy-writing and testing sources

- [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174). Requirement levels, sparing use, and uppercase clarification.
- [OpenAI API docs, *Working with evals*](https://platform.openai.com/docs/guides/evals). Explicit criteria and testing as essential to reliable applications.

### Empirical research

- [Lulla et al., *On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents*](https://arxiv.org/abs/2601.20404). Runtime and token reductions associated with `AGENTS.md`.
- [Gloaguen et al., *Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?*](https://arxiv.org/abs/2602.11988). Evidence that overloaded context files can reduce success and increase cost.
- [Galster et al., *Configuring Agentic AI Coding Tools: An Exploratory Study*](https://arxiv.org/abs/2602.14690). Context files dominate configuration; `AGENTS.md` emerging as interoperable standard.
- [Treude, Baltes, and Cheong, *Operationalizing Ethics for AI Agents*](https://arxiv.org/abs/2605.05584). Context files as developer-authored governance layers.
