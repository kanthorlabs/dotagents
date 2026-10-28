import json
import os
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
SUITE = Path(os.environ["EVAL_SUITE"]).resolve()
CASES = SUITE / os.environ.get("EVAL_CASES", "cases")
CONFIG = json.loads((SUITE / "suite.json").read_text())
POOL = 6
BUDGET_USD = "1.00"
TIMEOUT_SECONDS = 900


def command(skill_path, prompt):
    return [
        "claude", "-p", "--safe-mode", "--model", CONFIG["model"], "--effort", CONFIG["effort"],
        "--no-session-persistence", "--permission-prompts", "none",
        "--tools", CONFIG["tools"], "--output-format", "json",
        "--max-budget-usd", BUDGET_USD,
        "--append-system-prompt-file", str(skill_path), prompt,
    ]


def generate(skill_path, case_dir, target):
    raw_path = target.with_suffix(".json")
    if target.exists() and raw_path.exists():
        return f"skip {target}"
    prompt = (case_dir / "prompt.md").read_text()
    workspace = Path(tempfile.mkdtemp(prefix=f"{SUITE.name}-eval-"))
    try:
        fixture = case_dir / "fixture"
        if fixture.is_dir():
            shutil.copytree(fixture, workspace, dirs_exist_ok=True)
        completed = subprocess.run(
            command(skill_path, prompt), cwd=workspace, capture_output=True, text=True,
            timeout=TIMEOUT_SECONDS, stdin=subprocess.DEVNULL,
        )
    finally:
        shutil.rmtree(workspace, ignore_errors=True)
    try:
        raw = json.loads(completed.stdout)
    except json.JSONDecodeError:
        raw = {"is_error": True, "result": "", "stdout": completed.stdout, "stderr": completed.stderr}
    raw_path.write_text(json.dumps(raw, indent=2))
    if raw.get("is_error") or not raw.get("result"):
        return f"error {target}: {raw.get('subtype')} {completed.stderr[:200]}"
    target.write_text(raw["result"])
    return f"ok {target} {raw.get('total_cost_usd', 0):.3f} USD"


def main():
    skill_path = Path(sys.argv[1]).resolve()
    out_dir = Path(sys.argv[2]).resolve()
    repeats = int(sys.argv[3])
    out_dir.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(skill_path, out_dir / "skill.md")
    meta = {
        "skill_path": os.path.relpath(skill_path, REPO),
        "skill_lines": len(skill_path.read_text().splitlines()),
        "repeats": repeats,
        "model": CONFIG["model"],
        "effort": CONFIG["effort"],
    }
    (out_dir / "run.json").write_text(json.dumps(meta, indent=2))
    jobs = []
    for case_dir in sorted(path for path in CASES.iterdir() if path.is_dir()):
        sample_dir = out_dir / "samples" / case_dir.name
        sample_dir.mkdir(parents=True, exist_ok=True)
        for repeat in range(1, repeats + 1):
            jobs.append((case_dir, sample_dir / f"r{repeat}.md"))
    with ThreadPoolExecutor(max_workers=POOL) as pool:
        for line in pool.map(lambda job: generate(skill_path, *job), jobs):
            print(line, flush=True)


if __name__ == "__main__":
    main()
