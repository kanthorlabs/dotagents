import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { StringDecoder } from "node:string_decoder";
import { fileURLToPath } from "node:url";
import test from "node:test";

const testDir = dirname(fileURLToPath(import.meta.url));
const pluginDir = dirname(testDir);
const serverPath = join(pluginDir, "server", "pi-mcp-server.mjs");
const fakePiPath = join(testDir, "fake-pi.mjs");
const OTHER_METRICS = {
  reasoning_depth: {
    score: 0,
    evidence: "The requested operation is entirely mechanical and direct."
  },
  system_span: {
    score: 0,
    evidence: "The requested change affects one local unit only."
  },
  uncertainty: {
    score: 0,
    evidence: "The task states both cause and solution clearly."
  },
  impact_risk: {
    score: 0,
    evidence: "The local change is reversible without external effects."
  },
  verification_complexity: {
    score: 0,
    evidence: "One deterministic assertion verifies the complete requested result."
  }
};
const HARD_METRICS = {
  reasoning_depth: {
    score: 2,
    evidence: "Diagnosis requires multiple competing hypotheses and system invariants."
  },
  system_span: {
    score: 1,
    evidence: "Several related files within one subsystem require coordinated changes."
  },
  uncertainty: {
    score: 2,
    evidence: "The root cause and correct solution remain entirely unknown."
  },
  impact_risk: {
    score: 1,
    evidence: "The change can alter public behavior within one subsystem."
  },
  verification_complexity: {
    score: 0,
    evidence: "One deterministic fixture assertion verifies the complete expected result."
  }
};
const SELF_CONTAINED = {
  inspected_paths: [],
  self_contained: true,
  evidence: "The integration fixture fully specifies operation and expected result."
};

function delegationArgs(cwd, task, metrics = OTHER_METRICS, inspection = SELF_CONTAINED) {
  return { cwd, task, metrics, inspection };
}

class McpClient {
  constructor(environment = {}) {
    this.sequence = 0;
    this.pending = new Map();
    this.stderr = "";
    this.decoder = new StringDecoder("utf8");
    this.buffer = "";
    this.child = spawn(process.execPath, [serverPath], {
      env: {
        ...process.env,
        PI_ORCHESTRATOR_PI_COMMAND: process.execPath,
        PI_ORCHESTRATOR_PI_ARGS: JSON.stringify([
          fakePiPath,
          "--model",
          "wrong/wrong-model",
          "--thinking",
          "off"
        ]),
        PI_ORCHESTRATOR_TASK_TIMEOUT_MS: "5000",
        ...environment
      },
      stdio: ["pipe", "pipe", "pipe"]
    });
    this.child.stdout.on("data", (chunk) => this.consumeChunk(chunk));
    this.child.stderr.on("data", (chunk) => {
      this.stderr += chunk.toString();
    });
    this.child.once("exit", (code) => {
      for (const pending of this.pending.values()) {
        pending.reject(new Error(`MCP server exited with ${code}: ${this.stderr}`));
      }
      this.pending.clear();
    });
  }

  consumeChunk(chunk) {
    this.buffer += this.decoder.write(chunk);
    while (true) {
      const index = this.buffer.indexOf("\n");
      if (index === -1) break;
      let line = this.buffer.slice(0, index);
      this.buffer = this.buffer.slice(index + 1);
      if (line.endsWith("\r")) line = line.slice(0, -1);
      if (!line) continue;
      const message = JSON.parse(line);
      const pending = this.pending.get(message.id);
      if (!pending) continue;
      this.pending.delete(message.id);
      if (message.error) pending.reject(new Error(message.error.message));
      else pending.resolve(message.result);
    }
  }

