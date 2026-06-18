#!/usr/bin/env python3
"""Extract orbit-trap shared-renderer mapping candidates.

Non-counting worklist for existing-app orbit-trap source leads. It parses the
stable trap geometry token from the generated id/name so renderer mapping can be
reviewed without counting palette/camera presets.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/orbit-trap-shared-mapping-worklist.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/orbit-trap-shared-mapping-worklist.md"
ORBIT_SHADER = "shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag"


def trap_key(stable_id: str) -> str:
    prefix = stable_id.split("orbit_trap_", 1)
    return prefix[1] if len(prefix) == 2 else stable_id


def main() -> None:
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    batch = next(batch for batch in plan["batches"] if batch["candidate_shared_shader"] == ORBIT_SHADER)
    items = []
    for candidate in batch["candidates"]:
        key = trap_key(candidate["stable_id"])
        items.append({
            "stable_id": candidate["stable_id"],
            "metadata_source": candidate["metadata_source"],
            "thumbnail_plan": candidate["thumbnail_plan"],
            "candidate_shared_shader": ORBIT_SHADER,
            "parsed_trap_geometry": key,
            "status": "ready_for_trap_geometry_review",
            "counted_entry": False,
            "promotion_gate": "Review orbit-trap geometry uniform/mode mapping, render-smoke each stable trap geometry identity, then regenerate counted ledger.",
        })

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting orbit-trap shared-renderer geometry mapping worklist for existing-app source leads.",
        "counting_rule": "Orbit-trap geometry identities remain uncounted until shared renderer mapping and render validation pass; palette/camera-only variants do not count.",
        "candidate_shared_shader": ORBIT_SHADER,
        "candidate_count": len(items),
        "ready_for_trap_geometry_review_count": len(items),
        "needs_manual_review_count": 0,
        "items": items,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Orbit Trap Shared Mapping Worklist",
        "",
        "Non-counting geometry mapping worklist for orbit-trap existing-app source leads.",
        "",
        "## Summary",
        "",
        f"- Candidate shared shader: `{ORBIT_SHADER}`",
        f"- Candidate leads: {payload['candidate_count']}",
        f"- Ready trap-geometry mappings: {payload['ready_for_trap_geometry_review_count']}",
        "- Counted now: 0 from this worklist",
        "",
        "## Guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Items",
        "",
        "| Stable ID | Status | Trap geometry |",
        "|---|---|---|",
    ]
    for item in items:
        lines.append(f"| `{item['stable_id']}` | {item['status']} | `{item['parsed_trap_geometry']}` |")
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "ready": len(items), "total": len(items)}, indent=2))


if __name__ == "__main__":
    main()
