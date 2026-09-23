import assert from "node:assert/strict";
import { constants, realpathSync } from "node:fs";
import { access, stat } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, isAbsolute, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const scanner = resolve(dirname(realpathSync(new URL(import.meta.url))), "scan.sh");

export default function (pi: ExtensionAPI) {
  assert(isAbsolute(scanner));
  assert.equal(typeof pi.on, "function");

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "read") return;
    const blocked = { block: true, reason: "secret-guard: read blocked because the scan failed." };
    if (typeof event.input.path !== "string" || !event.input.path) return blocked;
    if (ctx.signal?.aborted) return blocked;
    assert(isAbsolute(ctx.cwd));

    let path = event.input.path.replace(/[\u00A0\u2000-\u200A\u202F\u205F\u3000]/g, " ").replace(/^@/, "");
    if (path === "~") path = homedir();
    else if (path.startsWith("~/")) path = resolve(homedir(), path.slice(2));
    if (path.startsWith("file://")) path = fileURLToPath(path);
    const file = resolve(ctx.cwd, path);
    assert(isAbsolute(file));
    if (!(await stat(file)).isFile()) return blocked;
    await access(file, constants.R_OK);

    const result = await pi.exec("bash", [scanner, file], {
      cwd: ctx.cwd,
      signal: ctx.signal,
      timeout: 10000
    });
    if (result.killed || ctx.signal?.aborted || result.stderr.trim()) return blocked;
    if (result.code === 0 && !result.stdout.trim()) return;
    if (result.code !== 1 || !result.stdout.trim()) return blocked;

    return {
      block: true,
      reason: `secret-guard: read blocked because ${file} contains possible sensitive data:\n${result.stdout.trim()}`
    };
  });
}
