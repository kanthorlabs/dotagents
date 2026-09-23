import assert from "node:assert/strict";
import { execFileSync, spawnSync } from "node:child_process";
import { copyFile, mkdir, mkdtemp, readlink, realpath, rm, symlink, writeFile } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { join, relative, resolve } from "node:path";
import test, { after, before } from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";
import secretGuard from "../extensions/secret-guard.ts";

const root = fileURLToPath(new URL("../../", import.meta.url));
const secret = "AKIA" + "IOSFODNN7EXAMPLE";
let directory;
before(async () => {
  directory = await realpath(await mkdtemp(join(tmpdir(), "pi secret guard ")));
  await writeFile(join(directory, "safe"), "hello\n");
  await writeFile(join(directory, "sensitive file"), `hello\nkey=${secret}\n`);
  await symlink(join(directory, "sensitive file"), join(directory, "link"));
});
after(() => rm(directory, { recursive: true, force: true }));

function harness(factory = secretGuard) {
  assert.equal(typeof factory, "function");
  const handlers = new Map();
  const calls = [];
  const prompts = [];
  const context = {
    cwd: directory,
    hasUI: true,
    signal: new AbortController().signal,
    ui: { confirm: async (...args) => { prompts.push(args); return false; } }
  };
  const pi = {
    on: (name, handler) => handlers.set(name, handler),
    exec: async (command, args, options) => {
      calls.push([command, args, options]);
      const result = spawnSync(command, args, { cwd: options.cwd, timeout: options.timeout, encoding: "utf8" });
      assert.ifError(result.error);
      assert.equal(result.signal, null);
      return { code: result.status, stdout: result.stdout, stderr: result.stderr, killed: false };
    }
  };
  factory(pi);
  assert.equal(typeof handlers.get("tool_call"), "function");
  return {
    calls, prompts, context, pi,
    emit: (path = "safe", input = {}, toolName = "read") => handlers.get("tool_call")({
      type: "tool_call", toolName, toolCallId: "test-read", input: { path, ...input }
    }, context)
  };
}

test("allows clean reads without a prompt and bounds the scan", async () => {
  const h = harness();
  assert.equal(await h.emit(), undefined);
  assert.deepEqual(h.prompts, []);
  assert.deepEqual(h.calls, [["bash", [join(root, "hooks/secret-guard/scan.sh"), join(directory, "safe")], {
    cwd: directory, signal: h.context.signal, timeout: 10000
  }]]);
});

test("blocks sensitive reads in every mode without approval or secret values", async () => {
  for (const mode of ["tui", "rpc", "json", "print"]) {
    const h = harness();
    h.context.mode = mode;
    h.context.hasUI = mode === "tui" || mode === "rpc";
    const result = await h.emit("sensitive file");
    assert.equal(result.block, true);
    assert.match(result.reason, /AWS access key ID \(lines 2\)/);
    assert.equal(result.reason.includes(secret), false);
    assert.equal(await h.emit(), undefined);
    assert.deepEqual(h.prompts, []);
  }
});

test("blocks repeated sensitive reads without an approval bypass", async () => {
  const h = harness();
  h.context.ui.confirm = async () => { throw new Error("approval is forbidden"); };
  assert.equal((await h.emit("sensitive file")).block, true);
  assert.equal((await h.emit("sensitive file")).block, true);
  assert.equal(h.calls.length, 2);
});

test("scans the full file even when the requested lines exclude a secret", async () => {
  const h = harness();
  const result = await h.emit("sensitive file", { offset: 1, limit: 1 });
  assert.equal(result.block, true);
  assert.match(result.reason, /lines 2/);
});

test("resolves relative, absolute, home, at-prefixed, URL, Unicode-space, and symlink paths", async () => {
  const file = join(directory, "sensitive file");
  const paths = [
    file,
    `~/` + relative(homedir(), file),
    "@sensitive file",
    "@" + file,
    "@~/" + relative(homedir(), file),
    pathToFileURL(file).href,
    "sensitive\u00a0file",
    "link"
  ];
  for (const path of paths) {
    const h = harness();
    const result = await h.emit(path);
    assert.equal(result.block, true, path);
    assert.match(result.reason, /AWS access key ID/, path);
  }
});

test("does not intercept other tools", async () => {
  const h = harness();
  for (const name of ["bash", "grep", "write", "edit", "find", "ls"]) {
    assert.equal(await h.emit("sensitive file", {}, name), undefined);
  }
  assert.deepEqual(h.calls, []);
  assert.deepEqual(h.prompts, []);
});

test("blocks invalid paths and non-files before the scanner runs", async () => {
  const h = harness();
  for (const path of ["", null, 42, directory]) {
    assert.equal((await h.emit(path)).block, true);
  }
  await assert.rejects(h.emit("missing"), { code: "ENOENT" });
  assert.deepEqual(h.calls, []);
  assert.deepEqual(h.prompts, []);
});

test("blocks scanner errors, timeouts, and malformed results without approval", async () => {
  const results = [
    { code: 2 },
    { code: 127 },
    { code: 1 },
    { code: 0, stdout: "unexpected output" },
    { code: 0, stderr: "scanner error" },
    { code: 0, killed: true },
    { code: 1, stdout: "AWS access key ID (lines 2)", killed: true }
  ];
  for (const result of results) {
    const h = harness();
    h.pi.exec = async () => ({ code: 0, stdout: "", stderr: "", killed: false, ...result });
    assert.equal((await h.emit()).block, true);
    assert.deepEqual(h.prompts, []);
  }
});

