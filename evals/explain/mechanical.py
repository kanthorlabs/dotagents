import re

FENCE = re.compile(r"^\s*(```|~~~)")
HEADER = re.compile(r"^\s{0,3}#{1,6}\s+(.*)$")
BOLD_START = re.compile(r"^\*\*([^*]+?)\*\*")
BULLET = re.compile(r"^[-*+]\s+(.*)$")
NUMBERED = re.compile(r"^(\d+[a-z]?)[.)]\s+(.*)$")
INLINE_CODE = re.compile(r"`[^`]*`")
LINK = re.compile(r"\[([^\]]*)\]\([^)]*\)")
SENTENCE_SPLIT = re.compile(r"(?<=[.!?])\s+(?=[A-Z0-9`\"'*(\[])")
PREAMBLE = re.compile(r"(?i)^(sure|great|good question|here('s| is| are)|let me|i('ll| will| can)|okay|ok\b|absolutely|certainly|of course|based on)")
CLOSE_LABEL = re.compile(r"(?i)^(question|next step|next|close|ruling|decision|open question|open item)")
FLATTERY = re.compile(r"(?i)\b(great question|good question|good catch|great catch|excellent question|nice find|happy to help|hope this helps|absolutely|certainly|simply|seamlessly|leverage|robust)\b")
DEFERRAL = re.compile(r"(?i)(before (the|this|a|you open the|opening the|merging the|you merge the) (pr|pull request)|\b(check|verify|confirm)\b.{0,60}\blater\b)")
REVIEW = re.compile(
    r"^(\*\*|`)?(?P<kind>[BS])\d+(\*\*|`)?:?\s+-\s+status:\s*(\*\*|`)?(FIXED|OPEN)(\*\*|`)?\s+-\s+"
    r"action:\s*(\*\*|`)?(YES|NO)(\*\*|`)?\s+-\s+.+?\s+-\s+.+?\s+-\s+fix:\s*.+?\s+-\s+why:\s*.+$"
)
FULL_TIMELINE = re.compile(r"^(existing behavio|timeline(?! with\b))")
SECTION_RANK = [
    (re.compile(r"^existing behavio"), 1),
    (re.compile(r"^timeline without"), 2),
    (re.compile(r"^timeline with\b"), 3),
    (re.compile(r"^timeline\b"), 2),
    (re.compile(r"^what changes"), 5),
    (re.compile(r"^(recommend|alternative)"), 6),
    (CLOSE_LABEL, 7),
]


def prose_lines(text):
    lines = []
    in_code = False
    for line in text.splitlines():
        if FENCE.match(line):
            in_code = not in_code
            lines.append("")
            continue
        lines.append("" if in_code else line)
    return lines


def plain(line):
    return LINK.sub(r"\1", INLINE_CODE.sub("CODE", line))


def blocks(text):
    result = []
    current = []
    start = 0
    for index, line in enumerate(prose_lines(text)):
        if line.strip():
            if not current:
                start = index
            current.append(line)
        elif current:
            result.append((start, current))
            current = []
    if current:
        result.append((start, current))
    return result


def label_of(line):
    header = HEADER.match(line)
    if header:
        return header.group(1).replace("*", "").strip().rstrip(".:").strip()
    bold = BOLD_START.match(line)
    if bold:
        return bold.group(1).strip().rstrip(".:").strip()
    return None


def labels(text):
    found = []
    for index, line in enumerate(prose_lines(text)):
        label = label_of(line)
        if label is not None:
            found.append((index, label, line))
    return found


def is_list_line(line):
    return bool(BULLET.match(line) or NUMBERED.match(line))


def numbered_items(lines, start, end):
    items = []
    for index in range(start, end):
        match = NUMBERED.match(lines[index])
        if match:
            items.append([match.group(1), match.group(2)])
        elif items and lines[index].strip() and lines[index].startswith((" ", "\t")):
            items[-1][1] += " " + lines[index].strip()
    return items


