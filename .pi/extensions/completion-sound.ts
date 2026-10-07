import { realpathSync } from "node:fs";
import { dirname, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const audioDirectory = resolve(dirname(realpathSync(new URL(import.meta.url))), "../../assets/audio");

function player(file: string): [string, string[]] | undefined {
  if (process.platform === "darwin") return ["afplay", [file]];
  if (process.platform === "linux") return ["mpg123", ["-q", file]];
  return undefined;
}

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
    if (!completedSound) return;
    const command = player(resolve(audioDirectory, `${completedSound}.mp3`));
    if (!command) return;

    try {
      const [program, args] = command;
      const result = await pi.exec(program, args, { timeout: 10000 });
      if (result.code !== 0) {
        throw new Error(result.stderr.trim() || `${program} exited with code ${result.code}`);
      }
    } catch (error) {
      if (ctx.hasUI) ctx.ui.notify(`Completion sound failed: ${String(error)}`, "warning");
    }
  });
}
