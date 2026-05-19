# Policy.md Skeleton

Back to [Policy Skeleton](../report.md#policy-skeleton).

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
