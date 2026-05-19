# HTML v1/v2 Comparison Matrix

Back to [Comparison Matrix](../research-agent-policy-markdown-html-meta-policy.md#comparison-matrix).

| Topic | v1 | v2 | Judgment |
|---|---|---|---|
| Generated and transient HTML | Implicit | Explicitly says HTML is usually transient and not meant for Git | v2 adds a useful default, but it overstates it. “Usually transient” is workable; “not meant to be checked into Git” is too absolute for docs repos and committed artifacts. |
| Links vs app controls | Allows forms for their real jobs and has an explicit exception section for interactive apps | Says forms, controls, widgets, scripts, and client-side state do not belong in a “document” | v2 is cleaner **if** the scope is strictly “document HTML,” but it removed the exception machinery that made that claim honest. |
| Image policy | Says images need text alternatives when they carry meaning | Says images must carry meaning, must have meaningful alt text, and if alt text is noise omit the image | v1 is closer to WAI guidance. Decorative images can be legitimate with `alt=""`; “images must carry meaning” is too rigid. See [W3C WAI: images tutorial](https://www.w3.org/WAI/tutorials/images/). |
| CSS allowlisting | Principle-based: CSS as enhancement, not requirement for meaning | CSS is last resort; only a tiny allowlist is permitted without amendment | v2’s discipline is admirable but overfit to one aesthetic sample. Better to constrain by outcomes and checks than by two immortal CSS declarations. |
| Checks | Includes validation, text-browser/reader-view readability, narrow-view review, link-following, and source/render story | Keeps checks but drops the richer exception framing and “source spirit” explanation | V1 has the better governance voice. V2 needs stronger distinction between required checks and advisory review heuristics. |
| Amendment flow | Not explicit, but exceptions exist | Says unlisted CSS requires amendment | v2 invokes amendment without defining amendment. That is governance theater until `policy.md` exists. |
