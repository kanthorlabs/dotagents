import os
import subprocess
import sys
from pathlib import Path


def main():
    font_cache = Path(os.environ["HOME"]) / ".cache" / "pdf-stamp"
    font_cache.mkdir(parents=True, exist_ok=True)
    subprocess.run(["qpdf", "--overlay", "stamp.pdf", "--", "-", "-"], stdin=sys.stdin, check=True)


main()
