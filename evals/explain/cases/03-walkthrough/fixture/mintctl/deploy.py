import subprocess
import tomllib

from mintctl import registry, slack


def deploy(env_name):
    with open("mint.toml", "rb") as handle:
        config = tomllib.load(handle)
    env = config["env"][env_name]
    sha = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], text=True).strip()
    tag = f"{registry.HOST}/mint-shop:{sha}"
    subprocess.run(["docker", "build", "-t", tag, "."], check=True)
    subprocess.run(["docker", "push", tag], check=True)
    subprocess.run(
        ["kubectl", "--context", env["cluster"], "-n", env["namespace"],
         "set", "image", "deployment/mint-shop", f"web={tag}"],
        check=True,
    )
    subprocess.run(
        ["kubectl", "--context", env["cluster"], "-n", env["namespace"],
         "rollout", "status", "deployment/mint-shop", "--timeout=300s"],
        check=True,
    )
    slack.post(env["slack_channel"], f"mint-shop {sha} is live on {env_name}")
