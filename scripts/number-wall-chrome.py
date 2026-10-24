#!/usr/bin/env python3
"""Chromium launcher for the Number Walls Flutter Chrome state gate on Linux.

Use via CHROME_EXECUTABLE, not by patching Flutter. The fresh test profile uses
basic password storage so startup never waits for the desktop secret service;
no user credentials/profile are loaded. Chromium sandboxing stays enabled.
"""

import json
import os
from pathlib import Path
import sys
import tempfile
from urllib.parse import urlsplit


if __name__ == "__main__":
    args = [arg for arg in sys.argv[1:] if arg != "--no-sandbox"]
    if any(arg.startswith(("--disable-web-security", "--disable-setuid-sandbox"))
           for arg in args):
        sys.exit("Number Walls Chrome gate must retain browser security")
    if "--version" not in args:
        profile = next((arg.split("=", 1)[1] for arg in args
                        if arg.startswith("--user-data-dir=")), None)
        if profile is None or not Path(profile).resolve().is_relative_to(
                Path(tempfile.gettempdir()).resolve()):
            sys.exit("Number Walls Chrome gate requires a temporary profile")
        for arg in args:
            if arg.startswith(("http://", "https://")) and urlsplit(arg).hostname not in (
                    "localhost", "127.0.0.1", "::1"):
                sys.exit("Number Walls Chrome gate requires loopback navigation")
    args.insert(0, "--password-store=basic")
    if log_path := os.environ.get("NUMBER_WALL_CHROME_LOG"):
        with open(log_path, "a", encoding="utf-8") as log:
            log.write(json.dumps({"pid": os.getpid(), "args": args}) + "\n")
    os.execv("/usr/bin/chromium", ["/usr/bin/chromium", *args])
