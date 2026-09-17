import { realpathSync } from "node:fs";
import { dirname, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const audioDirectory = resolve(dirname(realpathSync(new URL(import.meta.url))), "../../assets/audio");

export default function (pi: ExtensionAPI) {
  let sound: "success" | "failure" | undefined;

  pi.on("agent_start", () => {
    sound = undefined;
  });

  pi.on("agent_end", (event, ctx) => {
    const message = event.messages.findLast((message) => message.role === "assistant");
    sound = undefined;
    if (!message || message.stopReason === "aborted" || ctx.signal?.aborted) return;
    if (message.stopReason === "pending") return;
    sound = message.stopReason === "error" ? "failure" : "success";
  });

  pi.on("agent_settled", async (_event, ctx) => {
    if (!ctx.isIdle()) return;
    const completedSound = sound;
    sound = undefined;
    if (!completedSound || process.platform !== "darwin") return;

    try {
      const result = await pi.exec("afplay", [resolve(audioDirectory, `${completedSound}.mp3`)], { timeout: 10000 });
      if (result.code !== 0) {
        throw new Error(result.stderr.trim() || `afplay exited with code ${result.code}`);
      }
    } catch (error) {
      if (ctx.hasUI) ctx.ui.notify(`Completion sound failed: ${String(error)}`, "warning");
    }
  });
}
