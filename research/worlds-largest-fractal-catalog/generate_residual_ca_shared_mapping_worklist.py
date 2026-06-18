#!/usr/bin/env python3
"""Extract residual cellular/stochastic shared-renderer mapping candidates.

Non-counting worklist for small CA batches not covered by Elementary CA:
replicator, cyclic CA, maze-like rules, and forest fire. These are stable rule
identities, but remain uncounted until renderer mapping and render validation
pass.
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/residual-ca-shared-mapping-worklist.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/residual-ca-shared-mapping-worklist.md"
SHADERS = {
    "replicator": "shaders/cellular_and_stochastic/replicator_ca_gpu.frag",
    "cyclic": "shaders/cellular_and_stochastic/cyclic_ca_gpu.frag",
    "maze": "shaders/cellular_and_stochastic/maze_ca_gpu.frag",
    "forest_fire": "shaders/cellular_and_stochastic/forest_fire_gpu.frag",
}
CYCLIC_RE = re.compile(r"cyclic_ca_n_(\d+)$")
BS_RE = re.compile(r"_b(\d+)_s(\d+)")


def classify(stable_id: str, family: str) -> tuple[str, dict]:
    if family == "cyclic":
        n = int(CYCLIC_RE.search(stable_id).group(1)) if CYCLIC_RE.search(stable_id) else None
        return ("ready_for_cyclic_state_count_review" if n else "needs_manual_cyclic_review", {"states": n} if n else {})
    if family in {"replicator", "maze"}:
        match = BS_RE.search(stable_id)
        if match:
            return "ready_for_birth_survival_rule_review", {"birth": match.group(1), "survival": match.group(2), "family": family}
        return "needs_manual_birth_survival_review", {"family": family}
    if family == "forest_fire":
        return "ready_for_stochastic_rule_review", {"family": family}
    return "needs_manual_ca_review", {"family": family}


def main() -> None:
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    shader_to_family = {shader: family for family, shader in SHADERS.items()}
    batches = [b for b in plan["batches"] if b["candidate_shared_shader"] in shader_to_family]
    items = []
    ready = 0
    for batch in batches:
        shader = batch["candidate_shared_shader"]
        family = shader_to_family[shader]
        for candidate in batch["candidates"]:
            status, parsed = classify(candidate["stable_id"], family)
            if status.startswith("ready_for_"):
                ready += 1
            items.append({
                "stable_id": candidate["stable_id"],
                "metadata_source": candidate["metadata_source"],
                "thumbnail_plan": candidate["thumbnail_plan"],
                "candidate_shared_shader": shader,
                "parsed_mapping": parsed,
                "status": status,
                "counted_entry": False,
                "promotion_gate": "Review residual CA shared renderer mapping, render-smoke the mapped rule identity, then regenerate counted ledger.",
            })
    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting residual CA shared-renderer mapping worklist for existing-app source leads.",
        "counting_rule": "Residual CA/stochastic rule identities remain uncounted until shared renderer mapping and render validation pass; random seeds/palettes/camera views do not count.",
        "candidate_count": len(items),
        "ready_for_review_count": ready,
        "needs_manual_review_count": len(items) - ready,
        "items": items,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    lines = [
        "# Residual CA Shared Mapping Worklist",
        "",
        "Non-counting mapping worklist for residual CA/stochastic existing-app source leads.",
        "",
        "## Summary",
        "",
        f"- Candidate leads: {payload['candidate_count']}",
        f"- Ready mappings: {payload['ready_for_review_count']}",
        f"- Needs manual review: {payload['needs_manual_review_count']}",
        "- Counted now: 0 from this worklist",
        "",
        "## Guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Items",
        "",
        "| Stable ID | Status | Shader | Parsed mapping |",
        "|---|---|---|---|",
    ]
    for item in items:
        lines.append(f"| `{item['stable_id']}` | {item['status']} | `{item['candidate_shared_shader']}` | {json.dumps(item['parsed_mapping'], sort_keys=True)} |")
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "ready": ready, "total": len(items)}, indent=2))


if __name__ == "__main__":
    main()
