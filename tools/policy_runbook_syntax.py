"""Parse policy runbook syntax."""

import re
from dataclasses import dataclass

DOC_PROFILE_RE = re.compile(
    r"^<!-- doc-profile: TYPE=policy-runbook, VER=v\d+\.(?:\d+|x) -->$"
)
CODE_RUNME_MARKER_RE = re.compile(
    r"^<!-- not-prose: TYPE=code-runme(?:, WHY=[A-Za-z0-9_-]+)? -->$"
)
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
FENCE_RE = re.compile(r"^\s*(`{3,}|~{3,})(.*)$")


class ContractError(Exception):
    """Raised when a policy runbook does not satisfy the runner contract."""


@dataclass(frozen=True)
class CodeBlock:
    line: int
    source: str


def validate_policy_profile(lines: list[str]) -> None:
    if not lines:
        raise ContractError("policy file is empty")
    if not DOC_PROFILE_RE.match(lines[0]):
        raise ContractError(
            "first line must be "
            "`<!-- doc-profile: TYPE=policy-runbook, VER=v0.x -->` shape"
        )


def heading_level(line: str) -> int:
    match = HEADING_RE.match(line)
    return len(match.group(1)) if match else 0


def find_section_end(lines: list[str], start: int, level: int) -> int:
    for index in range(start, len(lines)):
        current_level = heading_level(lines[index])
        if current_level and current_level <= level:
            return index
    return len(lines)


def fence_language(info: str) -> str:
    stripped = info.strip()
    if not stripped:
        return ""
    return stripped.split()[0].lower()


def is_fence_close(line: str, opener: str) -> bool:
    stripped = line.strip()
    if not stripped.startswith(opener[0]):
        return False
    marker = stripped.split(maxsplit=1)[0]
    return set(marker) == {opener[0]} and len(marker) >= len(opener)


def collect_python_fences(
    lines: list[str],
    start: int,
    end: int,
) -> list[CodeBlock]:
    blocks: list[CodeBlock] = []
    index = start
    while index < end:
        match = FENCE_RE.match(lines[index])
        if not match:
            index += 1
            continue

        opener = match.group(1)
        language = fence_language(match.group(2))
        if language not in {"python", "py"}:
            line_no = index + 1
            found = language or "<none>"
            raise ContractError(
                f"unsupported fence language at line {line_no}: {found}"
            )

        body: list[str] = []
        body_start = index + 2
        index += 1
        while index < end and not is_fence_close(lines[index], opener):
            body.append(lines[index])
            index += 1
        if index >= end:
            raise ContractError(
                f"unclosed Python fence starting at line {body_start}"
            )
        source = "\n".join(body) + "\n"
        blocks.append(CodeBlock(line=body_start, source=source))
        index += 1
    return blocks


def extract_code_runme_blocks(policy_text: str) -> list[CodeBlock]:
    lines = policy_text.splitlines()
    validate_policy_profile(lines)
    blocks: list[CodeBlock] = []
    saw_runme = False

    index = 0
    while index < len(lines):
        if not CODE_RUNME_MARKER_RE.match(lines[index]):
            index += 1
            continue

        saw_runme = True
        marker_line = index + 1
        heading_index = index + 1
        if heading_index >= len(lines) or not HEADING_RE.match(
            lines[heading_index]
        ):
            raise ContractError(
                f"TYPE=code-runme marker at line {marker_line} "
                "must be immediately followed by a heading"
            )

        level = heading_level(lines[heading_index])
        section_end = find_section_end(lines, heading_index + 1, level)
        blocks.extend(
            collect_python_fences(lines, heading_index + 1, section_end)
        )
        index = section_end

    if not saw_runme:
        raise ContractError("no TYPE=code-runme sections found in policy")
    if not blocks:
        raise ContractError(
            "no Python fences found in TYPE=code-runme sections"
        )
    return blocks
