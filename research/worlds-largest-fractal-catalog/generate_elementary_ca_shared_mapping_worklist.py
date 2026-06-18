#!/usr/bin/env python3
"""Extract elementary cellular automata shared-shader mapping candidates.

Non-counting worklist for existing-app Elementary CA Rule N leads. It parses
Wolfram rule numbers so a reviewed shared renderer can map each formula/rule
identity to the existing CA shader without counting presets.
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/elementary-ca-shared-mapping-worklist.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/elementary-ca-shared-mapping-worklist.md"
CA_SHADER = "shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag"
RULE_RE = re.compile(r"elementary_ca_rule_(\d+)$")


def main() -> None:
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    batch = next(
        batch for batch in plan["batches"] if batch["candidate_shared_shader"] == CA_SHADER
    )
    items = []
    ready = 0
    for candidate in batch["candidates"]:
        stable_id = candidate["stable_id"]
        match = RULE_RE.search(stable_id)
        rule = int(match.group(1)) if match else None
        status = "ready_for_rule_uniform_review" if rule is not None and 0 <= rule <= 255 else "needs_manual_rule_review"
        if status == "ready_for_rule_uniform_review":
            ready += 1
        items.append({
            "stable_id": stable_id,
            "metadata_source": candidate["metadata_source"],
            "thumbnail_plan": candidate["thumbnail_plan"],
            "candidate_shared_shader": CA_SHADER,
            "parsed_rule_number": rule,
            "proposed_parameter_mapping": {
                "rule": rule,
                "generations": 256,
            } if rule is not None else None,
            "status": status,
            "counted_entry": False,
            "promotion_gate": "Review shader support for arbitrary Wolfram rule uniform, implement mapping, render-smoke each rule identity, then regenerate counted ledger.",
        })

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting elementary CA shared-renderer rule mapping worklist for existing-app source leads.",
        "counting_rule": "Elementary CA Rule N is a stable rule identity, but remains uncounted until shared renderer mapping and render validation pass; presets/random seeds/palettes/camera views do not count.",
        "candidate_shared_shader": CA_SHADER,
        "candidate_count": len(items),
        "ready_for_rule_uniform_review_count": ready,
        "needs_manual_review_count": len(items) - ready,
        "items": items,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Elementary CA Shared Mapping Worklist",
        "",
        "Non-counting rule mapping worklist for Elementary CA existing-app source leads.",
        "",
        "## Summary",
        "",
        f"- Candidate shared shader: `{CA_SHADER}`",
        f"- Candidate leads: {payload['candidate_count']}",
        f"- Parsed Wolfram rule numbers: {payload['ready_for_rule_uniform_review_count']}",
        f"- Needs manual review: {payload['needs_manual_review_count']}",
        "- Counted now: 0 from this worklist",
        "",
        "## Guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Items",
        "",
        "| Stable ID | Status | Rule |",
        "|---|---|---:|",
    ]
    for item in items:
        lines.append(f"| `{item['stable_id']}` | {item['status']} | {item['parsed_rule_number'] if item['parsed_rule_number'] is not None else ''} |")
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "ready": ready, "total": len(items)}, indent=2))


if __name__ == "__main__":
    main()
