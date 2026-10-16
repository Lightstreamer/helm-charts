#!/usr/bin/env python3
# Generated with the assistance of AI tools.
"""Validate values.yaml line references in DEPLOYMENT.md.

Every Markdown link of the form [text](charts/lightstreamer/values.yaml#L<n>) is
checked against the full dotted path of the YAML key defined on line <n>
(commented-out example keys included):

* Key links (`key`, `parent.key`, `dataProviders.<name>.key`): the link text must
  be a whole-segment suffix of the target path. `<...>` and `{}` match any
  single segment.
* Role links ([Metadata Adapter], [Proxy Data Adapter], ...): the target must be
  the key named right before the parenthesis (e.g. "- `installDir` ([Metadata
  Adapter](...), ...)") inside the block of that role.
* Other links (e.g. [values.yaml]) cannot be validated; they are listed as
  "unverified" with the line they currently land on.

Naming-convention warnings (never fatal) flag link texts that break the
full/relative path pattern used in the document.

Usage:
  python3 check-refs.py                  # check only
  python3 check-refs.py --fix            # fix wrong line numbers in place; ambiguous links
                                         # follow the shift of nearby unambiguous ones
  python3 check-refs.py --fix --base REV # also track keys from the values.yaml the doc was
                                         # last in sync with: git revision or file path
  python3 check-refs.py --no-style       # skip naming-convention warnings
  python3 check-refs.py --doc FILE --values FILE   # check other copies
"""

import argparse
import re
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent
DEPLOYMENT = REPO_ROOT / "DEPLOYMENT.md"
VALUES = REPO_ROOT / "charts" / "lightstreamer" / "values.yaml"
VALUES_REL = "charts/lightstreamer/values.yaml"

LINK_RE = re.compile(r"\[(`?)([^\]`]+?)\1\]\(charts/lightstreamer/values\.yaml#L(\d+)\)")
HEADING_RE = re.compile(r"^(#{1,6}) (.+)$")
KEY_TEXT_RE = re.compile(r"^[\w.\-]*(?:(?:<[^>]+>|\{\})[\w.\-]*)*$")
ROLE_KEY_RE = re.compile(r"`([\w.]+)` \(")
FILE_EXTS = (".yaml", ".yml", ".md", ".xml", ".html", ".properties")

# Path segment that a role link's target must contain.
ROLES = {
    "Metadata Adapter": "inProcessMetadataAdapter",
    "Data Adapter": "inProcessDataAdapter",
    "Proxy Metadata Adapter": "proxyMetadataAdapter",
    "Proxy Data Adapter": "proxyDataAdapter",
}

ACTIVE_KEY_RE = re.compile(r"^(\s*)(-\s+)?([A-Za-z_][\w.\-]*)\s*:(?:\s|$)")
# Commented-out example keys: "# key:" or "# key: value" (prose is excluded).
COMMENT_KEY_RE = re.compile(r"^(\s*)#( +)(-\s+)?([a-z][A-Za-z0-9_.]*)\s*:(\s+\S+)?\s*$")


def index_paths(lines: list[str]) -> dict[int, str]:
    """Map 1-based line numbers that define a key to the key's full dotted path."""
    paths: dict[int, str] = {}
    stack: list[tuple[int, str]] = []
    for no, line in enumerate(lines, 1):
        m = ACTIVE_KEY_RE.match(line)
        if m:
            col = len(m.group(1)) + len(m.group(2) or "")
            key = m.group(3)
        else:
            c = COMMENT_KEY_RE.match(line)
            if not c or line.lstrip().startswith("# --"):
                continue
            col = len(c.group(1)) + len(c.group(2)) - 1 + len(c.group(3) or "")
            key = c.group(4)
        while stack and stack[-1][0] >= col:
            stack.pop()
        stack.append((col, key))
        paths[no] = ".".join(k for _, k in stack)
    return paths


