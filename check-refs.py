#!/usr/bin/env python3
# Generated with the assistance of AI tools.
"""Validate values.yaml line references in DEPLOYMENT.md.

For each Markdown link of the form [text](charts/lightstreamer/values.yaml#L<n>),
the script checks that line <n> in values.yaml contains a token derived from the
link text.  Reports mismatches and suggests the closest matching line.

Usage:
  python3 check-refs.py          # check only
  python3 check-refs.py --fix    # fix mismatches in-place (picks nearest match)
"""

import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent
DEPLOYMENT = REPO_ROOT / "DEPLOYMENT.md"
VALUES = REPO_ROOT / "charts" / "lightstreamer" / "values.yaml"

LINK_RE = re.compile(
    r"\[(?:`?)([^]`]+?)(?:`?)\]"           # link text (strip backticks)
    r"\(charts/lightstreamer/values\.yaml#L(\d+)\)"
)

# Build a list of search keys from the link text, ordered from most to least
# specific.  We try:
#   1. The last dotted segment as-is (e.g. "fromPathInImage")
#   2. Multi-word names converted to camelCase (e.g. "Proxy Metadata Adapter"
#      -> "proxyMetadataAdapter")
#   3. The full dotted path (e.g. "logging.appenders.dailyRolling")
def build_keys(link_text: str) -> list[str]:
    text = link_text.strip("`").strip()
    keys: list[str] = []
    # Last dotted segment
    last = text.rsplit(".", 1)[-1]
    keys.append(last)
    # camelCase variant for multi-word
    words = last.split()
    if len(words) > 1:
        keys.append(words[0].lower() + "".join(w.capitalize() for w in words[1:]))
    # Full text
    if text != last:
        keys.append(text)
    return keys


# Also try to extract YAML key names from the surrounding markdown line.
# e.g. "- `requestReplyPort` ([Proxy Metadata Adapter]..." -> "requestReplyPort"
INLINE_KEY_RE = re.compile(r"`(\w+)`")

def build_keys_with_context(link_text: str, md_line: str) -> list[str]:
    """Build search keys from both the link text and the markdown line context."""
    keys = build_keys(link_text)
    # Extract backtick-quoted words from the same markdown line
    for m in INLINE_KEY_RE.finditer(md_line):
        word = m.group(1)
        if word not in keys and len(word) > 2:
            keys.append(word)
    return keys


def load_lines(path: Path) -> list[str]:
    return path.read_text().splitlines()


def line_has_yaml_key(line: str, key: str) -> bool:
    """Check if *key* appears as a YAML key definition on *line*.

    Matches patterns like ``key:``, ``key: value``, ``# key:``,
    ``# -- key: description``.  Does NOT match a bare mention of the
    word inside a comment (e.g. "# The dashboard.enable… setting").
    Uses case-insensitive comparison to tolerate casing differences
    between doc text and YAML keys (e.g. classLoader vs classloader).
    """
    return (key.lower() + ":") in line.lower()


def find_nearest(values_lines: list[str], keys: list[str], target_line: int,
                 window: int = 50) -> list[tuple[int, str]]:
    """Search ±window lines around *target_line* for YAML key definitions.

    Uses a two-tier approach: first collects strict matches (``key:``),
    then falls back to weak substring matches if no strict ones are found.
    """
    strict: list[tuple[int, str]] = []
    weak:   list[tuple[int, str]] = []
    lo = max(0, target_line - window - 1)
    hi = min(len(values_lines), target_line + window)
    for i in range(lo, hi):
        line = values_lines[i]
        if any(line_has_yaml_key(line, k) for k in keys):
            strict.append((i + 1, line.rstrip()))
        elif any(k.lower() in line.lower() for k in keys):
            weak.append((i + 1, line.rstrip()))
    return strict if strict else weak


def main() -> int:
    fix_mode = "--fix" in sys.argv

    if not DEPLOYMENT.exists() or not VALUES.exists():
        print(f"Error: cannot find {DEPLOYMENT} or {VALUES}", file=sys.stderr)
        return 1

    deploy_text = DEPLOYMENT.read_text()
    deploy_lines = deploy_text.splitlines()
    values_lines = load_lines(VALUES)

    errors = 0
    checked = 0
    fixed = 0

    # Collect replacements: list of (old_fragment, new_fragment)
    replacements: list[tuple[str, str]] = []

    for line_no, line in enumerate(deploy_lines, 1):
        for m in LINK_RE.finditer(line):
            link_text = m.group(1)
            ref_line = int(m.group(2))
            checked += 1

            # Skip bare filename links (e.g. [values.yaml]) — these are generic
            # file references where the link text has no YAML key to match.
            # A "bare filename" is text that ends with a known file extension
            # and contains no dotted-path prefix (e.g. "logging.appenders").
            bare = link_text.strip("`").strip()
            FILE_EXTS = (".yaml", ".yml", ".md", ".xml", ".html", ".properties")
            if bare.endswith(FILE_EXTS) and "." not in bare[:bare.rfind(".")]:
                continue

            if ref_line < 1 or ref_line > len(values_lines):
                print(f"DEPLOYMENT.md:{line_no}  L{ref_line} out of range "
                      f"(values.yaml has {len(values_lines)} lines)  [{link_text}]")
                errors += 1
                continue

            target = values_lines[ref_line - 1]
            keys = build_keys_with_context(link_text, line)
            if any(line_has_yaml_key(target, k) for k in keys):
                continue  # match — key definition found on target line

            # Mismatch — search nearby for the expected key
            errors += 1
            nearby = find_nearest(values_lines, keys, ref_line)
            print(f"DEPLOYMENT.md:{line_no}  [{link_text}] -> L{ref_line}")
            print(f"  expected {keys} but found: {target.rstrip()}")
            if nearby:
                # Pick the closest match
                best_line, best_content = min(nearby,
                                              key=lambda x: abs(x[0] - ref_line))
                delta = best_line - ref_line
                for nl, content in nearby[:3]:
                    d = nl - ref_line
                    marker = " *" if nl == best_line else ""
                    print(f"  suggestion: L{nl} ({d:+d})  {content}{marker}")
                if fix_mode:
                    old_frag = f"values.yaml#L{ref_line})"
                    new_frag = f"values.yaml#L{best_line})"
                    replacements.append((m.start(), old_frag, new_frag))
                    fixed += 1
            else:
                print(f"  no nearby match for {keys}")
            print()

    if fix_mode and replacements:
        # Build a map from (line_offset, old_frag) -> new_frag so that all
        # replacements are resolved against the original text before any
        # mutation.  We iterate the original text once, replacing each
        # matching fragment.
        # Sort by position descending so replacements don't shift offsets.
        deploy_chars = list(deploy_text)
        for pos, old_frag, new_frag in sorted(replacements, key=lambda x: x[0],
                                               reverse=True):
            # Find the exact occurrence of old_frag starting at or after pos
            idx = deploy_text.find(old_frag, pos)
            if idx == -1:
                continue
            deploy_chars[idx:idx + len(old_frag)] = list(new_frag)
        deploy_text = "".join(deploy_chars)
        DEPLOYMENT.write_text(deploy_text)
        print(f"Fixed {fixed} ref(s) in {DEPLOYMENT.name}")

    if errors:
        print(f"Checked {checked} refs — {errors} mismatch(es)"
              + (f", {fixed} fixed" if fix_mode else ""))
    else:
        print(f"Checked {checked} refs — all OK")

    return 1 if errors and not fix_mode else 0


if __name__ == "__main__":
    sys.exit(main())
