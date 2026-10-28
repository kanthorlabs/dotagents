import json
import subprocess

TIMEOUT_SECONDS = 600


def structured_call(prompt, schema_text, budget_usd):
    completed = subprocess.run(
        [
            "claude", "-p", "--safe-mode", "--model", "sonnet", "--effort", "medium",
            "--no-session-persistence", "--tools", "", "--output-format", "json",
            "--max-budget-usd", budget_usd, "--json-schema", schema_text,
        ],
        input=prompt, capture_output=True, text=True, timeout=TIMEOUT_SECONDS,
    )
    try:
        return json.loads(completed.stdout)
    except json.JSONDecodeError:
        return {"is_error": True, "stderr": completed.stderr[:500]}
