import hashlib
import json
import os
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from claude_call import structured_call

HERE = Path(__file__).resolve().parent
CASES = HERE / os.environ.get("EVAL_CASES", "cases")
POOL = 6
BUDGET_USD = "0.50"
ATTEMPTS = 2


def reader_prompt(case_dir, output):
    return (
        (HERE / "reader_prompt.md").read_text()
        .replace("{{PROMPT}}", (case_dir / "prompt.md").read_text().strip())
        .replace("{{OUTPUT}}", output.strip())
    )


def read_sample(case_dir, sample_path):
    reader_path = sample_path.with_suffix(".reader.json")
    if not sample_path.exists():
        return f"skip {sample_path}: no output"
    prompt = reader_prompt(case_dir, sample_path.read_text())
    key = hashlib.sha256(prompt.encode() + (HERE / "reader_schema.json").read_bytes()).hexdigest()
    if reader_path.exists():
        cached = json.loads(reader_path.read_text())
        if cached.get("key") == key and cached.get("reader"):
            return f"cached {reader_path}"
    cost = 0.0
    reader = None
    raw = {}
    for _ in range(ATTEMPTS):
        raw = structured_call(prompt, (HERE / "reader_schema.json").read_text(), BUDGET_USD)
        cost += raw.get("total_cost_usd", 0) or 0
        reader = raw.get("structured_output")
        if reader:
            break
    reader_path.write_text(json.dumps({"key": key, "cost_usd": cost, "reader": reader, "raw": raw}, indent=2))
    return f"{'ok' if reader else 'error'} {reader_path}"


def main():
    out_dir = Path(sys.argv[1]).resolve()
    meta = json.loads((out_dir / "run.json").read_text())
    jobs = []
    for case_dir in sorted(path for path in CASES.iterdir() if path.is_dir()):
        key = json.loads((case_dir / "key.json").read_text())
        if key["measures"] == ["MF"]:
            continue
        for repeat in range(1, meta["repeats"] + 1):
            jobs.append((case_dir, out_dir / "samples" / case_dir.name / f"r{repeat}.md"))
    with ThreadPoolExecutor(max_workers=POOL) as pool:
        for line in pool.map(lambda job: read_sample(*job), jobs):
            print(line, flush=True)


if __name__ == "__main__":
    main()
