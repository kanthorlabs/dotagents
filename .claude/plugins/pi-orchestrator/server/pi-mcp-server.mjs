import { spawn } from "node:child_process";
import { realpath, stat } from "node:fs/promises";
import { isAbsolute } from "node:path";
import { StringDecoder } from "node:string_decoder";
import { classifyMetrics } from "./routing.mjs";

const SERVER_VERSION = "0.3.0";
const DEFAULT_PROTOCOL_VERSION = "2024-11-05";
const MAX_RECORD_BYTES = 10 * 1024 * 1024;
const MAX_RESPONSE_BYTES = 50 * 1024;
const MAX_STDERR_CHARS = 16 * 1024;
const COMMAND_TIMEOUT_MS = readPositiveInteger("PI_ORCHESTRATOR_COMMAND_TIMEOUT_MS", 30_000);
const START_TIMEOUT_MS = readPositiveInteger("PI_ORCHESTRATOR_START_TIMEOUT_MS", 30_000);
const TASK_TIMEOUT_MS = readPositiveInteger("PI_ORCHESTRATOR_TASK_TIMEOUT_MS", 30 * 60_000);
const PI_COMMAND = process.env.PI_ORCHESTRATOR_PI_COMMAND?.trim() || "pi";
const PI_PREFIX_ARGS = readStringArray("PI_ORCHESTRATOR_PI_ARGS", []);

const WORKER_PROTOCOL = `Act as the implementation worker for a Claude Code orchestrator.
Complete the delegated task directly in the current working directory.
Inspect existing changes before edits and preserve unrelated work.
Run the strongest relevant validation available.
Do not invoke Claude Code or delegate the task again.
If blocked, stop and state the exact information required.
End the final response with these sections:
STATUS: completed, blocked, or failed
SUMMARY
CHANGES
VALIDATION
QUESTIONS

Task from Claude Code:`;

const FOLLOW_UP_PROTOCOL = `Continue the existing delegated task for the Claude Code orchestrator.
Apply the correction or answer below in the current working directory.
Run relevant validation again.
End the final response with STATUS, SUMMARY, CHANGES, VALIDATION, and QUESTIONS.

Follow-up from Claude Code:`;

function metricInputSchema(description) {
  return {
    type: "object",
    properties: {
      score: {
        type: "integer",
        minimum: 0,
        maximum: 2,
        description
      },
      evidence: {
        type: "string",
        minLength: 12,
        description: "Specific task or inspection evidence supporting this score."
      }
    },
    required: ["score", "evidence"],
    additionalProperties: false
  };
}