def section_spans(text, pattern):
    lines = prose_lines(text)
    found = labels(text)
    spans = []
    for position, (index, label, line) in enumerate(found):
        if re.search(pattern, label.lower()):
            end = found[position + 1][0] if position + 1 < len(found) else len(lines)
            spans.append((index, end, label, line))
    return lines, spans


def logical_lines(text):
    merged = []
    for _, block in blocks(text):
        for line in block:
            starts_new = not merged or is_list_line(line) or HEADER.match(line) or line.startswith("**") or line is block[0]
            if starts_new:
                merged.append(line.strip())
            else:
                merged[-1] += " " + line.strip()
    return merged


def sentences(text):
    parts = []
    for line in logical_lines(text):
        stripped = plain(line).strip()
        stripped = re.sub(r"^([-*+]|\d+[a-z]?[.)]|#{1,6})\s+", "", stripped).replace("**", "")
        if not stripped:
            continue
        parts.extend(piece for piece in SENTENCE_SPLIT.split(stripped) if piece.strip())
    return parts


def count_outside_code(text, char):
    return sum(plain(line).count(char) for line in prose_lines(text))


def no_em_dash(text, **_):
    hits = [line for line in prose_lines(text) if "—" in plain(line)]
    return (not hits, hits[0].strip()[:120] if hits else "no em-dash")


def no_paren_aside(text, **_):
    for line in prose_lines(text):
        match = re.search(r"\([^)]*[A-Za-z][^)]*\)", plain(line))
        if match:
            return False, match.group(0)[:120]
    return True, "no parenthetical aside"


def headers_ok(text, **_):
    count = sum(1 for line in prose_lines(text) if HEADER.match(line))
    words = len(text.split())
    limit = 0 if words < 500 else 3
    return count <= limit, f"{count} headers, {words} words"


def sentence_length(text, **_):
    lengths = [len(piece.split()) for piece in sentences(text)]
    if not lengths:
        return False, "no sentences"
    long_share = sum(1 for length in lengths if length > 25) / len(lengths)
    return (long_share <= 0.10 and max(lengths) <= 40, f"long share {long_share:.2f}, max {max(lengths)} words")


def bold_leadins(text, **_):
    all_blocks = blocks(text)
    for position, (_, block) in enumerate(all_blocks):
        first = block[0]
        if position > 0 and not (is_list_line(first) or HEADER.match(first) or first.lstrip().startswith(("|", ">", "**"))):
            return False, first.strip()[:120]
        for line in block:
            bullet = BULLET.match(line)
            if bullet and not re.match(r"^(\*\*|`|[BS]\d)", bullet.group(1)):
                return False, line.strip()[:120]
    return True, "all paragraphs and bullets carry a lead-in"


def no_flattery(text, **_):
    match = FLATTERY.search("\n".join(plain(line) for line in prose_lines(text)))
    return (not match, match.group(0) if match else "no flattery phrase")


def conclusion_first(text, **_):
    all_blocks = blocks(text)
    if not all_blocks:
        return False, "empty message"
    first = all_blocks[0][1]
    line = first[0].strip()
    if HEADER.match(line) or line.startswith("**") or is_list_line(line):
        return False, f"first block is labeled or a list: {line[:80]}"
    if PREAMBLE.match(line):
        return False, f"preamble: {line[:80]}"
    count = len(sentences("\n".join(first)))
    return count <= 3, f"{count} sentences in the conclusion"


def section_order(text, **_):
    previous = 0
    unranked_since = False
    for _, label, _ in labels(text):
        rank = next((value for pattern, value in SECTION_RANK if pattern.search(label.lower())), None)
        if rank is None:
            unranked_since = True
            continue
        reset_ok = rank <= 2 and (unranked_since or previous == 3)
        if rank < previous and not reset_ok:
            return False, f"'{label}' after a later section"
        previous = rank
        unranked_since = False
    return True, "sections in template order"


