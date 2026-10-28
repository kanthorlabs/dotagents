import json
import os
import urllib.request


def post(channel, text):
    body = json.dumps({"channel": channel, "text": text}).encode()
    request = urllib.request.Request(
        os.environ["MINT_SLACK_WEBHOOK"], data=body, headers={"Content-Type": "application/json"}
    )
    urllib.request.urlopen(request, timeout=10)
