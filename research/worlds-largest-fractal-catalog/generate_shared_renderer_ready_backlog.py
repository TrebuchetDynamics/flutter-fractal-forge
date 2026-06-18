#!/usr/bin/env python3
"""Generate a non-counting ready backlog for shared-renderer implementation.

Combines mapping worklists with duplicate-risk audit. Only candidates that are
non-duplicates and have enough parsed/exact mapping information are marked ready
for implementation. They still do not count until renderer mapping is actually
implemented and render-smoke validation passes.
"""

from __future__ import annotations

import json
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DUP_AUDIT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-duplicate-risk-audit.json"
WORKLISTS = {
    "julia": ROOT / "research/worlds-largest-fractal-catalog/julia-shared-mapping-worklist.json",
    "sprott": ROOT / "research/worlds-largest-fractal-catalog/sprott-shared-mapping-worklist.json",
    "phoenix": ROOT / "research/worlds-largest-fractal-catalog/phoenix-shared-mapping-worklist.json",
    "elementary_ca": ROOT / "research/worlds-largest-fractal-catalog/elementary-ca-shared-mapping-worklist.json",
    "mandelbrot": ROOT / "research/worlds-largest-fractal-catalog/mandelbrot-shared-mapping-worklist.json",
    "orbit_trap": ROOT / "research/worlds-largest-fractal-catalog/orbit-trap-shared-mapping-worklist.json",
    "multibrot": ROOT / "research/worlds-largest-fractal-catalog/multibrot-shared-mapping-worklist.json",
    "3d": ROOT / "research/worlds-largest-fractal-catalog/3d-shared-mapping-worklist.json",
    "escape_variant": ROOT / "research/worlds-largest-fractal-catalog/escape-variant-shared-mapping-worklist.json",
    "residual_ca": ROOT / "research/worlds-largest-fractal-catalog/residual-ca-shared-mapping-worklist.json",
}
OUT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-ready-backlog.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-ready-backlog.md"

READY_STATUSES = {
    "ready_for_reviewed_mapping",
    "exact_live_sprott_shader_available",
    "ready_for_power_override_review",
    "ready_for_rule_uniform_review",
    "ready_for_view_region_review",
    "ready_for_trap_geometry_review",
    "ready_for_power_uniform_review",
    "ready_for_scale_parameter_review",
    "ready_for_power_parameter_review",
    "ready_for_quaternion_c_review",
    "ready_for_kifs_family_review",
    "ready_for_expression_shader_review",
    "ready_for_birth_survival_rule_review",
    "ready_for_cyclic_state_count_review",
    "ready_for_stochastic_rule_review",
}


def main() -> None:
    dup = json.loads(DUP_AUDIT.read_text(encoding="utf-8"))
    duplicate_ids = {item["stable_id"] for item in dup.get("duplicate_risks", [])}
    items = []
    blocked = []
    for batch, path in WORKLISTS.items():
        data = json.loads(path.read_text(encoding="utf-8"))
        for item in data.get("items", []):
            stable_id = item["stable_id"]
            status = item.get("status")
            duplicate = stable_id in duplicate_ids
            ready_mapping = status in READY_STATUSES
            record = {
                "batch": batch,
                "stable_id": stable_id,
                "status": status,
                "duplicate_risk": duplicate,
                "mapping_ready": ready_mapping,
                "counted_entry": False,
                "thumbnail_plan": item.get("thumbnail_plan"),
                "metadata_source": item.get("metadata_source"),
                "renderer_candidate": item.get("candidate_shared_shader")
                or item.get("resolved_live_shader")
                or item.get("candidate_seed_shader"),
                "implementation_gate": "Implement reviewed shared renderer mapping and run render-smoke validation before promotion.",
            }
            if not duplicate and ready_mapping:
                items.append(record)
            else:
                reason = []
                if duplicate:
                    reason.append("duplicate_risk")
                if not ready_mapping:
                    reason.append("mapping_not_ready")
                blocked.append({**record, "blocked_reasons": reason})

    ready_by_batch = Counter(item["batch"] for item in items)
    blocked_by_reason = Counter(reason for item in blocked for reason in item["blocked_reasons"])
    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting implementation backlog for shared-renderer candidates that are non-duplicate and mapping-ready.",
        "counting_rule": "Backlog items are not counted entries. Count only after renderer mapping is implemented, render-smoke validation passes, and validators see a promoted renderer-backed formula/rule identity. Presets/random seeds/palettes/camera views do not count.",
        "ready_count": len(items),
        "blocked_count": len(blocked),
        "ready_by_batch": dict(ready_by_batch),
        "blocked_by_reason": dict(blocked_by_reason),
        "ready_items": items,
        "blocked_items": blocked,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Shared Renderer Ready Backlog",
        "",
        "Non-counting implementation backlog for shared-renderer candidates that are non-duplicate and mapping-ready.",
        "",
        "## Summary",
        "",
        f"- Ready implementation candidates: {payload['ready_count']}",
        f"- Blocked candidates: {payload['blocked_count']}",
        "- Counted now: 0 from this backlog",
        "",
        "## Guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Ready by batch",
        "",
        "| Batch | Ready candidates |",
        "|---|---:|",
    ]
    for batch, count in ready_by_batch.most_common():
        lines.append(f"| {batch} | {count} |")
    lines.extend([
        "",
        "## Blocked by reason",
        "",
        "| Reason | Candidates |",
        "|---|---:|",
    ])
    for reason, count in blocked_by_reason.most_common():
        lines.append(f"| {reason} | {count} |")
    lines.extend([
        "",
        "## Ready candidate IDs",
        "",
    ])
    for batch in sorted(ready_by_batch):
        ids = [item["stable_id"] for item in items if item["batch"] == batch]
        lines.extend([f"### {batch}", "", ", ".join(ids), ""])
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "ready": len(items), "blocked": len(blocked)}, indent=2))


if __name__ == "__main__":
    main()
