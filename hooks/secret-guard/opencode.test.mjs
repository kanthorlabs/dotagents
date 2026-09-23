import assert from "node:assert/strict"
import { execFileSync } from "node:child_process"
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { resolve } from "node:path"
import { test } from "node:test"
import plugin from "./opencode.js"

const root = resolve(import.meta.dirname, "../..")

test("OpenCode denies sensitive reads without exposing values", async () => {
  const directory = mkdtempSync(resolve(tmpdir(), "secret-guard-"))
  try {
    writeFileSync(resolve(directory, "sensitive"), "key=AKIAIOSFODNN7EXAMPLE\n")
    writeFileSync(resolve(directory, "clean"), "hello\n")
    let evaluate
    await plugin.setup({
      location: { directory },
      permission: { hook: async (name, callback) => {
        assert.equal(name, "evaluate")
        evaluate = callback
      } },
    })
    assert.equal(typeof evaluate, "function")

    const sensitive = { action: "read", resources: ["sensitive"], effect: "allow" }
    await evaluate(sensitive)
    assert.equal(sensitive.effect, "deny")
    assert.match(sensitive.message, /AWS access key ID \(lines 1\)/)
    assert.doesNotMatch(sensitive.message, /AKIAIOSFODNN7EXAMPLE/)

    const clean = { action: "read", resources: [resolve(directory, "clean")], effect: "allow" }
    await evaluate(clean)
    assert.equal(clean.effect, "allow")

    const unrelated = { action: "edit", resources: ["sensitive"], effect: "allow" }
    await evaluate(unrelated)
    assert.equal(unrelated.effect, "allow")
  } finally {
    rmSync(directory, { recursive: true, force: true })
  }
})

test("installer preserves existing plugins across repeated installs", () => {
  const directory = mkdtempSync(resolve(tmpdir(), "secret-guard-install-"))
  try {
    const config = resolve(directory, "opencode.jsonc")
    writeFileSync(config, JSON.stringify({ plugins: ["other-plugin"], permissions: [] }))
    const env = { ...process.env, ROOT: root, OPENCODE_DIR: directory }
    execFileSync(resolve(root, "scripts/install-opencode-json.sh"), { env })
    execFileSync(resolve(root, "scripts/install-opencode-json.sh"), { env })
    const installed = JSON.parse(readFileSync(config, "utf8"))
    assert.deepEqual(installed.plugins, ["other-plugin", `${root}/hooks/secret-guard/opencode.js`])
    assert.equal(installed.permissions.length, 1)
  } finally {
    rmSync(directory, { recursive: true, force: true })
  }
})
