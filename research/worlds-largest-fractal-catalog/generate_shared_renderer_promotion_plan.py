#!/usr/bin/env python3
"""Generate an implementation plan for existing-app shared-renderer promotion.

The plan is intentionally non-counting. It converts shader-linkage audit
candidates into reviewed batches with explicit gates needed before any entry can
be promoted as a curated renderable formula/rule identity.
"""

from __future__ import annotations

import json
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AUDIT = ROOT / "research/worlds-largest-fractal-catalog/existing-app-shader-linkage-audit.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.md"

COMMON_GATES = [
    "review shared shader semantic compatibility with the generated module formula/rule",
    "define parameter mapping from generated module defaults/metadata to shared shader uniforms",
    "register or otherwise expose the generated formula/rule as a renderable catalog identity",
    "run render smoke and quality metrics for the mapped renderer",
    "verify thumbnail asset exists and is not a random preset/palette/camera-only variant",
    "flip counted_entry only after validator and completion audit inputs see existing renderer + validation signals",
]

SHADER_NOTES = {
    "shaders/escape_time_family/core/julia_gpu.frag": "Julia-style complex-plane identities. Needs c-parameter/seed mapping from metadata or a reviewed default, not random presets.",
    "shaders/escape_time_family/core/phoenix_gpu.frag": "Phoenix escape-time identities. Needs degree/feedback parameter compatibility review.",
    "shaders/strange_attractors/sprott_a_gpu.frag": "Sprott-style attractor identities. Needs per-system coefficient mapping; do not collapse distinct Sprott equations into one visual without parameter validation.",
}


def main() -> None:
    audit = json.loads(AUDIT.read_text(encoding="utf-8"))
    candidates = audit.get("shared_shader_candidates", [])
    by_shader: dict[str, list[dict]] = defaultdict(list)
    for item in candidates:
        by_shader[item["candidate_shared_shader"]].append(item)

    batches = []
    for shader, items in sorted(by_shader.items(), key=lambda pair: (-len(pair[1]), pair[0])):
        ids = [item["stable_id"] for item in items]
        batches.append({
            "candidate_shared_shader": shader,
            "candidate_count": len(items),
            "status": "implementation_plan_only_not_counted",
            "notes": SHADER_NOTES.get(shader, "Requires reviewed shared renderer mapping before promotion."),
            "promotion_gates": COMMON_GATES,
            "candidate_ids": ids,
            "candidates": items,
        })

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting promotion plan for existing-app source leads that may share reviewed renderer shaders.",
        "counting_rule": "Candidates remain uncounted until formula/rule identity, renderer path, parameter mapping, thumbnail, provenance, and render validation all pass. Presets/random seeds/palettes/camera views are not entries.",
        "input_audit": str(AUDIT.relative_to(ROOT)),
        "candidate_total": len(candidates),
        "batch_count": len(batches),
        "batches": batches,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Shared Renderer Promotion Plan",
        "",
        "Non-counting implementation plan for existing-app source leads that may share reviewed renderer shaders.",
        "",
        "## Summary",
        "",
        f"- Input audit: `{payload['input_audit']}`",
        f"- Candidate leads: {payload['candidate_total']}",
        f"- Candidate shader batches: {payload['batch_count']}",
        "- Counted now: 0 from this plan",
        "",
        "## Counting guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Batches",
        "",
        "| Candidate shared shader | Leads | Status |",
        "|---|---:|---|",
    ]
    for batch in batches:
        lines.append(
            f"| `{batch['candidate_shared_shader']}` | {batch['candidate_count']} | {batch['status']} |"
        )
    lines.extend(["", "## Promotion gates", ""])
    for gate in COMMON_GATES:
        lines.append(f"- {gate}")
    lines.extend(["", "## Candidate IDs by batch", ""])
    for batch in batches:
        lines.extend([
            f"### `{batch['candidate_shared_shader']}`",
            "",
            batch["notes"],
            "",
            ", ".join(batch["candidate_ids"]),
            "",
        ])
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "candidate_total": len(candidates)}, indent=2))


if __name__ == "__main__":
    main()
