export const METRIC_NAMES = [
  "reasoning_depth",
  "system_span",
  "uncertainty",
  "impact_risk",
  "verification_complexity"
];

const ZERO_REQUIREMENTS = {
  reasoning_depth: "a mechanical change",
  system_span: "one local unit",
  uncertainty: "a clear cause and solution",
  impact_risk: "a local and reversible change",
  verification_complexity: "one deterministic check"
};

const HARD_ROUTE = {
  provider: "openai-codex",
  model: "gpt-6-astra",
  effort: "high"
};

const OTHER_ROUTE = {
  provider: "openai-codex",
  model: "gpt-5.6-luna",
  effort: "max"
};

function wordCount(value) {
  return value.split(/\s+/).filter((word) => /[\p{L}\p{N}]/u.test(word)).length;
}

function requireObject(value, name) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error(`${name} must be an object`);
  }
}

function rejectUnknownKeys(value, allowed, name) {
  const unknown = Object.keys(value).filter((key) => !allowed.includes(key));
  if (unknown.length > 0) throw new Error(`Unknown ${name}: ${unknown.join(", ")}`);
}

function requireEvidence(value, name, minimumWords) {
  if (typeof value !== "string" || value.trim().length < 12) {
    throw new Error(`${name} evidence must contain at least 12 characters`);
  }
  const evidence = value.trim();
  if (wordCount(evidence) < minimumWords) {
    throw new Error(`${name} evidence must contain at least ${minimumWords} words`);
  }
  return evidence;
}

export function validateMetrics(value) {
  requireObject(value, "metrics");
  rejectUnknownKeys(value, METRIC_NAMES, "metrics");

  const metrics = {};
  for (const name of METRIC_NAMES) {
    const metric = value[name];
    requireObject(metric, name);
    rejectUnknownKeys(metric, ["score", "evidence"], `${name} fields`);

    if (!Number.isInteger(metric.score) || metric.score < 0 || metric.score > 2) {
      throw new Error(`${name} score must be an integer from 0 through 2`);
    }

    const evidence = requireEvidence(metric.evidence, name, 3);
    if (metric.score === 0 && wordCount(evidence) < 5) {
      throw new Error(`${name} score 0 requires five evidence words proving ${ZERO_REQUIREMENTS[name]}`);
    }
    metrics[name] = { score: metric.score, evidence };
  }
  return metrics;
}

export function validateInspection(value) {
  requireObject(value, "inspection");
  rejectUnknownKeys(value, ["inspected_paths", "self_contained", "evidence"], "inspection fields");

  if (!Array.isArray(value.inspected_paths)) {
    throw new Error("inspected_paths must be an array");
  }
  const inspectedPaths = value.inspected_paths.map((path) => {
    if (typeof path !== "string" || path.trim() === "") {
      throw new Error("Each inspected path must be a non-empty string");
    }
    return path.trim();
  });
  if (new Set(inspectedPaths).size !== inspectedPaths.length) {
    throw new Error("inspected_paths must not contain duplicates");
  }
  if (typeof value.self_contained !== "boolean") {
    throw new Error("self_contained must be a boolean");
  }
  const evidence = requireEvidence(value.evidence, "inspection", 4);
  if (inspectedPaths.length === 0 && !value.self_contained) {
    throw new Error("Inspect at least one path or mark the task self-contained with evidence");
  }

  return {
    inspected_paths: inspectedPaths,
    self_contained: value.self_contained,
    evidence
  };
}

export function classifyMetrics(metricValues, inspectionValue) {
  const metrics = validateMetrics(metricValues);
  const inspection = validateInspection(inspectionValue);
  const score = METRIC_NAMES.reduce((total, name) => total + metrics[name].score, 0);
  const reasons = [];

  if (score >= 6) reasons.push("score>=6");
  if (metrics.impact_risk.score === 2) reasons.push("impact_risk=2");
  if (metrics.reasoning_depth.score === 2 && metrics.uncertainty.score === 2) {
    reasons.push("reasoning_depth=2+uncertainty=2");
  }
  if (metrics.system_span.score === 2 && metrics.verification_complexity.score === 2) {
    reasons.push("system_span=2+verification_complexity=2");
  }

  const classification = reasons.length > 0 ? "hard" : "other";
  const route = classification === "hard" ? HARD_ROUTE : OTHER_ROUTE;
  return {
    classification,
    score,
    reasons,
    metrics,
    inspection,
    ...route
  };
}