const TOOLS = [
  {
    name: "delegate",
    description: "Delegate one self-contained coding task to a persistent Pi worker. Pi can inspect files, modify files, and run commands in cwd. Include the objective, context, constraints, acceptance criteria, and required validation. The call returns only after Pi fully settles.",
    inputSchema: {
      type: "object",
      properties: {
        task: {
          type: "string",
          minLength: 1,
          description: "Complete task packet with objective, context, constraints, acceptance criteria, and validation requirements."
        },
        cwd: {
          type: "string",
          minLength: 1,
          description: "Absolute working directory for the Pi worker."
        },
        metrics: {
          type: "object",
          description: "Evidence-backed semantic scores. The bridge validates these values and computes the route.",
          properties: {
            reasoning_depth: metricInputSchema("0: mechanical. 1: normal design or debugging. 2: multiple hypotheses, algorithms, or invariants."),
            system_span: metricInputSchema("0: one local unit. 1: several files in one subsystem. 2: multiple subsystems, contracts, or repositories."),
            uncertainty: metricInputSchema("0: clear cause and solution. 1: some discovery. 2: unclear cause, requirements, or solution."),
            impact_risk: metricInputSchema("0: local and reversible. 1: public behavior or compatibility. 2: security, data, migration, concurrency, or irreversible impact."),
            verification_complexity: metricInputSchema("0: one deterministic check. 1: multiple tests or integration checks. 2: E2E, performance, nondeterminism, or missing infrastructure.")
          },
          required: [
            "reasoning_depth",
            "system_span",
            "uncertainty",
            "impact_risk",
            "verification_complexity"
          ],
          additionalProperties: false
        },
        inspection: {
          type: "object",
          description: "Context used to score the task before delegation.",
          properties: {
            inspected_paths: {
              type: "array",
              items: { type: "string", minLength: 1 },
              uniqueItems: true,
              description: "Project paths inspected before scoring. Empty only for a self-contained task."
            },
            self_contained: {
              type: "boolean",
              description: "True only when the task text fully determines scope, risk, solution, and validation."
            },
            evidence: {
              type: "string",
              minLength: 12,
              description: "Why the inspected context or self-contained task is sufficient for scoring."
            }
          },
          required: ["inspected_paths", "self_contained", "evidence"],
          additionalProperties: false
        }
      },
      required: ["task", "cwd", "metrics", "inspection"],
      additionalProperties: false
    }
  },
  {
    name: "follow_up",
    description: "Continue a Pi task in the same session. Use this for answers, review findings, corrections, or additional validation.",
    inputSchema: {
      type: "object",
      properties: {
        task_id: {
          type: "string",
          minLength: 1,
          description: "Task identifier returned by delegate."
        },
        message: {
          type: "string",
          minLength: 1,
          description: "Answer, correction, review finding, or additional requirement."
        }
      },
      required: ["task_id", "message"],
      additionalProperties: false
    }
  },
  {
    name: "status",
    description: "Inspect one Pi task or list all tasks without changing their sessions.",
    inputSchema: {
      type: "object",
      properties: {
        task_id: {
          type: "string",
          minLength: 1,
          description: "Optional task identifier returned by delegate."
        }
      },
      additionalProperties: false
    }
  },
  {
    name: "abort",
    description: "Abort the active run for one Pi task while preserving its session for a later follow-up.",
    inputSchema: {
      type: "object",
      properties: {
        task_id: {
          type: "string",
          minLength: 1,
          description: "Task identifier returned by delegate."
        }
      },
      required: ["task_id"],
      additionalProperties: false
    }
  },
  {
    name: "close",
    description: "Close one Pi worker process and remove it from the bridge. Close only after Claude finishes verification.",
    inputSchema: {
      type: "object",
      properties: {
        task_id: {
          type: "string",
          minLength: 1,
          description: "Task identifier returned by delegate."
        }
      },
      required: ["task_id"],
      additionalProperties: false
    }
  }
];

