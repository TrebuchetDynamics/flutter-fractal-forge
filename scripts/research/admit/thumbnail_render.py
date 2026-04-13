"""Thumbnail renderer for admitted fractals.

STAGE B STUB: Writes a placeholder PNG (gradient) at 512x512. Real Flutter
headless render lands in Stage B+ (needs shader pipeline + Impeller backend).

For now, admission marks `quality.thumbnail = {entropy: ..., placeholder: true}`
until real render replaces it.
"""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image


def compute_entropy(image_path: Path) -> float:
    """Shannon entropy of 8-bit grayscale histogram. Placeholder images score
    low; real rendered fractals typically score 4-7."""
    img = Image.open(image_path).convert("L")
    hist = img.histogram()
    total = sum(hist)
    if total == 0:
        return 0.0
    entropy = 0.0
    for count in hist:
        if count:
            p = count / total
            entropy -= p * math.log2(p)
    return entropy


def render_placeholder(output_path: Path, size: int = 512, seed_hash: str = "") -> None:
    """Write a 512x512 placeholder PNG. Color depends on hash prefix for variety."""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    # Derive a deterministic RGB from seed_hash
    if seed_hash:
        h = seed_hash.replace("sha256:", "")[:6]
        try:
            r = int(h[0:2], 16)
            g = int(h[2:4], 16)
            b = int(h[4:6], 16)
        except ValueError:
            r, g, b = 32, 32, 64
    else:
        r, g, b = 32, 32, 64

    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * size)
            px[x, y] = (
                int(r * (1 - t) + 200 * t),
                int(g * (1 - t) + 64 * t),
                int(b * (1 - t) + 32 * t),
            )
    img.save(output_path, "PNG")


def render(
    fractal_id: str,
    formula_hash: str,
    output_path: Path,
    size: int = 512,
) -> dict:
    """Render a thumbnail. STAGE B STUB: produces a placeholder gradient.

    Returns a dict usable as `quality.thumbnail`:
      {entropy: float, checked: str, placeholder: bool, size: [w, h]}
    """
    render_placeholder(output_path, size=size, seed_hash=formula_hash)
    entropy = compute_entropy(output_path)
    from datetime import date
    return {
        "entropy": round(entropy, 3),
        "checked": date.today().isoformat(),
        "placeholder": True,
        "size": [size, size],
    }