def sections_labeled(text, **_):
    lines = prose_lines(text)
    labeled_since_list = False
    in_list = False
    for line in lines:
        if label_of(line) is not None:
            labeled_since_list = True
            in_list = False
            continue
        if NUMBERED.match(line):
            if not in_list and not labeled_since_list:
                return False, f"unlabeled list at: {line.strip()[:80]}"
            in_list = True
            labeled_since_list = False
        elif line.strip() and not line.startswith((" ", "\t")) and not BULLET.match(line):
            in_list = False
    return True, "every numbered list carries a label"


def close_last(text, **_):
    found = labels(text)
    if not found:
        return False, "no labels"
    index, label, line = found[-1]
    if not CLOSE_LABEL.search(label):
        return False, f"last label is '{label}'"
    all_blocks = blocks(text)
    position = max(number for number, (start, _) in enumerate(all_blocks) if start <= index)
    start, block = all_blocks[position]
    trailing = all_blocks[position + 1:]
    alone = len(block) == 1 and (not BOLD_START.sub("", line).strip(" .:") or bool(HEADER.match(line)))
    allowed = 1 if alone else 0
    if len(trailing) > allowed:
        return False, f"text after the close: {trailing[allowed][1][0].strip()[:80]}"
    return True, f"close '{label}' ends the message"


def close_single_question(text, **_):
    found = labels(text)
    if not found or not CLOSE_LABEL.search(found[-1][1]):
        return False, "no close label"
    lines = prose_lines(text)
    close_text = "\n".join(lines[found[-1][0]:])
    count = sum(plain(line).count("?") for line in close_text.splitlines())
    return count == 1, f"{count} question marks in the close"


def no_question(text, **_):
    count = count_outside_code(text, "?")
    return count == 0, f"{count} question marks"


def full_timelines_bounded(text, **_):
    lines, spans = section_spans(text, FULL_TIMELINE.pattern)
    if not spans:
        return False, "no full timeline"
    counts = []
    for start, end, label, _ in spans:
        count = len(numbered_items(lines, start, end))
        counts.append(f"{label}={count}")
        if not 4 <= count <= 8:
            return False, f"{label} holds {count} steps"
    return True, ", ".join(counts)


def step_sentences_max(text, **_):
    lines = prose_lines(text)
    for number, body in numbered_items(lines, 0, len(lines)):
        count = len(SENTENCE_SPLIT.split(plain(body).replace("**", "").strip()))
        if count > 2:
            return False, f"step {number} holds {count} sentences"
    return True, "every step holds at most two sentences"


def fixed_starts_at_divergence(text, **_):
    lines, spans = section_spans(text, r"^timeline with\b")
    if not spans:
        return False, "no fixed timeline"
    for start, end, label, _ in spans:
        items = numbered_items(lines, start, end)
        head_end = start + 1
        while head_end < end and not NUMBERED.match(lines[head_end]):
            head_end += 1
        head = " ".join(lines[start:head_end])
        match = re.search(r"(?i)diverges at step\s+\*{0,2}(\d+[a-z]?)", head)
        if not match:
            return False, f"'{label}' names no divergence step before its list"
        if not items or items[0][0] != match.group(1):
            first = items[0][0] if items else "none"
            return False, f"diverges at step {match.group(1)}, first step {first}"
    return True, "every fixed timeline starts at its divergence step"


def change_bullets(text, **_):
    lines, spans = section_spans(text, r"^what changes")
    if not spans:
        return False, "no What changes section"
    for start, end, _, _ in spans:
        bullets = [BULLET.match(line) for line in lines[start + 1:end]]
        bullets = [match.group(1) for match in bullets if match]
        if not bullets:
            return False, "What changes holds no bullet"
        for body in bullets:
            if not re.match(r"^(\*\*)?`", body):
                return False, body[:100]
    return True, "every change bullet opens with a backticked name"


def no_alt_timeline(text, **_):
    lines, spans = section_spans(text, r"^alternative")
    for start, end, label, _ in spans:
        if numbered_items(lines, start, end):
            return False, f"'{label}' holds a numbered list"
    return True, "no alternative holds a timeline"


