import json
import os
import sys
from collections import defaultdict
from pathlib import Path

SUITE = Path(os.environ["EVAL_SUITE"]).resolve()
CASES_NAME = os.environ.get("EVAL_CASES", "cases")
FLAGS = SUITE / ("nondiscriminating.json" if CASES_NAME == "cases" else f"nondiscriminating-{CASES_NAME}.json")
MEASURES = json.loads((SUITE / "measures.json").read_text())


def rate(values):
    return sum(values) / len(values) if values else 0.0


def summarize(results):
    per_case = defaultdict(list)
    per_measure = defaultdict(list)
    per_cell = defaultdict(list)
    per_repeat = defaultdict(list)
    diagnostics = defaultdict(list)
    diagnostic_rules = {}
    for sample in results["samples"]:
        for measure in sample["measures"]:
            per_case[sample["case"]].append(measure["pass"])
            per_measure[measure["id"]].append(measure["pass"])
            per_cell[f"{sample['case']}:{measure['id']}"].append(measure["pass"])
            per_repeat[sample["sample"]].append(measure["pass"])
        for check in sample["diagnostics"]:
            diagnostics[check["id"]].append(check["pass"])
            diagnostic_rules[check["id"]] = check["rule"]
    every = [value for values in per_case.values() for value in values]
    words = [sample["words"] for sample in results["samples"] if not sample["error"]]
    every_diagnostic = [value for values in diagnostics.values() for value in values]
    return {
        "passed": sum(every),
        "total": len(every),
        "score": rate(every),
        "per_measure": {key: {"passed": sum(v), "n": len(v), "rate": rate(v)} for key, v in sorted(per_measure.items())},
        "per_case": {key: rate(values) for key, values in sorted(per_case.items())},
        "per_cell": {key: {"passed": sum(v), "n": len(v)} for key, v in sorted(per_cell.items())},
        "per_repeat": {key: rate(values) for key, values in sorted(per_repeat.items())},
        "mean_words": rate(words),
        "diagnostic_score": rate(every_diagnostic),
        "diagnostics": {
            key: {"rule": diagnostic_rules[key], "passed": sum(v), "n": len(v)} for key, v in sorted(diagnostics.items())
        },
        "errors": sum(1 for sample in results["samples"] if sample["error"]),
    }


def non_discriminating():
    return json.loads(FLAGS.read_text()) if FLAGS.exists() else {}


def render(results, summary):
    flagged = non_discriminating()
    cost = results["cost_usd"]
    lines = [
        f"# /{SUITE.name} eval report",
        "",
        f"- Skill: `{results['skill_path']}`",
        f"- Skill line count: {results['skill_lines']}",
        f"- Repeats: {results['repeats']}",
        f"- Total score: {summary['passed']}/{summary['total']} = {summary['score']:.3f}",
        "- Score per repeat: " + ", ".join(f"{k} {v:.3f}" for k, v in summary["per_repeat"].items()),
        f"- M6 reading cost: mean {summary['mean_words']:.0f} words per message",
        f"- Generation errors: {summary['errors']}",
        f"- Cost: generation {cost['generation']:.2f} USD, reader {cost['reader']:.2f} USD, grading {cost['grading']:.2f} USD",
        "",
        "## Score per measure",
        "",
        "| Measure | Name | Passed | Rate |",
        "| --- | --- | --- | --- |",
    ]
    for measure, data in summary["per_measure"].items():
        lines.append(f"| {measure} | {MEASURES[measure]['name']} | {data['passed']}/{data['n']} | {data['rate']:.3f} |")
    lines += ["", "## Score per case", "", "| Case | Score | Mean words |", "| --- | --- | --- |"]
    words = defaultdict(list)
    for sample in results["samples"]:
        words[sample["case"]].append(sample["words"])
    for case, score in summary["per_case"].items():
        lines.append(f"| {case} | {score:.3f} | {sum(words[case]) / len(words[case]):.0f} |")
    lines += ["", "## Score per case and measure", "", "| Cell | Passed | Flag |", "| --- | --- | --- |"]
    for cell, data in summary["per_cell"].items():
        flag = "non-discriminating" if cell in flagged else ""
        lines.append(f"| {cell} | {data['passed']}/{data['n']} | {flag} |")
    lines += ["", "## Failed measures", ""]
    for sample in results["samples"]:
        for measure in sample["measures"]:
            if not measure["pass"]:
                evidence = measure["evidence"].replace("\n", " ")
                lines.append(f"- {sample['case']} {sample['sample']} {measure['id']}: {evidence}")
    lines += [
        "",
        "## Diagnostic rule checks",
        "",
        "These mechanical checks do not count toward the score.",
        "",
        f"Diagnostic pass rate: {summary['diagnostic_score']:.3f}",
        "",
        "| Check | Rule | Passed |",
        "| --- | --- | --- |",
    ]
    for check, data in summary["diagnostics"].items():
        lines.append(f"| {check} | {data['rule']} | {data['passed']}/{data['n']} |")
    return "\n".join(lines) + "\n"


def main():
    out_dir = Path(sys.argv[1]).resolve()
    results = json.loads((out_dir / "results.json").read_text())
    summary = summarize(results)
    results["summary"] = summary
    (out_dir / "results.json").write_text(json.dumps(results, indent=2))
    (out_dir / "report.md").write_text(render(results, summary))
    print(f"score {summary['passed']}/{summary['total']} = {summary['score']:.3f}, mean words {summary['mean_words']:.0f}")


if __name__ == "__main__":
    main()
