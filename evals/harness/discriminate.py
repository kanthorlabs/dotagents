import json
import os
import sys
from collections import defaultdict
from pathlib import Path

SUITE = Path(os.environ["EVAL_SUITE"]).resolve()
CASES_NAME = os.environ.get("EVAL_CASES", "cases")
FLAGS = SUITE / ("nondiscriminating.json" if CASES_NAME == "cases" else f"nondiscriminating-{CASES_NAME}.json")


def cell_counts(run_dirs):
    counts = defaultdict(lambda: [0, 0])
    for run_dir in run_dirs:
        results = json.loads((Path(run_dir) / "results.json").read_text())
        for sample in results["samples"]:
            for measure in sample["measures"]:
                cell = counts[f"{sample['case']}:{measure['id']}"]
                cell[0] += measure["pass"]
                cell[1] += 1
    return counts


def main():
    if len(sys.argv) < 3:
        sys.exit("usage: discriminate.py <control-run> <baseline-run>...")
    control = cell_counts([sys.argv[1]])
    baseline = cell_counts(sys.argv[2:])
    flagged = {}
    for cell, (passed, total) in sorted(baseline.items()):
        control_passed, control_total = control.get(cell, [0, 0])
        if control_total and control_passed / control_total >= passed / total:
            flagged[cell] = f"control {control_passed}/{control_total}, baseline {passed}/{total}"
    FLAGS.write_text(json.dumps(flagged, indent=2) + "\n")
    for cell, reason in flagged.items():
        print(f"{cell}: {reason}")
    print(f"{len(flagged)} of {len(baseline)} cells are non-discriminating")


if __name__ == "__main__":
    main()
