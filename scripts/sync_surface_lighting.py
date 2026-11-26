#!/usr/bin/env python3
"""Materialize only the canonical surface block, without local GLSL includes."""

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BEGIN = "// BEGIN GENERATED SURFACE LIGHTING\n"
END = "// END GENERATED SURFACE LIGHTING\n"
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
    block = BEGIN + (ROOT / "shaders/shared/surface_lighting.glsl").read_text() + END
    stale = []
    for path in CONSUMERS:
        asset = ROOT / path
        source = asset.read_text()
        if source.count(BEGIN) != 1 or source.count(END) != 1:
            parser.exit(1, f"Expected exactly one surface block in {path}\n")
        start = source.index(BEGIN)
        end = source.index(END, start) + len(END)
        updated = source[:start] + block + source[end:]
        if source != updated:
            stale.append(str(path))
            if args.write:
                asset.write_text(updated)
    if args.check and stale:
        parser.exit(1, "Stale surface blocks: " + ", ".join(stale)
                    + "; run python3 scripts/sync_surface_lighting.py --write\n")
    print("Surface lighting assets are synchronized.")


if __name__ == "__main__":
    main()