  request(method, params) {
    const id = ++this.sequence;
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`MCP request timed out: ${method}\n${this.stderr}`));
      }, 10_000);
      this.pending.set(id, {
        resolve: (value) => {
          clearTimeout(timeout);
          resolve(value);
        },
        reject: (error) => {
          clearTimeout(timeout);
          reject(error);
        }
      });
      this.child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id, method, params })}\n`);
    });
  }

  notify(method, params) {
    this.child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", method, params })}\n`);
  }

  async initialize() {
    const result = await this.request("initialize", {
      protocolVersion: "2025-03-26",
      capabilities: {},
      clientInfo: { name: "pi-orchestrator-test", version: "1.0.0" }
    });
    this.notify("notifications/initialized", {});
    return result;
  }

  async call(name, args = {}) {
    return this.request("tools/call", { name, arguments: args });
  }

  async close() {
    if (this.child.exitCode !== null) return;
    this.child.stdin.end();
    await new Promise((resolve) => this.child.once("exit", resolve));
  }
}

function payload(result) {
  assert.equal(result.content.length, 1);
  assert.equal(result.content[0].type, "text");
  return JSON.parse(result.content[0].text);
}

test("exposes the orchestration tools through MCP", async (context) => {
  const client = new McpClient();
  context.after(() => client.close());

  const initialized = await client.initialize();
  assert.equal(initialized.serverInfo.name, "pi-orchestrator");
  assert.equal(initialized.protocolVersion, "2025-03-26");

  const listed = await client.request("tools/list", {});
  assert.deepEqual(
    listed.tools.map((tool) => tool.name),
    ["delegate", "follow_up", "status", "abort", "close"]
  );
  assert.deepEqual(listed.tools[0].inputSchema.required, ["task", "cwd", "metrics", "inspection"]);
});

test("delegates, waits for settlement, preserves Unicode, and reuses the Pi session", async (context) => {
  const cwd = await mkdtemp(join(tmpdir(), "pi-orchestrator-test-"));
  const client = new McpClient();
  context.after(async () => {
    await client.close();
    await rm(cwd, { recursive: true, force: true });
  });
  await client.initialize();

  const startedAt = Date.now();
  const delegatedResult = await client.call(
    "delegate",
    delegationArgs(cwd, "Create the requested proof artifact.")
  );
  const delegated = payload(delegatedResult);

  assert.equal(delegatedResult.isError, false);
  assert.equal(delegated.outcome, "completed");
  assert.equal(delegated.run, 1);
  assert.deepEqual(delegated.routing, {
    classification: "other",
    score: 0,
    reasons: [],
    metrics: OTHER_METRICS,
    inspection: SELF_CONTAINED,
    provider: "openai-codex",
    model: "gpt-5.6-luna",
    effort: "max"
  });
  assert.ok(delegated.elapsed_ms >= 50);
  assert.ok(Date.now() - startedAt >= 50);
  const separators = `${String.fromCodePoint(0x2028)} and ${String.fromCodePoint(0x2029)}`;
  assert.ok(delegated.response.includes(`Unicode ${separators}`));
  assert.deepEqual(delegated.tools, { total: 1, failed: 0, names: ["write"] });

  const proof = JSON.parse(await readFile(join(cwd, "fake-pi-proof.json"), "utf8"));
  assert.equal(proof.promptCount, 1);
  assert.equal(proof.model, "openai-codex/gpt-5.6-luna");
  assert.equal(proof.effort, "max");
  assert.match(proof.message, /Task from Claude Code:/);
  assert.match(proof.message, /Create the requested proof artifact\./);

  const followUpResult = await client.call("follow_up", {
    task_id: delegated.task_id,
    message: "Verify the artifact once more."
  });
  const followUp = payload(followUpResult);
  assert.equal(followUp.outcome, "completed");
  assert.equal(followUp.run, 2);
  assert.equal(followUp.pi_session_id, delegated.pi_session_id);

  const followUpProof = JSON.parse(await readFile(join(cwd, "fake-pi-proof.json"), "utf8"));
  assert.equal(followUpProof.pid, proof.pid);
  assert.equal(followUpProof.promptCount, 2);
  assert.match(followUpProof.message, /Follow-up from Claude Code:/);

  const status = payload(await client.call("status", { task_id: delegated.task_id }));
  assert.equal(status.state, "idle");
  assert.equal(status.last_outcome, "completed");
  assert.equal(status.run_count, 2);

  const closed = payload(await client.call("close", { task_id: delegated.task_id }));
  assert.deepEqual(closed, { task_id: delegated.task_id, closed: true });
  const all = payload(await client.call("status"));
  assert.deepEqual(all.tasks, []);
});

