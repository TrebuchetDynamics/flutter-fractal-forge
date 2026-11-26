#!/usr/bin/env python3
"""Materialize only the canonical surface block, without local GLSL includes."""

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BEGIN = rb"^// BEGIN GENERATED SURFACE LIGHTING(\r?\n)"
END = rb"^// END GENERATED SURFACE LIGHTING\r?\n"
CONSUMERS = [
    Path("shaders/legacy/raymarched_3d/mandelbulb.frag"),
    Path("shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag"),
    Path("test/shaders/sculptural_surface_fixture.frag"),
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="check without writing")
    mode.add_argument("--write", action="store_true", help="update generated blocks")
    args = parser.parse_args()
    canonical = (ROOT / "shaders/shared/surface_lighting.glsl").read_bytes()
    canonical = canonical.replace(b"\r\n", b"\n")
    stale = []
    for path in CONSUMERS:
        asset = ROOT / path
        source = asset.read_bytes()
        begins = list(re.finditer(BEGIN, source, re.MULTILINE))
        ends = list(re.finditer(END, source, re.MULTILINE))
        if len(begins) != 1 or len(ends) != 1 or begins[0].end() > ends[0].start():
            parser.exit(1, f"Expected exactly one ordered surface block in {path}\n")
        begin, end = begins[0], ends[0]
        # Match the marker's newline without rewriting the host shader.
        block = canonical.replace(b"\n", begin[1])
        if source[begin.end():end.start()] != block:
            stale.append(str(path))
            if args.write:
                asset.write_bytes(source[:begin.end()] + block + source[end.start():])
    if args.check and stale:
        parser.exit(1, "Stale surface blocks: " + ", ".join(stale)
                    + "; run python3 scripts/sync_surface_lighting.py --write\n")
    print("Surface lighting assets are synchronized.")


if __name__ == "__main__":
    main()