def text_regex(text: str) -> re.Pattern:
    parts = re.split(r"(<[^>]+>|\{\})", text)
    body = "".join(r"[^.]+" if p.startswith(("<", "{")) else re.escape(p) for p in parts)
    return re.compile(r"(?:^|\.)" + body + r"$")


class Link:
    def __init__(self, line_no, line, m, section, section_path):
        self.line_no = line_no
        self.line = line
        self.m = m
        self.backticked = bool(m.group(1))
        self.text = m.group(2).strip()
        self.ref = int(m.group(3))
        self.section = section
        self.section_path = section_path  # heading texts, outermost first
        self.kind, self.rule = self._classify()

    def _classify(self):
        if self.text in ROLES:
            keys = [k for k in ROLE_KEY_RE.finditer(self.line) if k.end() <= self.m.start()]
            if keys:
                key = keys[-1].group(1)
                seg = ROLES[self.text]
                rx = text_regex(key)
                return "role", (lambda p, rx=rx, seg=seg: bool(rx.search(p)) and seg in p.split("."),
                                f"`{key}` under `{seg}`")
            return "unverified", None
        if self.text.endswith(FILE_EXTS) or not KEY_TEXT_RE.match(self.text):
            return "unverified", None
        rx = text_regex(self.text)
        return "key", (lambda p, rx=rx: bool(rx.search(p)), f"`{self.text}`")

    def ok(self, path):
        return path is not None and self.rule[0](path)


def parse_links(doc_lines):
    links, heads = [], []
    in_code = False
    for no, line in enumerate(doc_lines, 1):
        if line.lstrip(" >").startswith("```"):
            in_code = not in_code
            continue
        h = None if in_code else HEADING_RE.match(line)
        if h:
            level = len(h.group(1))
            heads = [x for x in heads if x[0] < level] + [(level, h.group(2))]
            continue
        for m in LINK_RE.finditer(line):
            links.append(Link(no, line, m, heads[-1][1] if heads else "",
                              tuple(t for _, t in heads)))
    return links


def git_show(rev: str, rel: str):
    try:
        out = subprocess.run(["git", "show", f"{rev}:{rel}"], cwd=REPO_ROOT,
                             capture_output=True, text=True, check=True)
        return out.stdout.splitlines()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def common_prefix(a: str, b: str) -> int:
    n = 0
    for x, y in zip(a.split("."), b.split(".")):
        if x != y:
            break
        n += 1
    return n


def find_fix(link, paths, base_paths, context, shifts=()):
    """Return (new_line, note) or (None, reason)."""
    cands = sorted(no for no, p in paths.items() if link.ok(p))
    if len(cands) == 1:
        return cands[0], "unique match"
    if not cands:
        return None, "no key matches the link"
    for delta in shifts:
        if link.ref + delta in cands:
            return link.ref + delta, f"same shift ({delta:+d}) as the nearest unambiguous fixes"
    if base_paths is not None:
        old = base_paths.get(link.ref)
        exact = [no for no in cands if paths[no] == old]
        if old and exact:
            return min(exact, key=lambda n: abs(n - link.ref)), f"tracked `{old}` from base"
    # Prefer the candidate closest (by shared path prefix) to the section's other links.
    if context:
        score = {no: max(common_prefix(paths[no], c) for c in context) for no in cands}
        best = max(score.values())
        top = [no for no in cands if score[no] == best]
        if best > 0 and len(top) == 1:
            return top[0], "closest to the section's other links"
    shown = ", ".join(f"L{n} {paths[n]}" for n in cands[:5])
    return None, f"ambiguous ({len(cands)} candidates: {shown}{', ...' if len(cands) > 5 else ''})"


