#!/usr/bin/env python3
"""Inline the canonical sine-sphere kernel without platform-local GLSL includes."""

import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIRECTORY = Path("shaders/3d_and_hypercomplex/raymarched_volumes")
BEGIN = "// BEGIN GENERATED SINE SPHERE KERNEL\n"
END = "// END GENERATED SINE SPHERE KERNEL\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="check without writing")
    args = parser.parse_args()
    kernel = (ROOT / DIRECTORY / "recursive_sine_sphere_kernel.glsl").read_text()
    block = BEGIN + kernel + END
    stale = []
    for path in [
        DIRECTORY / "recursive_sine_sphere_gpu.frag",
        Path("test/shaders/recursive_sine_sphere_kernel_fixture.frag"),
    ]:
        asset = ROOT / path
        source = asset.read_text()
        start = source.index(BEGIN)
        end = source.index(END, start) + len(END)
        updated = source[:start] + block + source[end:]
        if source != updated:
            stale.append(str(path))
            if not args.check:
                asset.write_text(updated)
    if args.check and stale:
        parser.exit(1, "Stale sine-sphere kernels: " + ", ".join(stale) + "\n")
    print("Sine-sphere kernel assets are synchronized.")


if __name__ == "__main__":
    main()
