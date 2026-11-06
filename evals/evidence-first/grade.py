import hashlib
import json
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from claude_call import structured_call

HERE = Path(__file__).resolve().parent
CASES = HERE / os.environ.get("EVAL_CASES", "cases")
POOL = 6
BUDGET_USD = "0.50"
ATTEMPTS = 2
MEASURES = json.loads((HERE / "measures.json").read_text())


def load_cases():
    cases = {}
    for case_dir in sorted(path for path in CASES.iterdir() if path.is_dir()):
        cases[case_dir.name] = {
            "dir": case_dir,
            "key": json.loads((case_dir / "key.json").read_text()),
            "prompt": (case_dir / "prompt.md").read_text(),
        }
    return cases


def grader_prompt(case, output, measures):
    listing = "\n".join(
        f"- id: {m}\n  name: {MEASURES[m]['name']}\n  definition: {MEASURES[m]['definition']}"
        for m in measures
    )
    return (
        (HERE / "grader_prompt.md").read_text()
        .replace("{{KEY}}", json.dumps(case["key"], indent=2))
        .replace("{{PROMPT}}", case["prompt"].strip())
        .replace("{{OUTPUT}}", output.strip())
        .replace("{{MEASURES}}", listing)
    )


def judge(case, sample_path, output, measures):
    grade_path = sample_path.with_suffix(".grade.json")
    prompt = grader_prompt(case, output, measures)
    schema = (HERE / "grader_schema.json").read_text()
    cache_key = hashlib.sha256(prompt.encode() + schema.encode()).hexdigest()
    if grade_path.exists():
        cached = json.loads(grade_path.read_text())
        if cached.get("key") == cache_key and not cached.get("missing"):
            return cached
    cost = 0.0
    verdicts = {}
    raw = {}
    for _ in range(ATTEMPTS):
        raw = structured_call(prompt, schema, BUDGET_USD)
        cost += raw.get("total_cost_usd", 0) or 0
        structured = raw.get("structured_output") or {}
        verdicts = {item["id"]: item for item in structured.get("verdicts", [])}
        if all(m in verdicts for m in measures):
            break
    missing = [m for m in measures if m not in verdicts]
    record = {"key": cache_key, "cost_usd": cost, "verdicts": verdicts, "missing": missing, "raw": raw}
    grade_path.write_text(json.dumps(record, indent=2))
    return record


def grade_sample(case_name, case, sample_path):
    base = {"case": case_name, "sample": sample_path.stem}
    measures = case["key"]["measures"]
    if not sample_path.exists():
        failed = [{"id": m, "pass": False, "evidence": "no output: generation failed"} for m in measures]
        return {**base, "error": True, "words": 0, "grader_cost_usd": 0.0, "measures": failed, "diagnostics": []}
    output = sample_path.read_text()
    record = judge(case, sample_path, output, measures)
    cost = record["cost_usd"]
    results = []
    for m in measures:
        verdict = record["verdicts"].get(m)
        results.append({
            "id": m,
            "pass": bool(verdict and verdict["pass"]),
            "evidence": verdict["evidence"] if verdict else "grader returned no verdict",
        })
    return {**base, "error": False, "words": len(re.findall(r"\S+", output)),
            "grader_cost_usd": cost, "measures": results, "diagnostics": []}


def generation_cost(sample_path):
    raw_path = sample_path.with_suffix(".json")
    if not raw_path.exists():
        return 0.0
    return json.loads(raw_path.read_text()).get("total_cost_usd", 0.0) or 0.0


def main():
    out_dir = Path(sys.argv[1]).resolve()
    meta = json.loads((out_dir / "run.json").read_text())
    cases = load_cases()
    jobs = []
    for case_name, case in cases.items():
        for repeat in range(1, meta["repeats"] + 1):
            jobs.append((case_name, case, out_dir / "samples" / case_name / f"r{repeat}.md"))
    with ThreadPoolExecutor(max_workers=POOL) as pool:
        samples = list(pool.map(lambda job: grade_sample(*job), jobs))
    for sample, (_, _, path) in zip(samples, jobs):
        sample["generation_cost_usd"] = generation_cost(path)
    results = {
        **meta,
        "cost_usd": {
            "generation": round(sum(s["generation_cost_usd"] for s in samples), 4),
            "reader": 0.0,
            "grading": round(sum(s["grader_cost_usd"] for s in samples), 4),
        },
        "samples": samples,
    }
    (out_dir / "results.json").write_text(json.dumps(results, indent=2))
    passed = sum(m["pass"] for s in samples for m in s["measures"])
    total = sum(len(s["measures"]) for s in samples)
    print(f"graded {len(samples)} samples: {passed}/{total}")


if __name__ == "__main__":
    main()