def style_warnings(links, paths):
    """Naming-convention warnings: full path in openings, relative paths inside."""
    warns = []
    info = []
    for l in links:
        p = paths.get(l.ref)
        if l.kind != "key" or not l.backticked or not l.ok(p):
            continue
        base = text_regex(l.text).sub("", p)
        closing = l.line.lstrip().startswith("See the [")
        info.append((l, p, base, closing))

    # S1: relative links on the same line whose bases nest -> use the outer base.
    by_line = {}
    for l, p, base, _ in info:
        if base:
            by_line.setdefault(l.line_no, []).append((l, p, base))
    for items in by_line.values():
        for l, p, base in items:
            outer = [b for _, _, b in items if b != base and base.startswith(b + ".")]
            if outer:
                b = min(outer, key=len)
                warns.append((l, f"`{p[len(b) + 1:]}`", f"other links on this line are relative to `{b}`"))

    # S2: a section writing settings as full paths (`P.x`) has a link relative to P.
    by_sec = {}
    for item in info:
        by_sec.setdefault(item[0].section_path, []).append(item)
    for items in by_sec.values():
        fulls = [p for l, p, base, closing in items if not base and not closing]
        for l, p, base, _ in items:
            if base and sum(1 for f in fulls if f.startswith(base + ".")) >= 2:
                warns.append((l, f"`{p}`", f"this section writes settings under `{base}` as full paths"))

    # S3: sibling subsections mostly open with a full path, this one doesn't.
    openers = {}
    for l, p, base, closing in info:
        if not closing:
            openers.setdefault(l.section_path, (l, p, base))
    by_parent = {}
    for sp, item in openers.items():
        by_parent.setdefault(sp[:-1], []).append(item)
    for items in by_parent.values():
        full = [i for i in items if not i[2]]
        rel = [i for i in items if i[2]]
        if len(full) >= 2 and len(full) > len(rel):
            for l, p, base in rel:
                warns.append((l, f"`{p}`", "sibling subsections open with a full path"))

    # S4: relative link into a top-level block no other link of the section uses.
    for sp, items in by_sec.items():
        ctx = [p for s, its in by_sec.items() if sp[:len(s)] == s for _, p, _, _ in its]
        for l, p, base, _ in items:
            top = p.split(".")[0]
            if base and sum(1 for c in ctx if c.split(".")[0] == top) < 2:
                warns.append((l, f"`{p}`", f"relative name for a key outside this section (`{top}`)"))
    return warns


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--fix", action="store_true")
    ap.add_argument("--base")
    ap.add_argument("--no-style", action="store_true")
    ap.add_argument("--doc", type=Path, default=DEPLOYMENT)
    ap.add_argument("--values", type=Path, default=VALUES)
    args = ap.parse_args()

    doc_text = args.doc.read_text()
    doc_lines = doc_text.splitlines()
    values_lines = args.values.read_text().splitlines()
    paths = index_paths(values_lines)
    links = parse_links(doc_lines)

    base_paths = None
    base_lines = None
    if args.fix and args.base:
        base_file = Path(args.base)
        base_lines = (base_file.read_text().splitlines() if base_file.is_file()
                      else git_show(args.base, VALUES_REL))
        if base_lines is None:
            sys.exit(f"--base {args.base}: not a file or a git revision containing {VALUES_REL}")
        base_paths = index_paths(base_lines)

    errors = fixed = 0
    fixes: dict[int, list[tuple[int, int, int]]] = {}
    unverified = []
    valid_by_sec: dict[tuple, list[str]] = {}
    for l in links:
        if l.kind != "unverified" and l.ok(paths.get(l.ref)):
            valid_by_sec.setdefault(l.section_path, []).append(paths[l.ref])
    # Line shifts (old ref -> delta) observed on broken links with a single candidate.
    anchors = sorted({l.ref: n - l.ref for l in links
                      if l.kind != "unverified" and not l.ok(paths.get(l.ref))
                      for n in [c for c in paths if l.ok(paths[c])]
                      if sum(1 for c in paths if l.ok(paths[c])) == 1}.items())

    def nearby_shifts(ref):
        before = [d for r, d in anchors if r <= ref]
        after = [d for r, d in anchors if r > ref]
        return list(dict.fromkeys(([before[-1]] if before else []) + ([after[0]] if after else [])))

    for l in links:
        if l.kind == "unverified":
            target = values_lines[l.ref - 1].strip() if 0 < l.ref <= len(values_lines) else "<out of range>"
            moved = ""
            if args.fix and base_lines and 0 < l.ref <= len(base_lines):
                old = base_lines[l.ref - 1].strip()
                hits = [i + 1 for i, v in enumerate(values_lines) if v.strip() == old] if old else []
                if len(hits) == 1 and hits[0] != l.ref:
                    fixes.setdefault(l.line_no - 1, []).append((l.m.start(3), l.m.end(3), hits[0]))
                    fixed += 1
                    moved = f"  (moved L{l.ref} -> L{hits[0]}, same line text as base)"
                    target = old
            elif args.fix and not base_lines:
                s = nearby_shifts(l.ref)
                if len(s) == 1 and s[0]:
                    new = l.ref + s[0]
                    fixes.setdefault(l.line_no - 1, []).append((l.m.start(3), l.m.end(3), new))
                    fixed += 1
                    moved = f"  (moved L{l.ref} -> L{new}, same shift as the surrounding links)"
                    target = values_lines[new - 1].strip() if 0 < new <= len(values_lines) else target
            unverified.append(f"DEPLOYMENT.md:{l.line_no}  [{l.text}] -> L{l.ref}  "
                              f"{paths.get(l.ref) or target[:70]}{moved}")
            continue
        path = paths.get(l.ref)
        if l.ok(path):
            continue
        errors += 1
        found = path or (values_lines[l.ref - 1].strip()[:70] if 0 < l.ref <= len(values_lines) else "<out of range>")
        print(f"DEPLOYMENT.md:{l.line_no}  [{l.text}] -> L{l.ref}")
        print(f"  expected {l.rule[1]}, found: {found}")
        context = [p for s, ps in valid_by_sec.items() if l.section_path[:len(s)] == s for p in ps]
        new, note = find_fix(l, paths, base_paths if args.fix else None, context, nearby_shifts(l.ref))
        if new:
            print(f"  {'fix' if args.fix else 'suggestion'}: L{new}  {paths[new]}  ({note})")
            if args.fix:
                fixes.setdefault(l.line_no - 1, []).append((l.m.start(3), l.m.end(3), new))
                fixed += 1
        else:
            print(f"  not fixed: {note}")
        print()

    if args.fix and fixes:
        for idx, items in fixes.items():
            line = doc_lines[idx]
            for start, end, new in sorted(items, reverse=True):
                line = line[:start] + str(new) + line[end:]
            doc_lines[idx] = line
        args.doc.write_text("\n".join(doc_lines) + ("\n" if doc_text.endswith("\n") else ""))
        print(f"Fixed {fixed} ref(s) in {args.doc.name}\n")

    if unverified:
        print("Unverified links (text is not a key; check the target by hand):")
        for u in unverified:
            print(f"  {u}")
        print()

    if not args.no_style:
        warns = style_warnings(links, paths)
        if warns:
            print("Naming-convention warnings:")
            for l, suggestion, why in sorted(warns, key=lambda w: w[0].line_no):
                print(f"  DEPLOYMENT.md:{l.line_no}  [{l.section}] `{l.text}` -> {suggestion}  ({why})")
            print()

    checked = len(links) - len(unverified)
    if errors:
        print(f"Checked {checked} refs ({len(unverified)} unverified) — {errors} error(s)"
              + (f", {fixed} fixed" if args.fix else ""))
    else:
        print(f"Checked {checked} refs ({len(unverified)} unverified) — all OK")
    return 1 if errors > fixed else 0


if __name__ == "__main__":
    sys.exit(main())
