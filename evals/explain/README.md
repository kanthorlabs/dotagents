# /explain eval

This eval measures the outcome of the `/explain` skill. The goal of the skill: after one message, Ulrich makes the correct ruling without a follow-up question.

## What one run does

`../harness/run.sh` runs the shared steps and the steps of `suite.json`. See `../README.md`.

1. `harness/generate.py` runs every case with the skill as an appended system prompt. `suite.json` sets the model, the effort and the tools: Sonnet, medium, `Read,Grep,Glob`. Each case runs in a temp copy of its `fixture/` directory, outside any git repository. The model never sees `key.json`.
2. `read.py` runs a reader call that plays Ulrich. The reader sees the case prompt and the message only. It returns a decision, a reconstruction, its follow-up questions and its answer to the closing question.
3. `grade.py` runs one grader call per sample and writes `results.json`. The grader sees the answer key, the prompt, the message and the reader notes. It does not see the skill. It grades the measures M1 to M7. The script also runs the mechanical rule checks as a diagnostic layer.
4. `harness/report.py` writes `report.md`.

## Measures

`measures.json` defines each measure. `COVERAGE.md` maps each measure to its cases.

- M1 Right decision.
- M2 True facts.
- M3 No follow-up.
- M4 Understanding.
- M5 Answerable close.
- M6 Reading cost: mean word count. It is reported and it breaks ties. It is not scored.
- M7 Valid alternative.
- MF Factual answer, for the negative case only.

Each measure is binary per case and per repeat. A measure that a case does not list does not count. The total score is the passed share of all applicable cells.

The mechanical rule checks do not count toward the score. The report lists them in a separate section.

## Layout

- `cases/<id>/prompt.md`: the prompt.
- `cases/<id>/fixture/`: the files that the model can read.
- `cases/<id>/fixture.json`: the fixture files that git ignores, as path and content. Cases `10-negative-factual` and `12-selfdebate-allowlist` use it for their `.env` files.
- `cases/<id>/key.json`: the answer key. Only the grader sees it.
- `cases/<id>/checks.json`: the mechanical rule checks for the diagnostic layer.
- `common_checks.json`, `mechanical.py`, `rules.json`: the diagnostic layer.
- `suite.json`: the live skill path, the model, the effort, the tools and the suite steps.
- `read.py`, `grade.py`: the suite steps.
- `reader_prompt.md`, `reader_schema.json`, `grader_prompt.md`, `grader_schema.json`: the prompts of the reader and the grader.
- `holdout/<id>/`: 14 holdout cases, 2 per measure, in the same format as `cases/`.
- `control/SKILL.md`: an empty skill.
- `runs/baseline-1`, `runs/baseline-2`: two runs of the live skill `skills/explain/SKILL.md` on `cases/`, with 3 repeats each.
- `runs/holdout-baseline-1`, `runs/holdout-baseline-2`: the same two runs on `holdout/`.
- `nondiscriminating.json`, `nondiscriminating-holdout.json`: the cells that the control passes as often as the baseline.

Git tracks only the four baseline runs. `.gitignore` excludes every other directory under `runs/`.

## Run a candidate

Run these commands from `evals/`. Run the candidate on both case sets. A candidate passes only when both compares pass.

```
harness/run.sh explain <name> 3 <skill-path>
python3 harness/compare.py explain/runs/<name> explain/runs/baseline-1 explain/runs/baseline-2
EVAL_CASES=holdout harness/run.sh explain holdout-<name> 3 <skill-path>
python3 harness/compare.py explain/runs/holdout-<name> explain/runs/holdout-baseline-1 explain/runs/holdout-baseline-2
```

Without `<skill-path>`, the run uses the live skill `skills/explain/SKILL.md`.

When a candidate becomes the live skill, run it a second time on both case sets. Then replace the four baseline runs with its four runs.

A full run with 3 repeats costs about 4 USD and takes about 20 minutes. A run reuses every sample that already exists in its output directory. A reader or grader verdict is cached until its prompt, its key or its measure definitions change.

After a change to a fixture, a key or a measure definition, delete the affected samples and run the baselines again. Old baseline numbers are then not comparable.

## Acceptance criterion

A candidate counts as "performance does not drop" when both conditions hold on both case sets. Run the candidate with 3 repeats. Compare it against both baseline runs together. `compare.py` applies the criterion and exits with 0 on a pass.

1. **Total score.** The candidate total is at least the baseline total minus `2 * sigma * sqrt(1/3 + 1/6)`. `sigma` is the standard deviation of the six baseline repeat scores.
2. **Guard per measure.** For each measure, the candidate rate is at least the baseline rate minus two binomial standard errors. The standard error uses the pooled rate of both sides and the sample counts of both sides.

When two candidates pass, prefer the one with the lower M6 word count.

Values for the live skill (192 lines):

| Case set | Baseline total | `sigma` | Total margin | Fail below | Repeat range |
| --- | --- | --- | --- | --- | --- |
| `cases` | 0.872 | 0.035 | 0.050 | 0.822 | 0.815 to 0.914 |
| `holdout` | 0.856 | 0.037 | 0.052 | 0.804 | 0.819 to 0.903 |

With 3 candidate repeats, the measure margins are about 0.10 to 0.20 for M2 to M7. M1 sits at 1.000 on `cases`, so its margin is small. Two M1 misses in 36 samples can fail it.

Never compare against one baseline run. One run gives `sigma` from 3 repeats only. The live skill failed against itself in that setup: `holdout-baseline-2` scored 0.824 against 0.889 for `holdout-baseline-1`, with a margin of 0.023.

The total margin catches a broad drop of about 5 points. The measure guard catches a single measure that drops by more than 10 to 20 points. A drop in one case only is below the resolution of this eval. Read the cell table of the report for that.

## Non-discriminating cells

`EVAL_SUITE=explain python3 harness/discriminate.py explain/runs/control explain/runs/baseline-1 explain/runs/baseline-2` writes `nondiscriminating.json`. The report flags those cells. The stored flags come from the first eval round, which compared the control with the 267-line skill. Git does not track those runs.

33 of 81 cells are non-discriminating. 23 of them sit at the ceiling: the baseline passes 6 of 6 and the control passes 2 of 2. These cells test basic competence of the model. They stay in the score, because a refactor can still break them. The other 10 cells are weak in both arms. Examples: `11-selfdebate-source:M3` and `12-selfdebate-allowlist:M7`. They show where the baseline skill does not reach its goal.

## Known limits

- The reader and the grader are the same model family as the generator. They can share its blind spots.
- The grader is not deterministic. One regrade of one case moved a run total by about 0.01.
- Each measure-case cell holds 3 samples per run. A cell result is a weak signal. Read cells as hints, and use the totals and the measure rates for decisions.
- MF has one case in `cases/` and two cases in `holdout/`. Its guard is wide.
- `rules.json` maps the diagnostic checks to the rules of the 267-line skill. Some rule ids no longer match the live skill. The diagnostics do not count toward the score.
- The answer keys hold one author's judgment on the correct options. A disputed verdict needs a key review, not a prompt change.