test("rejects bare numeric metrics before Pi starts", async (context) => {
  const cwd = await mkdtemp(join(tmpdir(), "pi-orchestrator-bare-metrics-"));
  const client = new McpClient();
  context.after(async () => {
    await client.close();
    await rm(cwd, { recursive: true, force: true });
  });
  await client.initialize();

  const result = await client.call("delegate", {
    cwd,
    task: "Do not start Pi.",
    metrics: {
      reasoning_depth: 0,
      system_span: 0,
      uncertainty: 0,
      impact_risk: 0,
      verification_complexity: 0
    },
    inspection: SELF_CONTAINED
  });
  const failure = payload(result);
  assert.equal(result.isError, true);
  assert.match(failure.error, /reasoning_depth must be an object/);

  const status = payload(await client.call("status"));
  assert.deepEqual(status.tasks, []);
});

test("routes hard tasks to Sol with high effort", async (context) => {
  const cwd = await mkdtemp(join(tmpdir(), "pi-orchestrator-hard-"));
  const client = new McpClient();
  context.after(async () => {
    await client.close();
    await rm(cwd, { recursive: true, force: true });
  });
  await client.initialize();

  const result = await client.call("delegate", delegationArgs(cwd, "Resolve a hard task.", HARD_METRICS));
  const delegated = payload(result);
  assert.equal(result.isError, false);
  assert.equal(delegated.routing.classification, "hard");
  assert.equal(delegated.routing.score, 6);
  assert.deepEqual(delegated.routing.reasons, ["score>=6", "reasoning_depth=2+uncertainty=2"]);
  assert.equal(delegated.routing.model, "gpt-5.6-sol");
  assert.equal(delegated.routing.effort, "high");

  const proof = JSON.parse(await readFile(join(cwd, "fake-pi-proof.json"), "utf8"));
  assert.equal(proof.model, "openai-codex/gpt-5.6-sol");
  assert.equal(proof.effort, "high");
});

test("rejects a Pi model mismatch before prompting", async (context) => {
  const cwd = await mkdtemp(join(tmpdir(), "pi-orchestrator-model-mismatch-"));
  const client = new McpClient({ FAKE_PI_REPORTED_MODEL: "openai-codex/gpt-5.6-sol" });
  context.after(async () => {
    await client.close();
    await rm(cwd, { recursive: true, force: true });
  });
  await client.initialize();

  const result = await client.call("delegate", delegationArgs(cwd, "Do not run."));
  const failure = payload(result);
  assert.equal(result.isError, true);
  assert.equal(failure.outcome, "failed");
  assert.match(failure.error, /selected openai-codex\/gpt-5\.6-sol; expected openai-codex\/gpt-5\.6-luna/);
});

test("rejects a Pi effort mismatch before prompting", async (context) => {
  const cwd = await mkdtemp(join(tmpdir(), "pi-orchestrator-effort-mismatch-"));
  const client = new McpClient({ FAKE_PI_REPORTED_THINKING: "high" });
  context.after(async () => {
    await client.close();
    await rm(cwd, { recursive: true, force: true });
  });
  await client.initialize();

  const result = await client.call("delegate", delegationArgs(cwd, "Do not run."));
  const failure = payload(result);
  assert.equal(result.isError, true);
  assert.equal(failure.outcome, "failed");
  assert.match(failure.error, /selected high effort; expected max/);
});

