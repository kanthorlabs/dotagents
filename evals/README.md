# Skill evals

Each eval measures the outcome of one skill, not its compliance with its own rules. Each skill has one suite directory. All suites share the scripts in `harness/`.

## Layout

- `harness/run.sh`: runs one suite on one skill file.
- `harness/generate.py`: runs every case with the skill as an appended system prompt, in a temp copy of the case fixture outside any git repository.
- `harness/report.py`: writes `report.md` from `results.json`.
- `harness/compare.py`: applies the acceptance criterion of a candidate run against baseline runs.
- `harness/discriminate.py`: flags the cells that a control run passes as often as the baseline.
- `harness/claude_call.py`: a structured `claude -p` call for suite steps, for example a grader.
- `<suite>/`: one suite per skill. `explain/` is the first suite.

## Suite contract

A suite directory holds:

- `suite.json`:
  - `skill`: the live skill path, relative to the repository root.
  - `model`, `effort`, `tools`: the settings of the model under test.
  - `steps`: the suite scripts that run after generation, in order.
- `cases/<id>/`: one directory per case, with `prompt.md` and an optional `fixture/`. Other files in the case directory belong to the suite steps.
- `cases/<id>/fixture.json`: optional. It maps a workspace path to the file content. `generate.py` writes these files after it copies `fixture/`. Use it for a file that a gitignore rule excludes, for example `*.env`.
- `measures.json`: the name of each measure.
- `runs/`: the run output. Each run has `samples/<case>/r<n>.md`.

Each step receives the run directory as its only argument. The last step writes `results.json` with this shape:

```
{
  "skill_path": "...", "skill_lines": 192, "repeats": 3,
  "cost_usd": {"generation": 0.0, "reader": 0.0, "grading": 0.0},
  "samples": [
    {"case": "<id>", "sample": "r1", "error": false, "words": 400,
     "measures": [{"id": "M1", "pass": true, "evidence": "..."}],
     "diagnostics": []}
  ]
}
```

`run.sh` sets `EVAL_SUITE` to the suite directory and adds `harness/` to `PYTHONPATH`, so a step can import `claude_call`.

## Run

Run the commands from `evals/`.

```
harness/run.sh <suite> <run-name> [repeats] [skill-path]
python3 harness/compare.py <suite>/runs/<run-name> <suite>/runs/baseline-1 <suite>/runs/baseline-2
```

- Without `skill-path`, the run uses the `skill` of `suite.json`.
- `EVAL_CASES=<dir>` selects another case directory of the suite, for example `holdout`.
- Read the suite `README.md` for its measures, its baselines and its acceptance values.

## Add a suite

1. Write the goal of the skill as one sentence. Each measure must answer that sentence.
2. Create `<suite>/suite.json`, `<suite>/measures.json` and the cases.
3. Write the suite steps that grade the samples and write `results.json`.
4. Run the live skill twice and an empty skill once. Use the noise of the two runs to check the acceptance criterion.
