import hashlib
import json
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import mechanical
from claude_call import structured_call

HERE = Path(__file__).resolve().parent
CASES = HERE / os.environ.get("EVAL_CASES", "cases")
POOL = 6
BUDGET_USD = "0.50"
ATTEMPTS = 2
MEASURES = json.loads((HERE / "measures.json").read_text())
HIDDEN_KEY_FIELDS = ("measures", "factual_pattern")


def load_cases():
    common = json.loads((HERE / "common_checks.json").read_text())
    cases = {}
    for case_dir in sorted(path for path in CASES.iterdir() if path.is_dir()):
        spec = json.loads((case_dir / "checks.json").read_text())
        checks = [dict(check) for group in spec["common"] for check in common[group]]
        checks += [dict(check) for check in spec["checks"]]
        names = set()
        for check in checks:
            assert check["kind"] == "mechanical", f"{case_dir.name}: {check['name']} is not mechanical"
            assert check["name"] not in names, f"{case_dir.name}: duplicate check {check['name']}"
            names.add(check["name"])
            check["id"] = f"{case_dir.name}:{check['name']}"
        cases[case_dir.name] = {
            "dir": case_dir,
            "key": json.loads((case_dir / "key.json").read_text()),
            "prompt": (case_dir / "prompt.md").read_text(),
            "checks": checks,
        }
    return cases


def judged_measures(key):
    return [
        measure for measure in key["measures"]
        if MEASURES[measure]["kind"] == "judged" and not (measure == "M5" and key["closing_decision"] == "none")
    ]


def grader_prompt(case, output, reader, measures):
    visible_key = {name: value for name, value in case["key"].items() if name not in HIDDEN_KEY_FIELDS}
    listing = "\n".join(f"- id: {m}\n  name: {MEASURES[m]['name']}\n  definition: {MEASURES[m]['definition']}" for m in measures)
    return (
        (HERE / "grader_prompt.md").read_text()
        .replace("{{KEY}}", json.dumps(visible_key, indent=2))
        .replace("{{PROMPT}}", case["prompt"].strip())
        .replace("{{OUTPUT}}", output.strip())
        .replace("{{READER}}", json.dumps(reader, indent=2))
        .replace("{{MEASURES}}", listing)
    )


def judge(case, sample_path, output, reader, measures):
    grade_path = sample_path.with_suffix(".grade.json")
    prompt = grader_prompt(case, output, reader, measures)
    key = hashlib.sha256(prompt.encode() + (HERE / "grader_schema.json").read_bytes()).hexdigest()
    if grade_path.exists():
        cached = json.loads(grade_path.read_text())
        if cached.get("key") == key and not cached.get("missing"):
            return cached
    cost = 0.0
    verdicts = {}
    raw = {}
    for _ in range(ATTEMPTS):
        raw = structured_call(prompt, (HERE / "grader_schema.json").read_text(), BUDGET_USD)
        cost += raw.get("total_cost_usd", 0) or 0
        structured = raw.get("structured_output") or {}
        verdicts = {item["id"]: item for item in structured.get("verdicts", [])}
        if all(measure in verdicts for measure in measures):
            break
    missing = [measure for measure in measures if measure not in verdicts]
    record = {"key": key, "cost_usd": cost, "verdicts": verdicts, "missing": missing, "raw": raw}
    grade_path.write_text(json.dumps(record, indent=2))
    return record


def factual_measure(key, output):
    checks = [
        mechanical.run("regex_present", output, {"pattern": key["factual_pattern"]}),
        mechanical.run("word_max", output, {"n": 80}),
        mechanical.run("no_template", output, {}),
    ]
    return all(passed for passed, _ in checks), "; ".join(evidence for _, evidence in checks)


def measure_results(case, sample_path, output):
    key = case["key"]
    results = {}
    for measure in key["measures"]:
        if measure == "MF":
            results[measure] = factual_measure(key, output)
        elif measure == "M5" and key["closing_decision"] == "none":
            results[measure] = mechanical.run("no_question", output, {})
    measures = judged_measures(key)
    cost = 0.0
    if measures:
        reader_path = sample_path.with_suffix(".reader.json")
        reader = json.loads(reader_path.read_text()).get("reader") if reader_path.exists() else None
        if reader is None:
            for measure in measures:
                results[measure] = (False, "no reader output")
        else:
            record = judge(case, sample_path, output, reader, measures)
            cost = record["cost_usd"]
            for measure in measures:
                verdict = record["verdicts"].get(measure)
                results[measure] = (bool(verdict and verdict["pass"]), verdict["evidence"] if verdict else "grader returned no verdict")
    ordered = [{"id": m, "pass": results[m][0], "evidence": results[m][1]} for m in key["measures"]]
    return ordered, cost


def grade_sample(case_name, case, sample_path):
    base = {"case": case_name, "sample": sample_path.stem}
    if not sample_path.exists():
        failed = [{"id": m, "pass": False, "evidence": "no output: generation failed"} for m in case["key"]["measures"]]
        return {**base, "error": True, "words": 0, "grader_cost_usd": 0.0, "reader_cost_usd": 0.0, "measures": failed, "diagnostics": []}
    output = sample_path.read_text()
    measures, grader_cost = measure_results(case, sample_path, output)
    diagnostics = []
    for check in case["checks"]:
        passed, evidence = mechanical.run(check["fn"], output, check.get("args"))
        diagnostics.append({"id": check["id"], "rule": check["rule"], "criterion": check["criterion"], "pass": passed, "evidence": evidence})
    reader_path = sample_path.with_suffix(".reader.json")
    reader_cost = json.loads(reader_path.read_text()).get("cost_usd", 0.0) if reader_path.exists() else 0.0
    return {**base, "error": False, "words": len(re.findall(r"\S+", output)), "grader_cost_usd": grader_cost,
            "reader_cost_usd": reader_cost, "measures": measures, "diagnostics": diagnostics}


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
            "reader": round(sum(s["reader_cost_usd"] for s in samples), 4),
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
