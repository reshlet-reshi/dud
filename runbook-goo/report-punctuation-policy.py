#!/usr/bin/env python3
"""Report punctuation-policy findings for a Markdown file."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
import textwrap
import unittest
from collections import Counter
from dataclasses import dataclass
from pathlib import Path


DEFAULT_TARGET = (
    "for-agents/research/policy-research/"
    "research-agent-policy-markdown-html-meta-policy.md"
)
DEFAULT_OUTPUT = ".tmp/punctuation-policy-report.md"
DEFAULT_MAX_LENGTH = 79

LINK_RE = re.compile(r"!?\[([^\]\n]*)\]\(([^\)\n]*)\)")
INLINE_CODE_RE = re.compile(r"`([^`\n]*)`")
RAW_URL_RE = re.compile(r"https?://\S+")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*?)\s*$")
BULLET_RE = re.compile(r"^(\s*)[*+-]\s+")
FENCE_RE = re.compile(r"^\s*(```+|~~~+)")
TABLE_RE = re.compile(r"^\s*\|")
RAW_HTML_RE = re.compile(r"^\s*</?[A-Za-z][^>]*>\s*$")
MARKER_LIKE_RE = re.compile(r"^<!--\s*not-prose:")
MARKER_RE = re.compile(
    r"^<!-- not-prose: TYPE=(?P<type>code|table|html), "
    r"WHY=(?P<why>[A-Za-z0-9_-]+) -->$"
)


@dataclass(frozen=True)
class Finding:
    category: str
    line: int
    visible_length: int
    punctuation_class: str
    suggestion: str
    preview: str


@dataclass(frozen=True)
class Marker:
    line: int
    parent_level: int
    marker_type: str | None
    valid: bool


@dataclass(frozen=True)
class NotProseSection:
    level: int
    marker_type: str


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def resolve_from_root(path: str) -> Path:
    candidate = Path(path)
    if candidate.is_absolute():
        return candidate
    return repo_root() / candidate


def display_path(path: Path) -> str:
    try:
        return path.relative_to(repo_root()).as_posix()
    except ValueError:
        return path.as_posix()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Report punctuation-policy findings without editing files."
    )
    parser.add_argument(
        "--file",
        default=DEFAULT_TARGET,
        help=f"Markdown file to scan (default: {DEFAULT_TARGET})",
    )
    parser.add_argument(
        "--output",
        default=DEFAULT_OUTPUT,
        help=f"report output path (default: {DEFAULT_OUTPUT})",
    )
    parser.add_argument(
        "--max-length",
        type=int,
        default=DEFAULT_MAX_LENGTH,
        help=f"maximum preferred visible length (default: {DEFAULT_MAX_LENGTH})",
    )
    parser.add_argument(
        "--self-test",
        action="store_true",
        help="run the embedded unittest suite and exit",
    )
    return parser.parse_args()


def visible_text(markdown: str) -> str:
    text = LINK_RE.sub(lambda match: match.group(1), markdown)
    text = INLINE_CODE_RE.sub(lambda match: match.group(1), text)
    text = re.sub(r"[*_]", "", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def punctuation_text(markdown: str) -> str:
    text = LINK_RE.sub(lambda match: match.group(1), markdown)
    text = RAW_URL_RE.sub("URL", text)

    def scrub_code(match: re.Match[str]) -> str:
        return re.sub(r"[:,;]", " ", match.group(1))

    text = INLINE_CODE_RE.sub(scrub_code, text)
    return text


def punctuation_class(markdown: str) -> str:
    text = punctuation_text(markdown)
    delimiters = []
    if ":" in text:
        delimiters.append("colon")
    if ";" in text:
        delimiters.append("semicolon")
    if "," in text:
        delimiters.append("comma")
    return "+".join(delimiters) if delimiters else "none"


def length_category(punct_class: str) -> str:
    parts = set(punct_class.split("+")) if punct_class != "none" else set()
    if not parts:
        return "Long no-delimiter sentence"
    if parts == {"comma"}:
        return "Long comma-only sentence"
    if parts == {"colon"}:
        return "Long colon sentence"
    if parts == {"semicolon"}:
        return "Long semicolon sentence"
    return "Mixed delimiter sentence"


def heading_text(line: str) -> str:
    match = HEADING_RE.match(line)
    return match.group(2).strip() if match else ""


def heading_level(line: str) -> int:
    match = HEADING_RE.match(line)
    return len(match.group(1)) if match else 0


def is_blank(line: str) -> bool:
    return not line.strip()


def is_heading(line: str) -> bool:
    return HEADING_RE.match(line) is not None


def is_bullet(line: str) -> bool:
    return BULLET_RE.match(line) is not None


def is_marker_like(line: str) -> bool:
    return MARKER_LIKE_RE.match(line) is not None


def is_comment(line: str) -> bool:
    stripped = line.strip()
    return stripped.startswith("<!--") and stripped.endswith("-->")


def is_table_line(line: str) -> bool:
    return TABLE_RE.match(line) is not None


def is_raw_html_line(line: str) -> bool:
    return RAW_HTML_RE.match(line) is not None and not is_comment(line)


def is_fence_line(line: str) -> bool:
    return FENCE_RE.match(line) is not None


def is_prose_line(line: str) -> bool:
    return (
        bool(line.strip())
        and not is_heading(line)
        and not is_bullet(line)
        and not is_marker_like(line)
        and not is_comment(line)
        and not is_fence_line(line)
        and not is_table_line(line)
        and not is_raw_html_line(line)
    )


def preview(text: str, limit: int = 220) -> str:
    clean = re.sub(r"\s+", " ", text).strip()
    if len(clean) <= limit:
        return clean
    return clean[: limit - 3].rstrip() + "..."


def make_finding(category: str, line: int, raw: str, suggestion: str) -> Finding:
    visible = visible_text(raw)
    return Finding(
        category=category,
        line=line,
        visible_length=len(visible),
        punctuation_class=punctuation_class(raw),
        suggestion=suggestion,
        preview=preview(visible),
    )


def see_heading(parent_level: int) -> str:
    level = min(max(parent_level + 1, 2), 6)
    return f"{'#' * level} See"


def suggestion_for(category: str, punct_class: str, parent_level: int = 0) -> str:
    if category == "Old `See:` citation paragraph":
        return (
            f"Replace with `{see_heading(parent_level)}` and one Markdown link "
            "per bullet."
        )
    if category == "Inline prose link":
        return "Move the link into a citation block or standalone asset block."
    if category == "Long no-delimiter sentence":
        return "Rewrite by hand into multiple shorter sentences."
    if category == "Long comma-only sentence":
        return (
            "Convert true comma lists to Markdown bullets; otherwise split or "
            "rewrite the sentence."
        )
    if category == "Long colon sentence":
        return "Extract the lead-in into structure, then move introduced material."
    if category == "Long semicolon sentence":
        return "Split semicolon clauses into sentences, paragraphs, or list items."
    if category == "Soft-wrapped prose paragraph":
        return "Separate prose lines with `\\n\\n` or rewrite as one short line."
    if category == "Multiline list item":
        return "Convert continuation text to nested one-line bullets or restructure."
    if category == "Unmarked fenced code block":
        return "Move the fence under a marked `TYPE=code` not-prose section."
    if category == "Unmarked Markdown table":
        return "Move the table under a marked `TYPE=table` not-prose section."
    if category == "Unmarked raw HTML block":
        return "Move the HTML under a marked `TYPE=html` not-prose section."
    if category == "Invalid `not-prose` marker":
        return "Use `<!-- not-prose: TYPE=code, WHY=example-token -->` shape."
    if category == "`not-prose` marker not immediately followed by a heading":
        return "Place the marker immediately before the not-prose section heading."
    if category == "`not-prose` heading not one level below its parent heading":
        return "Make the not-prose heading exactly one level below its parent."

    advice = []
    if "colon" in punct_class:
        advice.append("extract colon-introduced material into structure")
    if "semicolon" in punct_class:
        advice.append("split semicolon clauses")
    if "comma" in punct_class:
        advice.append("convert true comma lists to Markdown lists or rewrite")
    return "; ".join(advice) + "."


def note_finding(
    findings: list[Finding],
    *,
    category: str,
    line: int,
    raw: str,
    parent_level: int = 0,
) -> None:
    findings.append(
        make_finding(
            category,
            line,
            raw,
            suggestion_for(category, punctuation_class(raw), parent_level),
        )
    )


def not_prose_kind(line: str) -> str | None:
    if is_fence_line(line):
        return "code"
    if is_table_line(line):
        return "table"
    if is_raw_html_line(line):
        return "html"
    return None


def is_allowed_not_prose(kind: str, section: NotProseSection | None) -> bool:
    return section is not None and section.marker_type == kind


def scan_text(text: str, max_length: int = DEFAULT_MAX_LENGTH) -> list[Finding]:
    findings: list[Finding] = []
    lines = text.splitlines()
    current_heading_level = 0
    current_heading_text = ""
    active_not_prose: NotProseSection | None = None
    pending_marker: Marker | None = None
    in_fence = False
    fence_marked = False

    for index, line in enumerate(lines):
        line_no = index + 1
        next_line = lines[index + 1] if index + 1 < len(lines) else ""

        marker_match = MARKER_RE.match(line)
        if is_marker_like(line):
            if not marker_match:
                note_finding(
                    findings,
                    category="Invalid `not-prose` marker",
                    line=line_no,
                    raw=line,
                    parent_level=current_heading_level,
                )
                pending_marker = Marker(line_no, current_heading_level, None, False)
            else:
                pending_marker = Marker(
                    line=line_no,
                    parent_level=current_heading_level,
                    marker_type=marker_match.group("type"),
                    valid=True,
                )
            if not HEADING_RE.match(next_line):
                note_finding(
                    findings,
                    category="`not-prose` marker not immediately followed by a heading",
                    line=line_no,
                    raw=line,
                    parent_level=current_heading_level,
                )
            continue

        if is_heading(line):
            level = heading_level(line)
            if active_not_prose is not None and level <= active_not_prose.level:
                active_not_prose = None

            if pending_marker is not None and pending_marker.line == line_no - 1:
                expected_level = pending_marker.parent_level + 1
                if level != expected_level:
                    note_finding(
                        findings,
                        category=(
                            "`not-prose` heading not one level below its parent heading"
                        ),
                        line=line_no,
                        raw=line,
                        parent_level=pending_marker.parent_level,
                    )
                if pending_marker.valid and pending_marker.marker_type is not None:
                    active_not_prose = NotProseSection(
                        level=level,
                        marker_type=pending_marker.marker_type,
                    )
                pending_marker = None
            else:
                pending_marker = None

            current_heading_level = level
            current_heading_text = heading_text(line)
            continue

        if pending_marker is not None and not is_blank(line):
            pending_marker = None

        if in_fence:
            if is_fence_line(line):
                in_fence = False
                fence_marked = False
            continue

        kind = not_prose_kind(line)
        if kind == "code":
            fence_marked = is_allowed_not_prose("code", active_not_prose)
            if not fence_marked:
                note_finding(
                    findings,
                    category="Unmarked fenced code block",
                    line=line_no,
                    raw=line,
                    parent_level=current_heading_level,
                )
            in_fence = True
            continue
        if kind == "table":
            if not is_allowed_not_prose("table", active_not_prose):
                note_finding(
                    findings,
                    category="Unmarked Markdown table",
                    line=line_no,
                    raw=line,
                    parent_level=current_heading_level,
                )
            continue
        if kind == "html":
            if not is_allowed_not_prose("html", active_not_prose):
                note_finding(
                    findings,
                    category="Unmarked raw HTML block",
                    line=line_no,
                    raw=line,
                    parent_level=current_heading_level,
                )
            continue

        if is_blank(line) or is_comment(line):
            continue

        if is_bullet(line):
            if next_line.strip() and not is_bullet(next_line) and not is_heading(next_line):
                if not is_fence_line(next_line) and not is_table_line(next_line):
                    if not is_raw_html_line(next_line) and not is_comment(next_line):
                        note_finding(
                            findings,
                            category="Multiline list item",
                            line=line_no,
                            raw=line,
                            parent_level=current_heading_level,
                        )

        if is_prose_line(line) and is_prose_line(next_line):
            note_finding(
                findings,
                category="Soft-wrapped prose paragraph",
                line=line_no,
                raw=f"{line} {next_line}",
                parent_level=current_heading_level,
            )

        if not is_prose_line(line) and not is_bullet(line):
            continue

        raw = line.strip()
        visible = visible_text(raw)
        punct = punctuation_class(raw)
        links = LINK_RE.findall(raw)
        in_see_section = current_heading_text == "See"

        if raw.startswith("See:"):
            note_finding(
                findings,
                category="Old `See:` citation paragraph",
                line=line_no,
                raw=raw,
                parent_level=current_heading_level,
            )
            continue

        if links and not in_see_section:
            note_finding(
                findings,
                category="Inline prose link",
                line=line_no,
                raw=raw,
                parent_level=current_heading_level,
            )

        if len(visible) > max_length and not in_see_section:
            note_finding(
                findings,
                category=length_category(punct),
                line=line_no,
                raw=raw,
                parent_level=current_heading_level,
            )

    return findings


def write_report(
    output: Path,
    *,
    target: Path,
    max_length: int,
    findings: list[Finding],
) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    counts = Counter(finding.category for finding in findings)

    lines = [
        "# Punctuation Policy Report",
        "",
        f"Target: `{display_path(target)}`",
        f"Maximum visible length: `{max_length}`",
        f"Findings: `{len(findings)}`",
        "",
        "## Summary",
        "",
    ]
    if counts:
        for category, count in sorted(counts.items()):
            lines.append(f"* {category}: {count}")
    else:
        lines.append("* No findings.")

    lines.extend(["", "## Findings", ""])
    for index, finding in enumerate(findings, 1):
        lines.extend(
            [
                f"### {index}. {finding.category}",
                "",
                f"* Line: `{finding.line}`",
                f"* Visible length: `{finding.visible_length}`",
                f"* Punctuation class: `{finding.punctuation_class}`",
                f"* Suggested repair: {finding.suggestion}",
                "",
                "Preview:",
                "",
                f"> {finding.preview}",
                "",
            ]
        )

    output.write_text("\n".join(lines), encoding="utf-8")


def test_markdown(text: str) -> str:
    return textwrap.dedent(text).strip("\n") + "\n"


def test_categories(text: str, max_length: int = DEFAULT_MAX_LENGTH) -> list[str]:
    findings = scan_text(test_markdown(text), max_length)
    return [finding.category for finding in findings]


class PunctuationPolicyReporterTests(unittest.TestCase):
    def test_long_no_delimiter_sentence(self) -> None:
        result = test_categories(
            "This sentence is intentionally long because it keeps going without useful punctuation and needs a rewrite soon."
        )
        self.assertIn("Long no-delimiter sentence", result)

    def test_long_comma_only_sentence(self) -> None:
        result = test_categories(
            "This sentence lists apples, oranges, pears, plums, peaches, apricots, cherries, and berries."
        )
        self.assertIn("Long comma-only sentence", result)

    def test_long_colon_sentence(self) -> None:
        result = test_categories(
            "This sentence introduces material: the thing should become a heading or short structured block."
        )
        self.assertIn("Long colon sentence", result)

    def test_long_semicolon_sentence(self) -> None:
        result = test_categories(
            "This sentence has one full clause; the second clause should probably become another sentence."
        )
        self.assertIn("Long semicolon sentence", result)

    def test_mixed_delimiter_sentence(self) -> None:
        result = test_categories(
            "This sentence introduces a list: apples, oranges, pears, and peaches should become bullets."
        )
        self.assertIn("Mixed delimiter sentence", result)

    def test_old_see_citation_paragraph(self) -> None:
        result = test_categories("See: [Source](https://example.test/source).")
        self.assertIn("Old `See:` citation paragraph", result)

    def test_inline_prose_link(self) -> None:
        result = test_categories("Read [the source](https://example.test/source) for details.")
        self.assertIn("Inline prose link", result)

    def test_citation_block_link_is_allowed(self) -> None:
        result = test_categories(
            """
            ## Parent

            ### See

            * [Source](https://example.test/source)
            """
        )
        self.assertNotIn("Inline prose link", result)

    def test_soft_wrapped_prose_paragraph(self) -> None:
        result = test_categories(
            """
            This is one prose sentence.
            This is another prose sentence without a blank separator.
            """
        )
        self.assertIn("Soft-wrapped prose paragraph", result)

    def test_multiline_list_item(self) -> None:
        result = test_categories(
            """
            * First list item.
              Continuation text should become a nested bullet.
            """
        )
        self.assertIn("Multiline list item", result)

    def test_nested_one_line_bullet_is_allowed(self) -> None:
        result = test_categories(
            """
            * First list item.
              * Nested one-line item.
            """
        )
        self.assertNotIn("Multiline list item", result)

    def test_unmarked_fenced_code_block(self) -> None:
        result = test_categories(
            """
            ```text
            alpha, beta: gamma;
            ```
            """
        )
        self.assertIn("Unmarked fenced code block", result)

    def test_marked_fenced_code_block_is_allowed(self) -> None:
        result = test_categories(
            """
            ## Parent

            <!-- not-prose: TYPE=code, WHY=example-token -->
            ### Example

            ```text
            alpha, beta: gamma;
            ```
            """
        )
        self.assertNotIn("Unmarked fenced code block", result)
        self.assertNotIn("Invalid `not-prose` marker", result)

    def test_unmarked_markdown_table(self) -> None:
        result = test_categories(
            """
            | A | B |
            | - | - |
            | 1 | 2 |
            """
        )
        self.assertIn("Unmarked Markdown table", result)

    def test_marked_markdown_table_is_allowed(self) -> None:
        result = test_categories(
            """
            ## Parent

            <!-- not-prose: TYPE=table, WHY=matrix -->
            ### Matrix

            | A | B |
            | - | - |
            | 1 | 2 |
            """
        )
        self.assertNotIn("Unmarked Markdown table", result)

    def test_unmarked_raw_html_block(self) -> None:
        result = test_categories("<article>")
        self.assertIn("Unmarked raw HTML block", result)

    def test_marked_raw_html_block_is_allowed(self) -> None:
        result = test_categories(
            """
            ## Parent

            <!-- not-prose: TYPE=html, WHY=html-example -->
            ### HTML Example

            <article>
            """
        )
        self.assertNotIn("Unmarked raw HTML block", result)

    def test_invalid_marker_format(self) -> None:
        result = test_categories(
            """
            ## Parent

            <!-- not-prose: TYPE=diagram, WHY=bad token -->
            ### Bad Marker
            """
        )
        self.assertIn("Invalid `not-prose` marker", result)

    def test_marker_not_followed_by_heading(self) -> None:
        result = test_categories(
            """
            ## Parent

            <!-- not-prose: TYPE=code, WHY=example-token -->
            Not a heading.
            """
        )
        self.assertIn("`not-prose` marker not immediately followed by a heading", result)

    def test_not_prose_heading_must_be_one_level_below_parent(self) -> None:
        result = test_categories(
            """
            ## Parent

            <!-- not-prose: TYPE=code, WHY=example-token -->
            #### Too Deep
            """
        )
        self.assertIn(
            "`not-prose` heading not one level below its parent heading",
            result,
        )

    def test_inline_code_punctuation_is_protected(self) -> None:
        result = test_categories(
            "This sentence has protected punctuation in `alpha, beta: gamma; delta` only.",
            max_length=20,
        )
        self.assertIn("Long no-delimiter sentence", result)
        self.assertNotIn("Mixed delimiter sentence", result)

    def test_cli_writes_report(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "case.md"
            output = root / "report.md"
            source.write_text(
                test_markdown("See: [Source](https://example.test/source)."),
                encoding="utf-8",
            )
            subprocess.run(
                [
                    sys.executable,
                    str(Path(__file__).resolve()),
                    "--file",
                    str(source),
                    "--output",
                    str(output),
                ],
                check=True,
                text=True,
                capture_output=True,
            )
            report = output.read_text(encoding="utf-8")
            self.assertIn("Old `See:` citation paragraph", report)


def run_self_tests() -> int:
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(
        PunctuationPolicyReporterTests
    )
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


def main() -> int:
    args = parse_args()
    if args.self_test:
        return run_self_tests()

    target = resolve_from_root(args.file)
    output = resolve_from_root(args.output)

    if not target.exists():
        raise SystemExit(f"error: target file does not exist: {display_path(target)}")
    if not target.is_file():
        raise SystemExit(f"error: target path is not a file: {display_path(target)}")

    text = target.read_text(encoding="utf-8")
    findings = scan_text(text, args.max_length)
    write_report(output, target=target, max_length=args.max_length, findings=findings)

    print(f"Target: {display_path(target)}")
    print(f"Lines scanned: {len(text.splitlines())}")
    print(f"Findings: {len(findings)}")
    print(f"Wrote report: {display_path(output)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
