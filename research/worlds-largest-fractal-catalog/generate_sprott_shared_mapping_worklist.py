#!/usr/bin/env python3
"""Extract Sprott shared-shader mapping candidates.

This is a non-counting worklist. It identifies generated Sprott source leads
that have exact live shader counterparts and separates Sprott/Linz variants
that need equation/coefficient mapping before promotion.
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/sprott-shared-mapping-worklist.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/sprott-shared-mapping-worklist.md"
SPROTT_SEED_SHADER = "shaders/strange_attractors/sprott_a_gpu.frag"

EXACT_LETTER_RE = re.compile(r"^f\d+_sprott_([a-z])$")
LIVE_SHADER_TEMPLATE = "shaders/strange_attractors/sprott_{letter}_gpu.frag"


def main() -> None:
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    sprott_batch = next(
        batch for batch in plan["batches"] if batch["candidate_shared_shader"] == SPROTT_SEED_SHADER
    )
    items = []
    exact = 0
    shader_inventory = {str(path.relative_to(ROOT)) for path in ROOT.glob("shaders/**/*.frag")}
    for candidate in sprott_batch["candidates"]:
        stable_id = candidate["stable_id"]
        match = EXACT_LETTER_RE.match(stable_id)
        resolved_shader = None
        if match:
            shader = LIVE_SHADER_TEMPLATE.format(letter=match.group(1))
            if shader in shader_inventory:
                resolved_shader = shader
        status = (
            "exact_live_sprott_shader_available"
            if resolved_shader
            else "needs_sprott_equation_coefficient_mapping"
        )
        if resolved_shader:
            exact += 1
        items.append({
            "stable_id": stable_id,
            "metadata_source": candidate["metadata_source"],
            "thumbnail_plan": candidate["thumbnail_plan"],
            "candidate_seed_shader": SPROTT_SEED_SHADER,
            "resolved_live_shader": resolved_shader,
            "status": status,
            "counted_entry": False,
            "promotion_gate": "Use exact live shader only after render smoke confirms formula identity; coefficient variants need reviewed equation mapping before promotion.",
        })

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting Sprott shared-renderer mapping worklist for existing-app source leads.",
        "counting_rule": "Sprott formula identities remain uncounted until exact shader or reviewed coefficient mapping and render validation pass; presets/random seeds/palettes/camera views are not entries.",
        "candidate_seed_shader": SPROTT_SEED_SHADER,
        "candidate_count": len(items),
        "exact_live_shader_available_count": exact,
        "needs_equation_mapping_count": len(items) - exact,
        "items": items,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Sprott Shared Mapping Worklist",
        "",
        "Non-counting renderer mapping worklist for Sprott-style existing-app source leads.",
        "",
        "## Summary",
        "",
        f"- Seed candidate shader from audit: `{SPROTT_SEED_SHADER}`",
        f"- Candidate leads: {payload['candidate_count']}",
        f"- Exact live Sprott shaders available: {payload['exact_live_shader_available_count']}",
        f"- Need equation/coefficient mapping: {payload['needs_equation_mapping_count']}",
        "- Counted now: 0 from this worklist",
        "",
        "## Guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Items",
        "",
        "| Stable ID | Status | Resolved live shader |",
        "|---|---|---|",
    ]
    for item in items:
        lines.append(
            f"| `{item['stable_id']}` | {item['status']} | {item['resolved_live_shader'] or ''} |"
        )
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "exact": exact, "total": len(items)}, indent=2))


if __name__ == "__main__":
    main()
