#!/usr/bin/env python3
"""Verify the restored Julia canvas in an Android uiautomator capture."""

import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def has_julia_canvas(capture: str) -> bool:
    # uiautomator can append a status line after the hierarchy XML.
    start = capture.find("<hierarchy")
    end = capture.find("</hierarchy>", start)
    if start < 0 or end < 0:
        return False
    try:
        root = ET.fromstring(capture[start : end + len("</hierarchy>")])
    except ET.ParseError:
        return False
    return any(
        node.get("content-desc", "").splitlines()
        == ["Interactive fractal canvas", "Julia"]
        for node in root.iter("node")
    )


if __name__ == "__main__":
    sys.exit(0 if has_julia_canvas(Path(sys.argv[1]).read_text()) else 1)
