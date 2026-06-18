#!/usr/bin/env python3
"""Extract escape-variant shared-renderer mapping candidates.

Non-counting worklist for tricorn, burning-ship, sine, and cosine Mandelbrot
variant candidates. It parses stable power/expression tokens so renderer mapping
can be reviewed without counting presets.
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/escape-variant-shared-mapping-worklist.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/escape-variant-shared-mapping-worklist.md"
SHADERS = {
    "tricorn": "shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_gpu.frag",
    "burning_ship": "shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag",
    "sine": "shaders/trigonometric_and_transcendental/elementary_trig/sine_mandelbrot_gpu.frag",
    "cosine": "shaders/trigonometric_and_transcendental/elementary_trig/cosine_mandelbrot_gpu.frag",
}
D_RE = re.compile(r"(?:tricorn|burning_ship)_d_(\d+)$")
Z_RE = re.compile(r"(?:tricorn|burning_ship)_z_(\d+)_(\d+)$")


def expression_token(stable_id: str) -> str:
    return re.sub(r"^f\d+_", "", stable_id)


def classify(stable_id: str, family: str) -> tuple[str, dict]:
    if family in {"tricorn", "burning_ship"}:
        if match := D_RE.search(stable_id):
            return "ready_for_power_parameter_review", {"power": int(match.group(1)), "variant_family": family}
        if match := Z_RE.search(stable_id):
            return "ready_for_power_parameter_review", {"power": float(f"{match.group(1)}.{match.group(2)}"), "variant_family": family}
        return "needs_manual_escape_variant_review", {"variant_family": family}
    return "ready_for_expression_shader_review", {"expression_token": expression_token(stable_id), "variant_family": family}


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
                "promotion_gate": "Review escape-variant shared shader support, render-smoke the mapped formula identity, then regenerate counted ledger.",
            })

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting escape-variant shared-renderer mapping worklist for existing-app source leads.",
        "counting_rule": "Escape variant formula identities remain uncounted until shared renderer mapping and render validation pass; presets/random seeds/palettes/camera views do not count.",
        "candidate_count": len(items),
        "ready_for_review_count": ready,
        "needs_manual_review_count": len(items) - ready,
        "items": items,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Escape Variant Shared Mapping Worklist",
        "",
        "Non-counting mapping worklist for tricorn, burning-ship, sine, and cosine candidates.",
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
        parsed = json.dumps(item["parsed_mapping"], sort_keys=True)
        lines.append(f"| `{item['stable_id']}` | {item['status']} | `{item['candidate_shared_shader']}` | {parsed} |")
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "ready": ready, "total": len(items)}, indent=2))


if __name__ == "__main__":
    main()
