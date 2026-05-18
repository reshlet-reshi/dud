#!/usr/bin/env python3
"""Run executable sections from a policy runbook."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


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
class RunbookContext:
    policy_path: Path
    target_path: Path | None
    output_path: Path | None
    self_test: bool


@dataclass(frozen=True)
class CodeBlock:
    line: int
    source: str


def repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def resolve_from_root(path: str | None) -> Path | None:
    if path is None:
        return None
    candidate = Path(path)
    if candidate.is_absolute():
        return candidate
    return repo_root() / candidate


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run marked executable sections from a policy runbook."
    )
    parser.add_argument("--policy", required=True, help="policy runbook path")
    parser.add_argument("--file", help="target file path for scan mode")
    parser.add_argument("--output", help="report output path for scan mode")
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="run the policy runbook self-test entrypoint",
    )
    args = parser.parse_args()

    if args.self_test and (args.file or args.output):
        parser.error("--self-test cannot be combined with --file or --output")
    if not args.self_test and (not args.file or not args.output):
        parser.error("scan mode requires both --file and --output")
    return args


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
            raise ContractError(f"unclosed Python fence starting at line {body_start}")
        blocks.append(CodeBlock(line=body_start, source="\n".join(body) + "\n"))
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
        if heading_index >= len(lines) or not HEADING_RE.match(lines[heading_index]):
            raise ContractError(
                f"TYPE=code-runme marker at line {marker_line} "
                "must be immediately followed by a heading"
            )

        level = heading_level(lines[heading_index])
        section_end = find_section_end(lines, heading_index + 1, level)
        blocks.extend(collect_python_fences(lines, heading_index + 1, section_end))
        index = section_end

    if not saw_runme:
        raise ContractError("no TYPE=code-runme sections found in policy")
    if not blocks:
        raise ContractError("no Python fences found in TYPE=code-runme sections")
    return blocks


def execute_blocks(blocks: list[CodeBlock], context: RunbookContext) -> int:
    namespace: dict[str, object] = {
        "__name__": "__policy_runbook__",
        "Path": Path,
        "RunbookContext": RunbookContext,
    }
    for block in blocks:
        try:
            code = compile(block.source, f"<policy-runbook:{block.line}>", "exec")
            exec(code, namespace)
        except Exception as exc:
            raise ContractError(
                f"failed to execute runbook code at line {block.line}: {exc}"
            ) from exc

    entrypoint = namespace.get("runbook_main")
    if not callable(entrypoint):
        raise ContractError("runbook code must define runbook_main(context)")

    result = entrypoint(context)
    if result is None:
        return 0
    if isinstance(result, int):
        return result
    raise ContractError("runbook_main(context) must return None or an integer")


def main() -> int:
    args = parse_args()
    policy_path = resolve_from_root(args.policy)
    target_path = resolve_from_root(args.file)
    output_path = resolve_from_root(args.output)
    assert policy_path is not None

    context = RunbookContext(
        policy_path=policy_path,
        target_path=target_path,
        output_path=output_path,
        self_test=args.self_test,
    )

    try:
        policy_text = policy_path.read_text(encoding="utf-8")
        blocks = extract_code_runme_blocks(policy_text)
        return execute_blocks(blocks, context)
    except ContractError as exc:
        print(f"contract error: {exc}", file=sys.stderr)
        return 2
    except OSError as exc:
        print(f"contract error: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
