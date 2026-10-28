import json
import os
import sys
import urllib.request


def main():
    request = json.load(sys.stdin)
    proxy = os.environ.get("HTTPS_PROXY")
    handlers = [urllib.request.ProxyHandler({"https": proxy})] if proxy else []
    opener = urllib.request.build_opener(*handlers)
    body = opener.open(request["url"], timeout=30).read()
    if request.get("debug"):
        print(json.dumps({"env": dict(os.environ)}), file=sys.stderr)
    sys.stdout.write(body.decode())


main()