test("returns cancelled Pi dialog requests as blockers", async (context) => {
  const cwd = await mkdtemp(join(tmpdir(), "pi-orchestrator-dialog-"));
  const client = new McpClient();
  context.after(async () => {
    await client.close();
    await rm(cwd, { recursive: true, force: true });
  });
  await client.initialize();

  const result = await client.call("delegate", delegationArgs(cwd, "__dialog__"));
  const blocked = payload(result);
  assert.equal(result.isError, false);
  assert.equal(blocked.outcome, "blocked");
  assert.deepEqual(blocked.interaction_requests, [
    {
      method: "input",
      title: "Missing input",
      placeholder: "required value"
    }
  ]);
});

test("cancels a Pi worker during startup", async (context) => {
  const cwd = await mkdtemp(join(tmpdir(), "pi-orchestrator-start-cancel-"));
  const client = new McpClient({ FAKE_PI_START_DELAY_MS: "1000" });
  context.after(async () => {
    await client.close();
    await rm(cwd, { recursive: true, force: true });
  });
  await client.initialize();

  const delegateId = client.sequence + 1;
  const delegation = client.call("delegate", delegationArgs(cwd, "Never starts."));

  let sawStarting = false;
  for (let attempt = 0; attempt < 50; attempt += 1) {
    const status = payload(await client.call("status"));
    if (status.tasks[0]?.state === "starting") {
      sawStarting = true;
      break;
    }
    await new Promise((resolve) => setTimeout(resolve, 20));
  }
  assert.equal(sawStarting, true);

  client.notify("notifications/cancelled", { requestId: delegateId, reason: "startup cancellation" });
  const result = await delegation;
  const aborted = payload(result);
  assert.equal(result.isError, true);
  assert.equal(aborted.outcome, "aborted");
});

test("propagates an MCP cancellation to Pi abort", async (context) => {
  const cwd = await mkdtemp(join(tmpdir(), "pi-orchestrator-abort-"));
  const client = new McpClient();
  context.after(async () => {
    await client.close();
    await rm(cwd, { recursive: true, force: true });
  });
  await client.initialize();

  const delegateId = client.sequence + 1;
  const delegation = client.call("delegate", delegationArgs(cwd, "__hang__"));

  let taskId;
  for (let attempt = 0; attempt < 50; attempt += 1) {
    const status = payload(await client.call("status"));
    if (status.tasks[0]?.state === "running") {
      taskId = status.tasks[0].task_id;
      break;
    }
    await new Promise((resolve) => setTimeout(resolve, 20));
  }
  assert.ok(taskId);

  client.notify("notifications/cancelled", { requestId: delegateId, reason: "test cancellation" });
  const result = await delegation;
  const aborted = payload(result);
  assert.equal(result.isError, true);
  assert.equal(aborted.outcome, "aborted");
  assert.equal(aborted.task_id, taskId);
});

test("returns structured failures when Pi exits during a task", async (context) => {
  const cwd = await mkdtemp(join(tmpdir(), "pi-orchestrator-crash-"));
  const client = new McpClient();
  context.after(async () => {
    await client.close();
    await rm(cwd, { recursive: true, force: true });
  });
  await client.initialize();

  const result = await client.call("delegate", delegationArgs(cwd, "__crash__"));
  const failure = payload(result);
  assert.equal(result.isError, true);
  assert.equal(failure.outcome, "failed");
  assert.match(failure.error, /exited with code 7/);
});

test("returns structured failures when Pi cannot start", async (context) => {
  const cwd = await mkdtemp(join(tmpdir(), "pi-orchestrator-failure-"));
  const client = new McpClient({
    PI_ORCHESTRATOR_PI_COMMAND: join(cwd, "missing-pi"),
    PI_ORCHESTRATOR_PI_ARGS: "[]"
  });
  context.after(async () => {
    await client.close();
    await rm(cwd, { recursive: true, force: true });
  });
  await client.initialize();

  const result = await client.call("delegate", delegationArgs(cwd, "This cannot start."));
  const failure = payload(result);
  assert.equal(result.isError, true);
  assert.equal(failure.outcome, "failed");
  assert.match(failure.error, /ENOENT|spawn/);
  assert.ok(failure.task_id);
});
