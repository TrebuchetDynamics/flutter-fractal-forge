#!/usr/bin/env python3
"""Temporarily replace pubspec.yaml's flutter.shaders list."""

from __future__ import annotations

import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: patch_pubspec_shaders.py <pubspec.yaml> <shader> [<shader> ...]", file=sys.stderr)
        return 2

    pubspec = Path(sys.argv[1])
    shaders = list(dict.fromkeys(sys.argv[2:]))
    lines = pubspec.read_text().splitlines()

    start = next((i for i, line in enumerate(lines) if line == "  shaders:"), None)
    if start is None:
        raise SystemExit("pubspec has no '  shaders:' block")

    end = start + 1
    while end < len(lines) and lines[end].startswith("    - "):
        end += 1

    replacement = ["  shaders:"] + [f"    - {shader}" for shader in shaders]
    pubspec.write_text("\n".join(lines[:start] + replacement + lines[end:]) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
