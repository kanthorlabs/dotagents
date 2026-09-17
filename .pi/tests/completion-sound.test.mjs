import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { access, copyFile, mkdir, mkdtemp, readlink, realpath, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import test, { after, before } from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";
import completionSound from "../extensions/completion-sound.ts";

const root = fileURLToPath(new URL("../../", import.meta.url));
const originalPlatform = Object.getOwnPropertyDescriptor(process, "platform");
before(() => Object.defineProperty(process, "platform", { value: "darwin" }));
after(() => Object.defineProperty(process, "platform", originalPlatform));

function harness(factory = completionSound) {
  const handlers = new Map();
  const calls = [];
  const notifications = [];
  const context = {
    hasUI: true,
    isIdle: () => true,
    ui: { notify: (...args) => notifications.push(args) }
  };
  const pi = {
    on: (name, handler) => handlers.set(name, handler),
    exec: async (...args) => {
      calls.push(args);
      return { code: 0, stdout: "", stderr: "", killed: false };
    }
  };
  factory(pi);
  return {
    calls,
    notifications,
    context,
    pi,
    emit: async (type, event = {}) => handlers.get(type)?.({ type, ...event }, context)
  };
}

function assistant(stopReason) {
  return { role: "assistant", stopReason };
}

function expectedCall(sound, directory = root) {
  return ["afplay", [resolve(directory, `assets/audio/${sound}.mp3`)], { timeout: 10000 }];
}

test("plays success once after the full run settles", async () => {
  const h = harness();
  await h.emit("agent_start");
  await h.emit("agent_end", { messages: [assistant("stop")] });
  assert.deepEqual(h.calls, []);
  await h.emit("agent_settled");
  await h.emit("agent_settled");
  assert.deepEqual(h.calls, [expectedCall("success")]);
  await access(h.calls[0][1][0]);
});

test("plays failure for a final agent error", async () => {
  const h = harness();
  await h.emit("agent_end", { messages: [assistant("stop"), assistant("error")] });
  await h.emit("agent_settled");
  assert.deepEqual(h.calls, [expectedCall("failure")]);
  await access(h.calls[0][1][0]);
});

test("plays only success after an automatic retry succeeds", async () => {
  const h = harness();
  await h.emit("agent_end", { messages: [assistant("error")] });
  await h.emit("agent_start");
  await h.emit("agent_end", { messages: [assistant("stop")] });
  assert.deepEqual(h.calls, []);
  await h.emit("agent_settled");
  assert.deepEqual(h.calls, [expectedCall("success")]);
});

test("uses the final queued run outcome", async () => {
  const h = harness();
  await h.emit("agent_end", { messages: [assistant("stop")] });
  await h.emit("agent_start");
  await h.emit("agent_end", { messages: [assistant("error")] });
  assert.deepEqual(h.calls, []);
  await h.emit("agent_settled");
  assert.deepEqual(h.calls, [expectedCall("failure")]);
});

test("ignores tool errors that the agent resolves", async () => {
  const h = harness();
  await h.emit("agent_end", {
    messages: [assistant("toolUse"), { role: "toolResult", isError: true }, assistant("stop")]
  });
  await h.emit("agent_settled");
  assert.deepEqual(h.calls, [expectedCall("success")]);
});

test("accepts normal length limits and terminal tool calls", async () => {
  for (const stopReason of ["length", "toolUse"]) {
    const h = harness();
    await h.emit("agent_end", { messages: [assistant(stopReason), { role: "toolResult", isError: false }] });
    await h.emit("agent_settled");
    assert.deepEqual(h.calls, [expectedCall("success")]);
  }
});

test("stays silent for aborted, absent, or partial assistant responses", async () => {
  const h = harness();
  await h.emit("agent_settled");
  for (const messages of [[assistant("aborted")], [], [{ role: "user" }], [assistant("pending")]]) {
    await h.emit("agent_end", { messages: [assistant("error")] });
    await h.emit("agent_end", { messages });
    await h.emit("agent_settled");
  }
  assert.deepEqual(h.calls, []);
});

test("stays silent after cancellation during a tool call", async () => {
  const h = harness();
  h.context.signal = AbortSignal.abort();
  await h.emit("agent_end", { messages: [assistant("toolUse"), { role: "toolResult", isError: true }] });
  await h.emit("agent_settled");
  assert.deepEqual(h.calls, []);
});

test("clears the previous outcome when a new run starts", async () => {
  const h = harness();
  await h.emit("agent_end", { messages: [assistant("error")] });
  await h.emit("agent_start");
  await h.emit("agent_settled");
  assert.deepEqual(h.calls, []);
});

test("does not notify while another extension starts more work", async () => {
  const h = harness();
  await h.emit("agent_end", { messages: [assistant("stop")] });
  h.context.isIdle = () => false;
  await h.emit("agent_settled");
  assert.deepEqual(h.calls, []);
});

test("skips audio outside macOS", async (t) => {
  Object.defineProperty(process, "platform", { value: "linux" });
  t.after(() => Object.defineProperty(process, "platform", { value: "darwin" }));
  const h = harness();
  await h.emit("agent_end", { messages: [assistant("stop")] });
  await h.emit("agent_settled");
  assert.deepEqual(h.calls, []);
});

test("reports audio errors without interrupting the agent", async () => {
  for (const exec of [
    async () => ({ code: 1, stderr: "Audio device unavailable" }),
    async () => { throw new Error("afplay unavailable"); }
  ]) {
    const h = harness();
    h.pi.exec = exec;
    await h.emit("agent_end", { messages: [assistant("stop")] });
    await h.emit("agent_settled");
    assert.equal(h.notifications.length, 1);
    assert.match(h.notifications[0][0], /^Completion sound failed:/);
    assert.equal(h.notifications[0][1], "warning");
  }
});

test("keeps print and JSON output free of audio diagnostics", async () => {
  const h = harness();
  h.context.hasUI = false;
  h.pi.exec = async () => { throw new Error("afplay unavailable"); };
  await h.emit("agent_end", { messages: [assistant("error")] });
  await h.emit("agent_settled");
  assert.deepEqual(h.notifications, []);
});

test("installs idempotently and resolves audio through a global symlink with spaces", async (t) => {
  const directory = await realpath(await mkdtemp(join(tmpdir(), "pi sound test ")));
  t.after(() => rm(directory, { recursive: true, force: true }));
  const checkout = join(directory, "dotagents checkout");
  const agentDirectory = join(directory, "pi agent");
  const source = join(checkout, ".pi/extensions/completion-sound.ts");
  const installed = join(agentDirectory, "extensions/completion-sound.ts");
  await mkdir(join(checkout, ".pi/extensions"), { recursive: true });
  await copyFile(join(root, ".pi/extensions/completion-sound.ts"), source);
  for (let attempt = 0; attempt < 2; attempt++) {
    execFileSync("make", ["-f", join(root, "Makefile"), `PI_DIR=${agentDirectory}`, "install-pi-extensions"], {
      cwd: checkout,
      stdio: "pipe"
    });
    assert.equal(await readlink(installed), source);
  }
  const { default: installedExtension } = await import(pathToFileURL(installed).href);
  const h = harness(installedExtension);
  await h.emit("agent_end", { messages: [assistant("stop")] });
  await h.emit("agent_settled");
  assert.deepEqual(h.calls, [expectedCall("success", checkout)]);
});
