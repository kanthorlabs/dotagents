import json
import math
import statistics
import sys
from collections import defaultdict
from pathlib import Path

Z = 2.0


def load(run_dir):
    return json.loads((Path(run_dir) / "results.json").read_text())


def repeat_scores(results):
    per_repeat = defaultdict(list)
    for sample in results["samples"]:
        per_repeat[sample["sample"]].extend(measure["pass"] for measure in sample["measures"])
    return [sum(values) / len(values) for values in per_repeat.values()]


def measure_counts(runs):
    counts = defaultdict(lambda: [0, 0])
    for results in runs:
        for sample in results["samples"]:
            for measure in sample["measures"]:
                counts[measure["id"]][0] += measure["pass"]
                counts[measure["id"]][1] += 1
    return counts


def total(runs):
    values = [m["pass"] for results in runs for s in results["samples"] for m in s["measures"]]
    return sum(values) / len(values)


def mean_words(runs):
    words = [s["words"] for results in runs for s in results["samples"] if not s["error"]]
    return sum(words) / len(words)


def main():
    if len(sys.argv) < 3:
        sys.exit("usage: compare.py <candidate-run> <baseline-run>...")
    candidate = [load(sys.argv[1])]
    baseline = [load(path) for path in sys.argv[2:]]
    baseline_repeats = [score for results in baseline for score in repeat_scores(results)]
    candidate_repeats = repeat_scores(candidate[0])
    sigma = statistics.stdev(baseline_repeats)
    total_margin = Z * sigma * math.sqrt(1 / len(candidate_repeats) + 1 / len(baseline_repeats))
    base_total, cand_total = total(baseline), total(candidate)
    total_ok = cand_total >= base_total - total_margin
    print(f"total: candidate {cand_total:.3f}, baseline {base_total:.3f}, margin {total_margin:.3f}, {'PASS' if total_ok else 'FAIL'}")
    base_counts, cand_counts = measure_counts(baseline), measure_counts(candidate)
    guards_ok = True
    for measure in sorted(base_counts):
        b_pass, b_n = base_counts[measure]
        c_pass, c_n = cand_counts.get(measure, [0, 0])
        if not c_n:
            print(f"{measure}: no candidate data, FAIL")
            guards_ok = False
            continue
        pooled = (b_pass + c_pass) / (b_n + c_n)
        margin = Z * math.sqrt(max(pooled * (1 - pooled), 0.0025) * (1 / b_n + 1 / c_n))
        ok = c_pass / c_n >= b_pass / b_n - margin
        guards_ok = guards_ok and ok
        print(f"{measure}: candidate {c_pass}/{c_n} = {c_pass / c_n:.3f}, baseline {b_pass}/{b_n} = {b_pass / b_n:.3f}, margin {margin:.3f}, {'PASS' if ok else 'FAIL'}")
    print(f"M6 mean words: candidate {mean_words(candidate):.0f}, baseline {mean_words(baseline):.0f}")
    verdict = total_ok and guards_ok
    print(f"verdict: {'no drop' if verdict else 'drop'}")
    sys.exit(0 if verdict else 1)


if __name__ == "__main__":
    main()
