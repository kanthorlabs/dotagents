import os
import subprocess
import sys
from pathlib import Path

PLUGIN_DIR = Path("/srv/tinkerbox/plugins")
DENYLIST = {"AWS_SECRET_ACCESS_KEY", "DATABASE_URL", "GITHUB_TOKEN"}


def plugin_env(plugin_name):
    env = dict(os.environ)
    for name in DENYLIST:
        env.pop(name, None)
    env["TINKERBOX_PLUGIN_DIR"] = str(PLUGIN_DIR / plugin_name)
    return env


def run_plugin(plugin_name, payload):
    return subprocess.run(
        [sys.executable, str(PLUGIN_DIR / plugin_name / "main.py")],
        input=payload,
        env=plugin_env(plugin_name),
        capture_output=True,
        timeout=120,
    )
