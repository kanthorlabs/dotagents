import { execFile } from "node:child_process"
import { fileURLToPath } from "node:url"
import { dirname, isAbsolute, resolve } from "node:path"

const scanner = resolve(dirname(fileURLToPath(import.meta.url)), "scan.sh")

function scan(path) {
  return new Promise((accept, reject) => {
    execFile(scanner, [path], (error, stdout) => {
      if (!error) return accept("")
      if (error.code === 1 && stdout.trim()) return accept(stdout.trim().split("\n").join("; "))
      reject(new Error(`secret-guard scan failed for ${path}: ${error.message}`))
    })
  })
}

export default {
  id: "secret-guard",
  async setup(ctx) {
    await ctx.permission.hook("evaluate", async (event) => {
      if (event.action !== "read") return
      for (const resource of event.resources) {
        const path = isAbsolute(resource) ? resource : resolve(ctx.location.directory, resource)
        const findings = await scan(path)
        if (!findings) continue
        event.effect = "deny"
        event.message = `secret-guard: ${path} contains possible sensitive data: ${findings}. Read blocked.`
        return
      }
    })
  },
}
