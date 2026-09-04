import assert from "node:assert/strict";
import test from "node:test";
import { classifyMetrics, validateMetrics } from "../server/routing.mjs";

const base = {
  reasoning_depth: 0,
  system_span: 0,
  uncertainty: 0,
  impact_risk: 0,
  verification_complexity: 0
};

function classify(changes) {
  return classifyMetrics({ ...base, ...changes });
}

test("routes totals below six to Luna with max effort", () => {
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
});

test("routes a total of six to Sol with high effort", () => {
  const result = classify({
    reasoning_depth: 1,
    system_span: 1,
    uncertainty: 1,
    impact_risk: 1,
    verification_complexity: 2
  });
  assert.equal(result.score, 6);
  assert.equal(result.classification, "hard");
  assert.equal(result.model, "gpt-5.6-sol");
  assert.equal(result.effort, "high");
  assert.deepEqual(result.reasons, ["score>=6"]);
});

test("applies the impact-risk override", () => {
  const result = classify({ impact_risk: 2 });
  assert.equal(result.score, 2);
  assert.equal(result.classification, "hard");
  assert.deepEqual(result.reasons, ["impact_risk=2"]);
});

test("applies the reasoning-and-uncertainty override", () => {
  const result = classify({ reasoning_depth: 2, uncertainty: 2 });
  assert.equal(result.score, 4);
  assert.equal(result.classification, "hard");
  assert.deepEqual(result.reasons, ["reasoning_depth=2+uncertainty=2"]);
});

test("applies the span-and-verification override", () => {
  const result = classify({ system_span: 2, verification_complexity: 2 });
  assert.equal(result.score, 4);
  assert.equal(result.classification, "hard");
  assert.deepEqual(result.reasons, ["system_span=2+verification_complexity=2"]);
});

test("rejects incomplete, out-of-range, and unknown metrics", () => {
  assert.throws(() => validateMetrics({}), /reasoning_depth/);
  assert.throws(() => validateMetrics({ ...base, uncertainty: 3 }), /uncertainty/);
  assert.throws(() => validateMetrics({ ...base, extra: 1 }), /Unknown metrics: extra/);
});
