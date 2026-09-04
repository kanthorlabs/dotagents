export const METRIC_NAMES = [
  "reasoning_depth",
  "system_span",
  "uncertainty",
  "impact_risk",
  "verification_complexity"
];

const HARD_ROUTE = {
  provider: "openai-codex",
  model: "gpt-5.6-sol",
  effort: "high"
};

const OTHER_ROUTE = {
  provider: "openai-codex",
  model: "gpt-5.6-luna",
  effort: "max"
};

export function validateMetrics(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error("metrics must be an object");
  }

  const unknown = Object.keys(value).filter((name) => !METRIC_NAMES.includes(name));
  if (unknown.length > 0) {
    throw new Error(`Unknown metrics: ${unknown.join(", ")}`);
  }

  const metrics = {};
  for (const name of METRIC_NAMES) {
    const score = value[name];
    if (!Number.isInteger(score) || score < 0 || score > 2) {
      throw new Error(`${name} must be an integer from 0 through 2`);
    }
    metrics[name] = score;
  }
  return metrics;
}

export function classifyMetrics(value) {
  const metrics = validateMetrics(value);
  const score = METRIC_NAMES.reduce((total, name) => total + metrics[name], 0);
  const reasons = [];

  if (score >= 6) reasons.push("score>=6");
  if (metrics.impact_risk === 2) reasons.push("impact_risk=2");
  if (metrics.reasoning_depth === 2 && metrics.uncertainty === 2) {
    reasons.push("reasoning_depth=2+uncertainty=2");
  }
  if (metrics.system_span === 2 && metrics.verification_complexity === 2) {
    reasons.push("system_span=2+verification_complexity=2");
  }

  const classification = reasons.length > 0 ? "hard" : "other";
  const route = classification === "hard" ? HARD_ROUTE : OTHER_ROUTE;
  return {
    classification,
    score,
    reasons,
    metrics,
    ...route
  };
}
