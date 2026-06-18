#!/usr/bin/env python3
"""Extract Phoenix shared-shader mapping candidates.

Non-counting worklist for Phoenix-style existing-app source leads. It parses the
named degree from the stable id/name and flags the required parameter override
review before any entry can be counted.
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/phoenix-shared-mapping-worklist.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/phoenix-shared-mapping-worklist.md"
PHOENIX_SHADER = "shaders/escape_time_family/core/phoenix_gpu.frag"
DEGREE_RE = re.compile(r"phoenix_d_(\d+)$")


def main() -> None:
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    batch = next(
        batch for batch in plan["batches"] if batch["candidate_shared_shader"] == PHOENIX_SHADER
    )
    items = []
    ready = 0
    for candidate in batch["candidates"]:
        stable_id = candidate["stable_id"]
        match = DEGREE_RE.search(stable_id)
        degree = int(match.group(1)) if match else None
        status = "ready_for_power_override_review" if degree else "needs_manual_degree_review"
        if degree:
            ready += 1
        items.append({
            "stable_id": stable_id,
            "metadata_source": candidate["metadata_source"],
            "thumbnail_plan": candidate["thumbnail_plan"],
            "candidate_shared_shader": PHOENIX_SHADER,
            "parsed_degree": degree,
            "proposed_parameter_mapping": {
                "power": degree,
                "bailout": 4.0,
                "iterations": 500,
                "feedback": "requires review against live phoenix shader uniforms",
            } if degree else None,
            "status": status,
            "counted_entry": False,
            "promotion_gate": "Review Phoenix degree/feedback compatibility, implement parameter mapping, render-smoke each identity, then regenerate counted ledger.",
        })

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting Phoenix shared-renderer parameter mapping worklist for existing-app source leads.",
        "counting_rule": "Phoenix formula identities remain uncounted until shared renderer parameter mapping and render validation pass; degree names are formula identities, not random presets.",
        "candidate_shared_shader": PHOENIX_SHADER,
        "candidate_count": len(items),
        "ready_for_power_override_review_count": ready,
        "needs_manual_review_count": len(items) - ready,
        "items": items,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Phoenix Shared Mapping Worklist",
        "",
        "Non-counting parameter mapping worklist for Phoenix-style existing-app source leads.",
        "",
        "## Summary",
        "",
        f"- Candidate shared shader: `{PHOENIX_SHADER}`",
        f"- Candidate leads: {payload['candidate_count']}",
        f"- Ready for power override review: {payload['ready_for_power_override_review_count']}",
        f"- Needs manual review: {payload['needs_manual_review_count']}",
        "- Counted now: 0 from this worklist",
        "",
        "## Guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Items",
        "",
        "| Stable ID | Status | Parsed degree |",
        "|---|---|---:|",
    ]
    for item in items:
        lines.append(f"| `{item['stable_id']}` | {item['status']} | {item['parsed_degree'] or ''} |")
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "ready": ready, "total": len(items)}, indent=2))


if __name__ == "__main__":
    main()
