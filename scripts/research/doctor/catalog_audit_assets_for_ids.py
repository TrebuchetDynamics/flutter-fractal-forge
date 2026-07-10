#!/usr/bin/env python3
"""Return comma-separated shader assets for module IDs from a list-only audit report."""

from __future__ import annotations

import json
import sys
from pathlib import Path

RUNTIME_SHADERS = [
    "shaders/runtime/ink_sparkle.frag",
    "shaders/runtime/post_glow_h.frag",
    "shaders/runtime/post_glow_v.frag",
    "shaders/runtime/fluid_warp.frag",
]


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: catalog_audit_assets_for_ids.py <catalog.json> <id,id,...>", file=sys.stderr)
        return 2

    catalog = json.loads(Path(sys.argv[1]).read_text())
    wanted = {part for part in sys.argv[2].split(",") if part}
    assets = list(RUNTIME_SHADERS)
    for entry in catalog.get("selectedEntries", []):
        if entry.get("moduleId") in wanted or entry.get("catalogId") in wanted:
            assets.append(entry["shaderAsset"])
    assets = list(dict.fromkeys(assets))
    print(",".join(assets))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