function readPositiveInteger(name, fallback) {
  const value = process.env[name];
  if (value === undefined || value === "") return fallback;
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer`);
  }
  return parsed;
}

function readStringArray(name, fallback) {
  const value = process.env[name];
  if (value === undefined || value === "") return fallback;
  const parsed = JSON.parse(value);
  if (!Array.isArray(parsed) || parsed.some((item) => typeof item !== "string")) {
    throw new Error(`${name} must be a JSON array of strings`);
  }
  return parsed;
}

function createDeferred() {
  let resolve;
  const promise = new Promise((resolveValue) => {
    resolve = resolveValue;
  });
  return { promise, resolve };
}

function waitWithTimeout(promise, timeoutMs, message) {
  let timeout;
  const timeoutPromise = new Promise((_, reject) => {
    timeout = setTimeout(() => reject(new Error(message)), timeoutMs);
  });
  return Promise.race([promise, timeoutPromise]).finally(() => clearTimeout(timeout));
}

function errorMessage(error) {
  return error instanceof Error ? error.message : String(error);
}

function truncateUtf8(value, maxBytes = MAX_RESPONSE_BYTES) {
  const text = String(value ?? "");
  const bytes = Buffer.from(text);
  if (bytes.length <= maxBytes) return { text, truncated: false };
  return {
    text: `${bytes.subarray(0, maxBytes).toString("utf8")}\n\n[Pi response truncated by the bridge]`,
    truncated: true
  };
}

function parseOutcome(text, stopReason) {
  if (stopReason === "aborted") return "aborted";
  if (stopReason === "error") return "failed";
  const match = text.match(/(?:^|\n)\s*(?:\*\*)?STATUS(?:\*\*)?\s*:\s*(completed|blocked|failed)\b/i);
  if (match) return match[1].toLowerCase();
  return text.trim() ? "completed" : "failed";
}

function createJsonLineReader(stream, handlers) {
  const decoder = new StringDecoder("utf8");
  let buffer = "";
  let ended = false;

  const consume = (final) => {
    while (true) {
      const newlineIndex = buffer.indexOf("\n");
      if (newlineIndex === -1) break;
      let line = buffer.slice(0, newlineIndex);
      buffer = buffer.slice(newlineIndex + 1);
      if (line.endsWith("\r")) line = line.slice(0, -1);
      if (Buffer.byteLength(line) > MAX_RECORD_BYTES) {
        handlers.onError(new Error(`JSONL record exceeds ${MAX_RECORD_BYTES} bytes`));
        continue;
      }
      if (line.length > 0) handlers.onLine(line);
    }
    if (Buffer.byteLength(buffer) > MAX_RECORD_BYTES) {
      handlers.onError(new Error(`JSONL record exceeds ${MAX_RECORD_BYTES} bytes`));
      buffer = "";
    }
    if (final && buffer.length > 0) {
      const line = buffer.endsWith("\r") ? buffer.slice(0, -1) : buffer;
      buffer = "";
      if (line.length > 0) handlers.onLine(line);
    }
  };

  stream.on("data", (chunk) => {
    if (ended) return;
    buffer += typeof chunk === "string" ? chunk : decoder.write(chunk);
    consume(false);
  });
  stream.on("error", (error) => handlers.onError(error));
  stream.on("end", () => {
    if (ended) return;
    ended = true;
    buffer += decoder.end();
    consume(true);
    handlers.onEnd?.();
  });
}

async function normalizeCwd(value) {
  if (typeof value !== "string" || value.trim() === "") {
    throw new Error("cwd must be a non-empty absolute path");
  }
  if (!isAbsolute(value)) throw new Error("cwd must be an absolute path");
  const normalized = await realpath(value);
  const details = await stat(normalized);
  if (!details.isDirectory()) throw new Error("cwd must identify a directory");
  return normalized;
}

function requireString(object, key) {
  const value = object?.[key];
  if (typeof value !== "string" || value.trim() === "") {
    throw new Error(`${key} must be a non-empty string`);
  }
  return value;
}

class PiSession {
  constructor(taskId, cwd, routing) {
    this.taskId = taskId;
    this.cwd = cwd;
    this.routing = routing;
    this.createdAt = new Date().toISOString();
    this.state = "starting";
    this.runCount = 0;
    this.rpcSequence = 0;
    this.pending = new Map();
    this.stderr = "";
    this.sessionId = undefined;
    this.sessionFile = undefined;
    this.lastResult = undefined;
    this.currentRun = undefined;
    this.cancelRequested = false;
    this.closing = false;
    this.exit = createDeferred();
  }

  async start() {
    const environment = { ...process.env, PI_SKIP_VERSION_CHECK: "1" };
    const args = [
      ...PI_PREFIX_ARGS,
      "--mode",
      "rpc",
      "--name",
      `claude-${this.taskId}`,
      "--model",
      `${this.routing.provider}/${this.routing.model}`,
      "--thinking",
      this.routing.effort
    ];
    this.child = spawn(PI_COMMAND, args, {
      cwd: this.cwd,
      env: environment,
      stdio: ["pipe", "pipe", "pipe"]
    });
    this.child.stdin.on("error", (error) => this.fail(error));
    this.child.stderr.on("data", (chunk) => {
      this.stderr = `${this.stderr}${chunk.toString()}`.slice(-MAX_STDERR_CHARS);
    });
    createJsonLineReader(this.child.stdout, {
      onLine: (line) => this.consumePiLine(line),
      onError: (error) => this.fail(error),
      onEnd: () => undefined
    });
    this.child.once("error", (error) => this.fail(error));
    this.child.once("close", (code, signal) => this.handleExit(code, signal));

    const response = await this.request({ type: "get_state" }, START_TIMEOUT_MS);
    this.updateSessionState(response.data);
    this.verifyRouting(response.data);
    this.state = "idle";
  }

  consumePiLine(line) {
    let event;
    try {
      event = JSON.parse(line);
    } catch (error) {
      this.fail(new Error(`Pi emitted invalid JSONL: ${errorMessage(error)}`));
      return;
    }

    if (event?.type === "response" && event.id !== undefined) {
      const pending = this.pending.get(event.id);
      if (!pending) return;
      this.pending.delete(event.id);
      clearTimeout(pending.timeout);
      if (event.success) pending.resolve(event);
      else pending.reject(new Error(event.error || `${event.command || "Pi command"} failed`));
      return;
    }

    if (event?.type === "extension_ui_request") {
      this.handleExtensionUiRequest(event);
      return;
    }

    const run = this.currentRun;
    if (!run) return;

    if (event?.type === "agent_settled") run.settled.resolve();
    if (event?.type === "message_end" && event.message?.role === "assistant") {
      run.lastAssistant = event.message;
    }
    if (event?.type === "tool_execution_start") {
      run.toolCalls.set(event.toolCallId, { name: event.toolName, failed: false });
    }
    if (event?.type === "tool_execution_end") {
      const call = run.toolCalls.get(event.toolCallId) || { name: event.toolName, failed: false };
      call.failed = Boolean(event.isError);
      run.toolCalls.set(event.toolCallId, call);
    }
    if (event?.type === "extension_error") {
      run.extensionErrors.push({
        event: event.event,
        error: event.error,
        extension: event.extensionPath
      });
    }
  }

  handleExtensionUiRequest(event) {
    const run = this.currentRun;
    if (run) {
      run.interactions.push({
        method: event.method,
        title: event.title,
        message: event.message,
        placeholder: event.placeholder,
        options: event.options,
        notification: event.notifyType
      });
    }
    if (["select", "confirm", "input", "editor"].includes(event.method)) {
      this.send({ type: "extension_ui_response", id: event.id, cancelled: true });
    }
  }

  send(command) {
    if (!this.child?.stdin || this.child.stdin.destroyed) {
      throw new Error("Pi RPC stdin is unavailable");
    }
    this.child.stdin.write(`${JSON.stringify(command)}\n`);
  }

  request(command, timeoutMs = COMMAND_TIMEOUT_MS) {
    const id = `${this.taskId}:${++this.rpcSequence}`;
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`Pi RPC command timed out: ${command.type}`));
      }, timeoutMs);
      this.pending.set(id, { resolve, reject, timeout });
      try {
        this.send({ ...command, id });
      } catch (error) {
        clearTimeout(timeout);
        this.pending.delete(id);
        reject(error);
      }
    });
  }

  updateSessionState(data) {
    if (!data || typeof data !== "object") return;
    if (typeof data.sessionId === "string") this.sessionId = data.sessionId;
    if (typeof data.sessionFile === "string") this.sessionFile = data.sessionFile;
  }

  verifyRouting(data) {
    const selected = data?.model;
    if (selected?.provider !== this.routing.provider || selected?.id !== this.routing.model) {
      const actual = selected ? `${selected.provider}/${selected.id}` : "none";
      const expected = `${this.routing.provider}/${this.routing.model}`;
      throw new Error(`Pi selected ${actual}; expected ${expected}`);
    }
    if (data?.thinkingLevel !== this.routing.effort) {
      throw new Error(`Pi selected ${data?.thinkingLevel || "none"} effort; expected ${this.routing.effort}`);
    }
  }

  async run(message, kind) {
    if (this.state !== "idle") {
      throw new Error(`Task ${this.taskId} is ${this.state}`);
    }

    this.state = "running";
    this.cancelRequested = false;
    this.runCount += 1;
    const startedAt = Date.now();
    const settled = createDeferred();
    const run = {
      settled,
      lastAssistant: undefined,
      toolCalls: new Map(),
      extensionErrors: [],
      interactions: []
    };
    this.currentRun = run;

    try {
      await this.request({ type: "prompt", message });
      await waitWithTimeout(
        settled.promise,
        TASK_TIMEOUT_MS,
        `Pi task timed out after ${TASK_TIMEOUT_MS}ms`
      );
      if (run.transportError) throw new Error(run.transportError);
      const [textResponse, stateResponse] = await Promise.all([
        this.request({ type: "get_last_assistant_text" }),
        this.request({ type: "get_state" })
      ]);
      this.updateSessionState(stateResponse.data);
      const rawText = textResponse.data?.text || "";
      const response = truncateUtf8(rawText);
      const stopReason = run.lastAssistant?.stopReason;
      const outcome = parseOutcome(rawText, stopReason);
      const toolCalls = [...run.toolCalls.values()];
      const result = {
        task_id: this.taskId,
        outcome,
        run: this.runCount,
        kind,
        cwd: this.cwd,
        routing: this.routing,
        pi_session_id: this.sessionId,
        pi_session_file: this.sessionFile,
        response: response.text,
        response_truncated: response.truncated,
        stop_reason: stopReason,
        tools: {
          total: toolCalls.length,
          failed: toolCalls.filter((call) => call.failed).length,
          names: [...new Set(toolCalls.map((call) => call.name))]
        },
        interaction_requests: run.interactions,
        extension_errors: run.extensionErrors,
        elapsed_ms: Date.now() - startedAt
      };
      this.lastResult = result;
      return result;
    } catch (error) {
      const timedOut = errorMessage(error).startsWith("Pi task timed out after");
      if (timedOut && this.child?.exitCode === null) {
        await this.abort().catch(() => undefined);
      }
      const result = {
        task_id: this.taskId,
        outcome: timedOut ? "timed_out" : "failed",
        run: this.runCount,
        kind,
        cwd: this.cwd,
        routing: this.routing,
        pi_session_id: this.sessionId,
        pi_session_file: this.sessionFile,
        error: errorMessage(error),
        stderr: this.stderr || undefined,
        elapsed_ms: Date.now() - startedAt
      };
      this.lastResult = result;
      return result;
    } finally {
      this.currentRun = undefined;
      if (!this.closing && this.child?.exitCode === null) this.state = "idle";
    }
  }

  async abort() {
    if (this.state === "starting") {
      this.cancelRequested = true;
      if (this.child?.exitCode === null) this.child.kill("SIGTERM");
      return this.snapshot();
    }
    if (this.state !== "running") return this.snapshot();
    this.cancelRequested = true;
    await this.request({ type: "abort" });
    return this.snapshot();
  }

  snapshot() {
    return {
      task_id: this.taskId,
      state: this.state,
      cwd: this.cwd,
      routing: this.routing,
      pi_session_id: this.sessionId,
      pi_session_file: this.sessionFile,
      run_count: this.runCount,
      created_at: this.createdAt,
      last_outcome: this.lastResult?.outcome,
      last_error: this.lastResult?.error
    };
  }

  rejectOutstanding(reason) {
    for (const pending of this.pending.values()) {
      clearTimeout(pending.timeout);
      pending.reject(new Error(reason));
    }
    this.pending.clear();
    if (this.currentRun) {
      this.currentRun.transportError = reason;
      this.currentRun.settled.resolve();
    }
  }

  fail(error) {
    if (this.failure) return;
    this.failure = errorMessage(error);
    if (!this.closing) this.state = "failed";
    this.rejectOutstanding(this.failure);
    if (this.child?.exitCode === null) this.child.kill("SIGTERM");
  }

  handleExit(code, signal) {
    const detail = this.stderr.trim();
    const suffix = detail ? `: ${detail}` : "";
    const reason = `Pi RPC exited with code ${code ?? "null"} and signal ${signal ?? "none"}${suffix}`;
    if (!this.closing) this.failure = this.failure || reason;
    this.rejectOutstanding(this.failure || reason);
    this.state = this.closing ? "closed" : "failed";
    this.exit.resolve();
  }

  async close() {
    if (this.state === "closed") return;
    this.closing = true;
    if (!this.child) {
      this.state = "closed";
      this.exit.resolve();
      return;
    }
    if (this.state === "running") {
      await this.request({ type: "abort" }).catch(() => undefined);
    }
    if (this.child.exitCode === null) this.child.kill("SIGTERM");
    try {
      await waitWithTimeout(this.exit.promise, 2_000, "Pi RPC shutdown timed out");
    } catch {
      if (this.child.exitCode === null) this.child.kill("SIGKILL");
      await this.exit.promise;
    }
    this.state = "closed";
  }
}

const sessions = new Map();
const activeRequests = new Map();
let taskSequence = 0;
let shuttingDown = false;

function nextTaskId() {
  taskSequence += 1;
  return `pi-${Date.now().toString(36)}-${taskSequence.toString(36)}`;
}

function getSession(taskId) {
  const session = sessions.get(taskId);
  if (!session) throw new Error(`Unknown task_id: ${taskId}`);
  return session;
}

function textResult(payload, isError = false) {
  return {
    content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
    isError
  };
}

async function callTool(name, args, requestId) {
  if (name === "delegate") {
    const task = requireString(args, "task");
    const cwd = await normalizeCwd(requireString(args, "cwd"));
    const routing = classifyMetrics(args?.metrics, args?.inspection);
    const taskId = nextTaskId();
    const session = new PiSession(taskId, cwd, routing);
    sessions.set(taskId, session);
    activeRequests.set(requestId, session);
    try {
      await session.start();
      const result = await session.run(`${WORKER_PROTOCOL}\n\n${task}`, "delegate");
      return textResult(result, ["failed", "aborted", "timed_out"].includes(result.outcome));
    } catch (error) {
      const outcome = session.cancelRequested ? "aborted" : "failed";
      await session.close().catch(() => undefined);
      const result = {
        task_id: taskId,
        outcome,
        cwd,
        routing,
        error: errorMessage(error),
        stderr: session.stderr || undefined
      };
      session.lastResult = result;
      session.state = "failed";
      return textResult(result, true);
    } finally {
      activeRequests.delete(requestId);
    }
  }

  if (name === "follow_up") {
    const taskId = requireString(args, "task_id");
    const message = requireString(args, "message");
    const session = getSession(taskId);
    activeRequests.set(requestId, session);
    try {
      const result = await session.run(`${FOLLOW_UP_PROTOCOL}\n\n${message}`, "follow_up");
      return textResult(result, ["failed", "aborted", "timed_out"].includes(result.outcome));
    } finally {
      activeRequests.delete(requestId);
    }
  }

  if (name === "status") {
    const taskId = args?.task_id;
    if (taskId !== undefined) {
      if (typeof taskId !== "string" || taskId.trim() === "") {
        throw new Error("task_id must be a non-empty string");
      }
      return textResult(getSession(taskId).snapshot());
    }
    return textResult({ tasks: [...sessions.values()].map((session) => session.snapshot()) });
  }

  if (name === "abort") {
    const taskId = requireString(args, "task_id");
    const session = getSession(taskId);
    await session.abort();
    return textResult({ task_id: taskId, abort_requested: true, state: session.state });
  }

  if (name === "close") {
    const taskId = requireString(args, "task_id");
    const session = getSession(taskId);
    await session.close();
    sessions.delete(taskId);
    return textResult({ task_id: taskId, closed: true });
  }

  throw new Error(`Unknown tool: ${name}`);
}

function sendJsonRpc(message) {
  process.stdout.write(`${JSON.stringify(message)}\n`);
}

function sendResult(id, result) {
  sendJsonRpc({ jsonrpc: "2.0", id, result });
}

function sendError(id, code, message) {
  sendJsonRpc({ jsonrpc: "2.0", id, error: { code, message } });
}

async function handleRequest(message) {
  const id = message.id;
  const method = message.method;

  if (method === "initialize") {
    sendResult(id, {
      protocolVersion: message.params?.protocolVersion || DEFAULT_PROTOCOL_VERSION,
      capabilities: { tools: { listChanged: false } },
      serverInfo: { name: "pi-orchestrator", version: SERVER_VERSION },
      instructions: "Support every metric with evidence. Inspect project paths unless the task is self-contained. The bridge validates the assessment and computes the route."
    });
    return;
  }

  if (method === "ping") {
    sendResult(id, {});
    return;
  }

  if (method === "tools/list") {
    sendResult(id, { tools: TOOLS });
    return;
  }

  if (method === "tools/call") {
    const name = message.params?.name;
    if (typeof name !== "string") {
      sendError(id, -32602, "tools/call requires a tool name");
      return;
    }
    try {
      const result = await callTool(name, message.params?.arguments || {}, id);
      sendResult(id, result);
    } catch (error) {
      sendResult(id, textResult({ outcome: "failed", error: errorMessage(error) }, true));
    }
    return;
  }

  sendError(id, -32601, `Method not found: ${method}`);
}

function handleNotification(message) {
  if (message.method !== "notifications/cancelled") return;
  const session = activeRequests.get(message.params?.requestId);
  if (session) session.abort().catch(() => undefined);
}

function consumeClientLine(line) {
  let message;
  try {
    message = JSON.parse(line);
  } catch (error) {
    sendError(null, -32700, `Parse error: ${errorMessage(error)}`);
    return;
  }
  if (!message || message.jsonrpc !== "2.0" || typeof message.method !== "string") {
    sendError(message?.id ?? null, -32600, "Invalid JSON-RPC request");
    return;
  }
  if (message.id === undefined) {
    handleNotification(message);
    return;
  }
  handleRequest(message).catch((error) => sendError(message.id, -32603, errorMessage(error)));
}

async function shutdown(exitCode = 0) {
  if (shuttingDown) return;
  shuttingDown = true;
  await Promise.allSettled([...sessions.values()].map((session) => session.close()));
  process.exitCode = exitCode;
}

createJsonLineReader(process.stdin, {
  onLine: consumeClientLine,
  onError: (error) => {
    process.stderr.write(`${errorMessage(error)}\n`);
    shutdown(1).catch(() => undefined);
  },
  onEnd: () => shutdown(0).catch(() => undefined)
});

process.stdout.on("error", (error) => {
  if (error.code !== "EPIPE") process.stderr.write(`${errorMessage(error)}\n`);
  shutdown(error.code === "EPIPE" ? 0 : 1).catch(() => undefined);
});
process.on("SIGINT", () => shutdown(0).then(() => process.exit(0)));
process.on("SIGTERM", () => shutdown(0).then(() => process.exit(0)));
