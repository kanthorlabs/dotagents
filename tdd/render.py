#!/usr/bin/env python3
"""Render the TDD skeleton with a project PROFILE into runnable agent/command files.

Usage:
    render.py <skeleton_dir> <profile.md> <out_dir>

Substitution rules (see PROFILE.template.md):
  - `{{TOKEN}}`    single value from the profile's §1 token table.
  - `{{> SLOT}}`   full section body from a profile `### `{{> SLOT}}`` heading.

Slots are expanded first, then tokens (so tokens inside slot bodies resolve too).
A leftover `{{...}}` after rendering is a profile-coverage error and aborts.
"""
import re
import sys
from pathlib import Path

TOKEN_ROW = re.compile(r"^\|\s*`?\{\{(\w+)\}\}`?\s*\|\s*(.*?)\s*\|\s*$")
SLOT_HEAD = re.compile(r"^###\s+`\{\{>\s*(\w+)\}\}`")
STOP_BODY = re.compile(r"^(?:#{2,3}\s|---\s*$)")
LEFTOVER = re.compile(r"\{\{[^}]+\}\}")


def parse_profile(text: str):
    tokens, slots = {}, {}
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        m = TOKEN_ROW.match(line)
        if m and m.group(1) not in ("TOKEN",):  # skip the template header row
            val = m.group(2).strip()
            if val.startswith("`") and val.endswith("`") and len(val) > 1:
                val = val[1:-1]
            tokens[m.group(1)] = val
            i += 1
            continue
        sm = SLOT_HEAD.match(line)
        if sm:
            name = sm.group(1)
            body, j = [], i + 1
            while j < len(lines) and not STOP_BODY.match(lines[j]):
                body.append(lines[j])
                j += 1
            slots[name] = "\n".join(body).strip("\n")
            i = j
            continue
        i += 1
    return tokens, slots


def render(text: str, tokens: dict, slots: dict, where: str) -> str:
    def slot_sub(m):
        name = m.group(1)
        if name not in slots:
            sys.exit(f"ERROR: slot {{{{> {name}}}}} used in {where} but not defined in profile")
        return slots[name]

    text = re.sub(r"\{\{>\s*(\w+)\}\}", slot_sub, text)

    def tok_sub(m):
        name = m.group(1)
        if name not in tokens:
            sys.exit(f"ERROR: token {{{{{name}}}}} used in {where} but not defined in profile")
        return tokens[name]

    text = re.sub(r"\{\{(\w+)\}\}", tok_sub, text)
    return text


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    skel, profile, out = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
    tokens, slots = parse_profile(profile.read_text())

    files = [Path("commands/work.md")] + [Path("agents") / f.name
             for f in sorted((skel / "agents").glob("*.md"))]
    out.mkdir(parents=True, exist_ok=True)
    for rel in files:
        rendered = render((skel / rel).read_text(), tokens, slots, str(rel))
        leftover = LEFTOVER.search(rendered)
        if leftover:
            sys.exit(f"ERROR: unresolved {leftover.group(0)} in rendered {rel}")
        dst = out / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(rendered)
        print(f"rendered {rel} -> {dst}")
    print(f"\nOK: {len(files)} files, {len(tokens)} tokens, {len(slots)} slots")


if __name__ == "__main__":
    main()
