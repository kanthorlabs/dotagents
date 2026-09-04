import { writeFile } from "node:fs/promises";
import { join } from "node:path";
import { StringDecoder } from "node:string_decoder";

const decoder = new StringDecoder("utf8");
const modelIndex = process.argv.lastIndexOf("--model");
const thinkingIndex = process.argv.lastIndexOf("--thinking");
const modelSelector = modelIndex === -1 ? "fake/fake-pi" : process.argv[modelIndex + 1];
const reportedModelSelector = process.env.FAKE_PI_REPORTED_MODEL || modelSelector;
const reportedModelSeparator = reportedModelSelector.indexOf("/");
const selectedProvider = reportedModelSeparator === -1 ? "fake" : reportedModelSelector.slice(0, reportedModelSeparator);
const selectedModel = reportedModelSeparator === -1 ? reportedModelSelector : reportedModelSelector.slice(reportedModelSeparator + 1);
const selectedThinking = process.env.FAKE_PI_REPORTED_THINKING || (thinkingIndex === -1 ? "off" : process.argv[thinkingIndex + 1]);
let buffer = "";
let active = false;
let activeTimer;
let pendingDialog = false;
let firstStateRead = true;
let promptCount = 0;
let lastText = null;
const messages = [];
const sessionId = `fake-${process.pid}`;
const sessionFile = join(process.cwd(), ".fake-pi-session.jsonl");

function send(value) {
  process.stdout.write(`${JSON.stringify(value)}\n`);
}

function respond(command, data) {
  send({
    id: command.id,
    type: "response",
    command: command.type,
    success: true,
    ...(data === undefined ? {} : { data })
  });
}

function assistantMessage(text, stopReason = "stop") {
  return {
    role: "assistant",
    content: [{ type: "text", text }],
    stopReason,
    timestamp: Date.now()
  };
}

async function finishPrompt(message, stopReason = "stop") {
  const assistant = assistantMessage(message, stopReason);
  lastText = message;
  messages.push(assistant);
  send({ type: "message_end", message: assistant });
  send({ type: "agent_end", messages: [assistant], willRetry: false });
  await new Promise((resolve) => setTimeout(resolve, 35));
  active = false;
  send({ type: "agent_settled" });
}

async function handlePrompt(command) {
  promptCount += 1;
  active = true;
  messages.push({ role: "user", content: command.message, timestamp: Date.now() });
  await writeFile(
    join(process.cwd(), "fake-pi-proof.json"),
    JSON.stringify({
      pid: process.pid,
      promptCount,
      message: command.message,
      model: modelSelector,
      effort: selectedThinking
    }, null, 2)
  );
  respond(command);
  send({ type: "agent_start" });
  send({ type: "turn_start", turnIndex: promptCount - 1, timestamp: Date.now() });
  const toolCallId = `fake-tool-${promptCount}`;
  send({ type: "tool_execution_start", toolCallId, toolName: "write", args: { path: "fake-pi-proof.json" } });
  send({
    type: "tool_execution_end",
    toolCallId,
    toolName: "write",
    result: { content: [{ type: "text", text: "proof written" }], details: {} },
    isError: false
  });

  if (command.message.includes("__crash__")) {
    setTimeout(() => process.exit(7), 10);
    return;
  }
  if (command.message.includes("__hang__")) return;
  if (command.message.includes("__dialog__")) {
    pendingDialog = true;
    send({
      type: "extension_ui_request",
      id: `fake-dialog-${promptCount}`,
      method: "input",
      title: "Missing input",
      placeholder: "required value"
    });
    return;
  }

  activeTimer = setTimeout(() => {
    const status = command.message.includes("__blocked__") ? "blocked" : "completed";
    const separators = `${String.fromCodePoint(0x2028)} and ${String.fromCodePoint(0x2029)}`;
    const text = `Fake Pi run ${promptCount} preserved Unicode ${separators}.\nSTATUS: ${status}\nSUMMARY\nFake task complete.\nCHANGES\nfake-pi-proof.json\nVALIDATION\npassed\nQUESTIONS\nnone`;
    finishPrompt(text).catch((error) => {
      process.stderr.write(`${error.message}\n`);
      process.exitCode = 1;
    });
  }, 25);
}

async function handle(command) {
  if (command.type === "get_state") {
    if (firstStateRead) {
      firstStateRead = false;
      const delay = Number(process.env.FAKE_PI_START_DELAY_MS || 0);
      if (delay > 0) await new Promise((resolve) => setTimeout(resolve, delay));
    }
    respond(command, {
      model: { provider: selectedProvider, id: selectedModel },
      thinkingLevel: selectedThinking,
      isStreaming: active,
      sessionFile,
      sessionId,
      messageCount: messages.length,
      pendingMessageCount: 0
    });
    return;
  }
  if (command.type === "prompt") {
    await handlePrompt(command);
    return;
  }
  if (command.type === "get_last_assistant_text") {
    respond(command, { text: lastText });
    return;
  }
  if (command.type === "get_messages") {
    respond(command, { messages });
    return;
  }
  if (command.type === "abort") {
    respond(command);
    if (active) {
      clearTimeout(activeTimer);
      await finishPrompt("STATUS: failed\nSUMMARY\nAborted by orchestrator.\nCHANGES\nnone\nVALIDATION\nnot run\nQUESTIONS\nnone", "aborted");
    }
    return;
  }
  if (command.type === "extension_ui_response") {
    if (pendingDialog) {
      pendingDialog = false;
      await finishPrompt("STATUS: blocked\nSUMMARY\nInput is required.\nCHANGES\nnone\nVALIDATION\nnot run\nQUESTIONS\nProvide the required value.");
    }
    return;
  }
  send({
    id: command.id,
    type: "response",
    command: command.type,
    success: false,
    error: `Unsupported fake command: ${command.type}`
  });
}

function consume(line) {
  if (line.endsWith("\r")) line = line.slice(0, -1);
  if (!line) return;
  let command;
  try {
    command = JSON.parse(line);
  } catch (error) {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
    return;
  }
  handle(command).catch((error) => {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  });
}

process.stdin.on("data", (chunk) => {
  buffer += decoder.write(chunk);
  while (true) {
    const index = buffer.indexOf("\n");
    if (index === -1) break;
    consume(buffer.slice(0, index));
    buffer = buffer.slice(index + 1);
  }
});
process.stdin.on("end", () => {
  buffer += decoder.end();
  if (buffer) consume(buffer);
});
process.on("SIGTERM", () => process.exit(0));
