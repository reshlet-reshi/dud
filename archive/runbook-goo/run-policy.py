#!/usr/bin/env python3
"""Execute a policy runbook."""

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path

from policy_runbook_syntax import (
    CodeBlock,
    ContractError,
    extract_code_runme_blocks,
)


@dataclass(frozen=True)
class RunbookContext:
    policy_path: Path
    target_path: Path | None
    output_path: Path | None
    self_test: bool


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


def execute_blocks(blocks: list[CodeBlock], context: RunbookContext) -> int:
    namespace: dict[str, object] = {
        "__name__": "__policy_runbook__",
        "Path": Path,
        "RunbookContext": RunbookContext,
    }
    for block in blocks:
        try:
            code = compile(
                block.source,
                f"<policy-runbook:{block.line}>",
                "exec",
            )
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
