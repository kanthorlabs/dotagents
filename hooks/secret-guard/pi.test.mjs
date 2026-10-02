import assert from "node:assert/strict"
import { spawnSync } from "node:child_process"
import { mkdtempSync, realpathSync, rmSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { resolve } from "node:path"
import { test } from "node:test"
import extension from "../../.pi/extensions/secret-guard.ts"

test("Pi uses the linked scanner and exempts fixture values individually", async () => {
  const directory = mkdtempSync(resolve(tmpdir(), "secret-guard-pi-"))
  try {
    let evaluate
    extension({
      on(name, callback) {
        assert.equal(name, "tool_call")
        assert.equal(typeof callback, "function")
        evaluate = callback
      },
      async exec(command, args, options) {
        assert.equal(command, "bash")
        assert.equal(realpathSync(args[0]), resolve(import.meta.dirname, "scan.sh"))
        const result = spawnSync(command, args, { cwd: options.cwd, timeout: options.timeout, encoding: "utf8" })
        assert.equal(result.error, undefined)
        return { code: result.status, stdout: result.stdout, stderr: result.stderr, killed: result.signal !== null }
      },
    })
    assert.equal(typeof evaluate, "function")
    const file = resolve(directory, "fixture.ts")
    for (const prefix of ["debug_", "test_"]) {
      writeFileSync(file, `const SECRET = "${prefix}fixture-value";\n`)
      assert.equal(await evaluate({ toolName: "read", input: { path: file } }, { cwd: directory }), undefined)
    }
    writeFileSync(file, 'const SECRET = "test_fixture-value"; const password = "ordinary-value";\n')
    const blocked = await evaluate({ toolName: "read", input: { path: file } }, { cwd: directory })
    assert.equal(blocked.block, true)
    assert.match(blocked.reason, /Password or secret literal \(lines 1\)/)
    assert.doesNotMatch(blocked.reason, /ordinary-value/)
  } finally {
    rmSync(directory, { recursive: true, force: true })
  }
})