test("propagates scanner launch failures so Pi blocks the tool", async () => {
  const h = harness();
  h.pi.exec = async () => { throw new Error("scanner unavailable"); };
  await assert.rejects(h.emit(), /scanner unavailable/);
  assert.deepEqual(h.prompts, []);
});

test("blocks cancellation before and during the scan", async () => {
  const h = harness();
  h.context.signal = AbortSignal.abort();
  assert.equal((await h.emit()).block, true);
  assert.deepEqual(h.calls, []);
  const controller = new AbortController();
  h.context.signal = controller.signal;
  h.pi.exec = async () => {
    controller.abort();
    return { code: 0, stdout: "", stderr: "", killed: false };
  };
  assert.equal((await h.emit()).block, true);
  assert.deepEqual(h.prompts, []);
});

test("installs both extensions repeatedly and resolves the scanner from a relocated checkout", async () => {
  const checkout = join(directory, "dotagents checkout");
  const agentDirectory = join(directory, "pi agent");
  const source = join(checkout, ".pi/extensions/secret-guard.ts");
  const installed = join(agentDirectory, "extensions/secret-guard.ts");
  assert.equal(await readlink(join(root, ".pi/extensions/secret-guard.ts")), "../../hooks/secret-guard/pi.ts");
  await mkdir(join(checkout, "hooks/secret-guard"), { recursive: true });
  await mkdir(join(checkout, ".pi/extensions"), { recursive: true });
  await symlink("../../hooks/secret-guard/pi.ts", source);
  await copyFile(join(root, "hooks/secret-guard/pi.ts"), join(checkout, "hooks/secret-guard/pi.ts"));
  await copyFile(join(root, "hooks/secret-guard/scan.sh"), join(checkout, "hooks/secret-guard/scan.sh"));
  await copyFile(join(root, ".pi/extensions/completion-sound.ts"), join(checkout, ".pi/extensions/completion-sound.ts"));
  for (let attempt = 0; attempt < 2; attempt++) {
    execFileSync("make", ["-f", join(root, "Makefile"), `PI_DIR=${agentDirectory}`, "install-pi-extensions"], {
      cwd: checkout, stdio: "pipe"
    });
    assert.equal(await readlink(installed), source);
    assert.equal(await readlink(join(agentDirectory, "extensions/completion-sound.ts")), join(checkout, ".pi/extensions/completion-sound.ts"));
  }
  const { default: installedGuard } = await import(pathToFileURL(installed).href);
  const h = harness(installedGuard);
  assert.equal((await h.emit("sensitive file")).block, true);
  assert.equal(h.calls[0][1][0], join(checkout, "hooks/secret-guard/scan.sh"));
  assert.equal(JSON.stringify(h.prompts).includes(secret), false);
  await rm(join(checkout, "hooks/secret-guard/scan.sh"));
  assert.equal((await h.emit()).block, true);
  assert.deepEqual(h.prompts, []);
});

test("installer tests ignore inherited make overrides", async () => {
  const inherited = join(directory, "inherited agent");
  const override = `PI_DIR=${inherited.replaceAll(" ", "\\ ")}`;
  const env = { ...process.env, PI_DIR: inherited, MAKEFLAGS: ` -- ${override}`, MAKEOVERRIDES: override };
  delete env.NODE_TEST_CONTEXT;
  const result = spawnSync(process.execPath, [
    "--test", "--test-reporter=tap",
    "--test-name-pattern=^installer uses the home directory",
    fileURLToPath(import.meta.url)
  ], {
    cwd: root,
    env,
    encoding: "utf8",
    timeout: 30000
  });
  assert.ifError(result.error);
  assert.equal(result.status, 0, `${result.stdout}\n${result.stderr}`);
  assert.match(result.stdout, /^ok \d+ - installer uses the home directory/m);
  assert.match(result.stdout, /^# pass 1$/m);
  await assert.rejects(readlink(join(inherited, "extensions/secret-guard.ts")), { code: "ENOENT" });
});

test("installer uses the home directory or PI_CODING_AGENT_DIR and permits PI_DIR overrides", async () => {
  const home = join(directory, "home");
  const custom = join(directory, "custom agent");
  const override = join(directory, "override agent");
  const env = { ...process.env, HOME: home };
  delete env.PI_DIR;
  delete env.MAKEFLAGS;
  delete env.MAKEOVERRIDES;
  delete env.MFLAGS;
  delete env.GNUMAKEFLAGS;
  const cases = [
    { configured: "", args: [], target: join(home, ".pi/agent") },
    { configured: custom, args: [], target: custom },
    { configured: custom, args: [`PI_DIR=${override}`], target: override }
  ];
  for (const { configured, args, target } of cases) {
    execFileSync("make", [...args, "install-pi-extensions"], {
      cwd: root,
      env: { ...env, PI_CODING_AGENT_DIR: configured },
      stdio: "pipe"
    });
    assert.equal(await readlink(join(target, "extensions/secret-guard.ts")), resolve(root, ".pi/extensions/secret-guard.ts"));
    assert.equal(await readlink(join(target, "extensions/completion-sound.ts")), resolve(root, ".pi/extensions/completion-sound.ts"));
  }
});
