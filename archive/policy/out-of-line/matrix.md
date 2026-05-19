# Scheme Comparison Matrix

Back to [Scheme Comparison](../report.md#scheme-comparison).

| Scheme | Summary | Strengths | Risks | Fit for this repo |
|---|---|---|---|---|
| **Minimal root `AGENTS.md` plus topic docs** | Keep root `AGENTS.md` short and binding; put doctrine directly into `html.md`, `markdown.md`, etc.; no separate meta-policy. | Lowest ceremony, easy to explain, keeps docs small. | Status drift, inconsistent force language, ad hoc amendment flow, experiments can still blur into policy. | Good only if the repo stays very small and disciplined. |
| **Root `AGENTS.md` plus meta `policy.md` plus topic policies** | Root routes and governs agent behavior; `policy.md` defines how policy works; topic docs hold substantive rules. | Best balance of clarity, scalability, and readability; clean promotion path; easier to preserve research without bloating root docs. | One extra file to maintain; requires discipline to keep `policy.md` meta-only. | **Best fit now. Recommended.** |
| **Policy bundle with explicit status labels and promotion flow** | A more formal family of policy docs, possibly in a dedicated policy directory, with explicit statuses, index, amendment log, and decision records. | Strongest long-term governance; best for multi-subtree or multi-team repos; easiest to audit. | More ceremony and navigation overhead; may feel heavy for a small repo with strong owner taste for directness. | Good if the repo grows or more policies accumulate. |
