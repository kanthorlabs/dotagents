import assert from "node:assert/strict";
import test from "node:test";
import {
  classifyMetrics,
  validateInspection,
  validateMetrics
} from "../server/routing.mjs";

const METRIC_NAMES = [
  "reasoning_depth",
  "system_span",
  "uncertainty",
  "impact_risk",
  "verification_complexity"
];

const ZERO_EVIDENCE = {
  reasoning_depth: "The requested operation is entirely mechanical and direct.",
  system_span: "The requested change affects one local unit only.",
  uncertainty: "The task states both cause and solution clearly.",
  impact_risk: "The local change is reversible without external effects.",
  verification_complexity: "One deterministic assertion verifies the complete requested result."
};

const SELF_CONTAINED = {
  inspected_paths: [],
  self_contained: true,
  evidence: "The exact operation and expected result are fully specified."
};

function metrics(scores = {}) {
  return Object.fromEntries(METRIC_NAMES.map((name) => {
    const score = scores[name] ?? 0;
    const evidence = score === 0
      ? ZERO_EVIDENCE[name]
      : `The inspected task evidence supports score ${score} for ${name}.`;
    return [name, { score, evidence }];
  }));
}

function classify(scores, inspection = SELF_CONTAINED) {
  return classifyMetrics(metrics(scores), inspection);
}

test("routes evidence-backed totals below six to Luna with max effort", () => {
  const result = classify({
    reasoning_depth: 1,
    system_span: 1,
    uncertainty: 1,
    impact_risk: 1,
    verification_complexity: 1
  });
  assert.equal(result.score, 5);
  assert.equal(result.classification, "other");
  assert.equal(result.provider, "openai-codex");
  assert.equal(result.model, "gpt-5.6-luna");
  assert.equal(result.effort, "max");
  assert.deepEqual(result.reasons, []);
  assert.deepEqual(result.inspection, SELF_CONTAINED);
});

test("routes an evidence-backed total of six to Sol with high effort", () => {
  const result = classify({
    reasoning_depth: 1,
    system_span: 1,
    uncertainty: 1,
    impact_risk: 1,
    verification_complexity: 2
  });
  assert.equal(result.score, 6);
  assert.equal(result.classification, "hard");
  assert.equal(result.model, "gpt-6-astra");
  assert.equal(result.effort, "high");
  assert.deepEqual(result.reasons, ["score>=6"]);
});

test("applies every hard override", () => {
  assert.deepEqual(
    classify({ impact_risk: 2 }).reasons,
    ["impact_risk=2"]
  );
  assert.deepEqual(
    classify({ reasoning_depth: 2, uncertainty: 2 }).reasons,
    ["reasoning_depth=2+uncertainty=2"]
  );
  assert.deepEqual(
    classify({ system_span: 2, verification_complexity: 2 }).reasons,
    ["system_span=2+verification_complexity=2"]
  );
});

test("rejects bare numeric metrics", () => {
  const bare = Object.fromEntries(METRIC_NAMES.map((name) => [name, 0]));
  assert.throws(() => validateMetrics(bare), /reasoning_depth must be an object/);
});

test("rejects weak zero evidence", () => {
  const values = metrics();
  values.reasoning_depth = { score: 0, evidence: "Mechanical task evidence" };
  assert.throws(
    () => validateMetrics(values),
    /reasoning_depth score 0 requires five evidence words proving a mechanical change/
  );
});

test("rejects incomplete, out-of-range, and unknown metrics", () => {
  assert.throws(() => validateMetrics({}), /reasoning_depth must be an object/);
  assert.throws(
    () => validateMetrics({ ...metrics(), uncertainty: { score: 3, evidence: "Specific inspected evidence supports this assigned score." } }),
    /uncertainty score/
  );
  assert.throws(() => validateMetrics({ ...metrics(), extra: { score: 1, evidence: "Extra evidence is not part of the rubric." } }), /Unknown metrics: extra/);
});

test("requires inspected paths for non-self-contained tasks", () => {
  assert.throws(
    () => validateInspection({
      inspected_paths: [],
      self_contained: false,
      evidence: "The task requires repository context before reliable scoring."
    }),
    /Inspect at least one path/
  );
});

test("accepts unique inspected paths with evidence", () => {
  const inspection = {
    inspected_paths: ["src/auth.ts", "test/auth.test.ts"],
    self_contained: false,
    evidence: "These files define the affected behavior and its verification."
  };
  assert.deepEqual(validateInspection(inspection), inspection);
  assert.throws(
    () => validateInspection({ ...inspection, inspected_paths: ["src/auth.ts", "src/auth.ts"] }),
    /must not contain duplicates/
  );
});
