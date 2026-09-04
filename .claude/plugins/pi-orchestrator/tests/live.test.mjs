import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { StringDecoder } from "node:string_decoder";
import { fileURLToPath } from "node:url";
import test from "node:test";

const enabled = process.env.PI_ORCHESTRATOR_LIVE_TEST === "1";
const testDir = dirname(fileURLToPath(import.meta.url));
const pluginDir = dirname(testDir);
const serverPath = join(pluginDir, "server", "pi-mcp-server.mjs");

function startClient() {
  const environment = { ...process.env, PI_ORCHESTRATOR_TASK_TIMEOUT_MS: "600000" };
  delete environment.PI_ORCHESTRATOR_PI_COMMAND;
  delete environment.PI_ORCHESTRATOR_PI_ARGS;
  const child = spawn(process.execPath, [serverPath], {
    env: environment,
    stdio: ["pipe", "pipe", "pipe"]
  });
  const pending = new Map();
  const decoder = new StringDecoder("utf8");
  let buffer = "";
  let sequence = 0;
  let stderr = "";

  child.stderr.on("data", (chunk) => {
    stderr += chunk.toString();
  });
  child.stdout.on("data", (chunk) => {
    buffer += decoder.write(chunk);
    while (true) {
      const index = buffer.indexOf("\n");
      if (index === -1) break;
      const line = buffer.slice(0, index);
      buffer = buffer.slice(index + 1);
      if (!line) continue;
      const message = JSON.parse(line);
      const request = pending.get(message.id);
      if (!request) continue;
      pending.delete(message.id);
      if (message.error) request.reject(new Error(message.error.message));
      else request.resolve(message.result);
    }
  });

  const request = (method, params) => {
    const id = ++sequence;
    return new Promise((resolve, reject) => {
      pending.set(id, { resolve, reject });
      child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id, method, params })}\n`);
    });
  };

  return {
    child,
    request,
    async close() {
      child.stdin.end();
      await new Promise((resolve) => child.once("exit", resolve));
      assert.equal(child.exitCode, 0, stderr);
    }
  };
}

test("real Pi modifies and validates an isolated workspace", { skip: !enabled, timeout: 660_000 }, async () => {
  const cwd = await mkdtemp(join(tmpdir(), "pi-orchestrator-live-"));
  const client = startClient();
  try {
    await client.request("initialize", {
      protocolVersion: "2025-03-26",
      capabilities: {},
      clientInfo: { name: "pi-orchestrator-live-test", version: "1.0.0" }
    });
    const result = await client.request("tools/call", {
      name: "delegate",
      arguments: {
        cwd,
        task: "Create proof.txt with exactly pi-orchestrator-live-ok followed by one newline. Read it back and verify the exact content. Do not create other files.",
        metrics: {
          reasoning_depth: 0,
          system_span: 0,
          uncertainty: 0,
          impact_risk: 0,
          verification_complexity: 0
        }
      }
    });
    const payload = JSON.parse(result.content[0].text);
    assert.equal(result.isError, false, JSON.stringify(payload));
    assert.equal(payload.outcome, "completed", JSON.stringify(payload));
    assert.equal(payload.routing.model, "gpt-5.6-luna");
    assert.equal(payload.routing.effort, "max");
    assert.equal(await readFile(join(cwd, "proof.txt"), "utf8"), "pi-orchestrator-live-ok\n");
  } finally {
    await client.close();
    await rm(cwd, { recursive: true, force: true });
  }
});