def label_present(text, pattern, **_):
    hits = [label for _, label, _ in labels(text) if re.search(pattern, label.lower())]
    return bool(hits), hits[0] if hits else f"no label matches {pattern}"


def label_absent(text, pattern, **_):
    hits = [label for _, label, _ in labels(text) if re.search(pattern, label.lower())]
    return not hits, hits[0] if hits else f"no label matches {pattern}"


def label_count_min(text, pattern, n, **_):
    count = sum(1 for _, label, _ in labels(text) if re.search(pattern, label.lower()))
    return count >= n, f"{count} labels match {pattern}"


def label_count_exact(text, pattern, n, **_):
    count = sum(1 for _, label, _ in labels(text) if re.search(pattern, label.lower()))
    return count == n, f"{count} labels match {pattern}"


def regex_present(text, pattern, **_):
    match = re.search(pattern, text)
    return bool(match), match.group(0) if match else f"absent: {pattern}"


def regex_absent(text, pattern, **_):
    match = re.search(pattern, text)
    return not match, match.group(0) if match else f"absent: {pattern}"


def no_deferral(text, **_):
    match = DEFERRAL.search(text)
    return not match, match.group(0)[:120] if match else "no deferral phrase"


def word_max(text, n, **_):
    count = len(text.split())
    return count <= n, f"{count} words"


def no_template(text, **_):
    for line in prose_lines(text):
        if label_of(line) is not None or NUMBERED.match(line) or re.search(r"(?i)timeline", line):
            return False, line.strip()[:100]
    return True, "no template element"


def first_line_bullet(text, **_):
    all_blocks = blocks(text)
    if not all_blocks:
        return False, "empty message"
    first = all_blocks[0][1][0]
    return bool(BULLET.match(first)), first.strip()[:100]


def first_list_min_items(text, n, **_):
    all_blocks = blocks(text)
    if not all_blocks:
        return False, "empty message"
    count = sum(1 for line in all_blocks[0][1] if BULLET.match(line))
    return count >= n, f"{count} bullets in the first block"


def first_block_regex(text, pattern, **_):
    all_blocks = blocks(text)
    if not all_blocks:
        return False, "empty message"
    first = "\n".join(all_blocks[0][1])
    match = re.search(pattern, first)
    return bool(match), first.strip()[:120]


def review_format(text, min_b, min_s, **_):
    lines = prose_lines(text)
    findings = []
    for index, line in enumerate(lines):
        bullet = BULLET.match(line)
        if not bullet or not re.match(r"^(\*\*|`)?[BS]\d", bullet.group(1)):
            continue
        body = bullet.group(1)
        follow = index + 1
        while follow < len(lines) and lines[follow].startswith((" ", "\t")) and lines[follow].strip():
            body += " " + lines[follow].strip()
            follow += 1
        findings.append(body)
    if not findings:
        return False, "no B/S bullet"
    kinds = []
    for body in findings:
        match = REVIEW.match(body)
        if not match:
            return False, body[:120]
        kinds.append(match.group("kind"))
    b_count, s_count = kinds.count("B"), kinds.count("S")
    return (b_count >= min_b and s_count >= min_s, f"{b_count} B, {s_count} S, all bullets match")


CHECKS = {
    name: function
    for name, function in globals().items()
    if callable(function) and name in {
        "no_em_dash", "no_paren_aside", "headers_ok", "sentence_length", "bold_leadins", "no_flattery",
        "conclusion_first", "section_order", "sections_labeled", "close_last", "close_single_question",
        "no_question", "full_timelines_bounded", "step_sentences_max", "fixed_starts_at_divergence",
        "change_bullets", "no_alt_timeline", "label_present", "label_absent", "label_count_min",
        "label_count_exact", "regex_present", "regex_absent", "no_deferral", "word_max", "no_template",
        "first_line_bullet", "first_list_min_items", "first_block_regex", "review_format",
    }
}


def run(fn, text, args):
    passed, evidence = CHECKS[fn](text, **(args or {}))
    return bool(passed), str(evidence)
