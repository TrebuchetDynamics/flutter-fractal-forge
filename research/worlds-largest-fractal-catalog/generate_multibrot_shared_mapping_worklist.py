#!/usr/bin/env python3
"""Extract Multibrot shared-renderer mapping candidates.

Non-counting worklist for existing-app Multibrot source leads. It parses stable
power/exponent identities from generated ids so renderer mapping can be reviewed
without counting presets.
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/multibrot-shared-mapping-worklist.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/multibrot-shared-mapping-worklist.md"
MULTIBROT_SHADER = "shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag"
Z_RE = re.compile(r"multibrot_z_(\d+)$")
D_RE = re.compile(r"multibrot_d_(\d+)_(\d+)$")
INV_RE = re.compile(r"inverse_multibrot_d_(\d+)$")


def parse_power(stable_id: str) -> tuple[float | None, str]:
    if match := Z_RE.search(stable_id):
        return float(match.group(1)), "integer_power"
    if match := D_RE.search(stable_id):
        return float(f"{match.group(1)}.{match.group(2)}"), "fractional_power"
    if match := INV_RE.search(stable_id):
        return -float(match.group(1)), "inverse_power"
    return None, "manual_review"


def main() -> None:
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    batch = next(batch for batch in plan["batches"] if batch["candidate_shared_shader"] == MULTIBROT_SHADER)
    items = []
    ready = 0
    for candidate in batch["candidates"]:
        power, kind = parse_power(candidate["stable_id"])
        status = "ready_for_power_uniform_review" if power is not None else "needs_manual_power_review"
        if power is not None:
            ready += 1
        items.append({
            "stable_id": candidate["stable_id"],
            "metadata_source": candidate["metadata_source"],
            "thumbnail_plan": candidate["thumbnail_plan"],
            "candidate_shared_shader": MULTIBROT_SHADER,
            "parsed_power": power,
            "power_kind": kind,
            "status": status,
            "counted_entry": False,
            "promotion_gate": "Review shared Multibrot shader support for parsed power, render-smoke the mapped formula identity, then regenerate counted ledger.",
        })

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting Multibrot shared-renderer power mapping worklist for existing-app source leads.",
        "counting_rule": "Multibrot power/exponent identities remain uncounted until shared renderer mapping and render validation pass; presets/random seeds/palettes/camera views do not count.",
        "candidate_shared_shader": MULTIBROT_SHADER,
        "candidate_count": len(items),
        "ready_for_power_uniform_review_count": ready,
        "needs_manual_review_count": len(items) - ready,
        "items": items,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Multibrot Shared Mapping Worklist",
        "",
        "Non-counting power mapping worklist for Multibrot existing-app source leads.",
        "",
        "## Summary",
        "",
        f"- Candidate shared shader: `{MULTIBROT_SHADER}`",
        f"- Candidate leads: {payload['candidate_count']}",
        f"- Parsed powers: {payload['ready_for_power_uniform_review_count']}",
        f"- Needs manual review: {payload['needs_manual_review_count']}",
        "- Counted now: 0 from this worklist",
        "",
        "## Guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Items",
        "",
        "| Stable ID | Status | Power | Kind |",
        "|---|---|---:|---|",
    ]
    for item in items:
        power = "" if item["parsed_power"] is None else item["parsed_power"]
        lines.append(f"| `{item['stable_id']}` | {item['status']} | {power} | {item['power_kind']} |")
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "ready": ready, "total": len(items)}, indent=2))


if __name__ == "__main__":
    main()
