#!/usr/bin/env python3
"""Extract 3D shared-renderer mapping candidates.

Non-counting worklist for existing-app 3D candidates (Mandelbox, Mandelbulb,
Quaternion Julia, Menger/KIFS) found by shader-linkage audit. It parses stable
formula parameters where available; entries remain uncounted until reviewed
renderer mapping and render validation pass.
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/3d-shared-mapping-worklist.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/3d-shared-mapping-worklist.md"
SHADERS = {
    "mandelbox": "shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag",
    "mandelbulb": "shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag",
    "quaternion_julia": "shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag",
    "menger": "shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag",
}
SCALE_RE = re.compile(r"mandelbox_s_(\d+)_(\d+)$")
POWER_RE = re.compile(r"mandelbulb_n_(\d+)$")
QJ_RE = re.compile(r"quaternion_julia_((?:\d+_?)+)$")


def parse_quaternion(stable_id: str) -> list[float] | None:
    match = QJ_RE.search(stable_id)
    if not match:
        return None
    parts = match.group(1).split("_")
    # Generated ids encode four decimal values as eight integer chunks.
    if len(parts) != 8:
        return None
    vals = []
    for a, b in zip(parts[0::2], parts[1::2]):
        vals.append(float(f"{a}.{b}"))
    # First known generated sample is named with a negative real component.
    if stable_id.startswith("f0540_quaternion_julia_0_2_"):
        vals[0] = -vals[0]
    return vals


def classify(stable_id: str, shader: str) -> tuple[str, dict | None]:
    if shader == SHADERS["mandelbox"]:
        if match := SCALE_RE.search(stable_id):
            return "ready_for_scale_parameter_review", {"scale": float(f"{match.group(1)}.{match.group(2)}")}
        return "needs_manual_mandelbox_review", None
    if shader == SHADERS["mandelbulb"]:
        if match := POWER_RE.search(stable_id):
            return "ready_for_power_parameter_review", {"power": int(match.group(1))}
        return "needs_manual_mandelbulb_review", None
    if shader == SHADERS["quaternion_julia"]:
        vals = parse_quaternion(stable_id)
        if vals:
            return "ready_for_quaternion_c_review", {"c": vals}
        return "needs_manual_quaternion_review", None
    if shader == SHADERS["menger"]:
        return "ready_for_kifs_family_review", {"family_hint": stable_id}
    return "needs_manual_3d_review", None


def main() -> None:
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    batches = [b for b in plan["batches"] if b["candidate_shared_shader"] in SHADERS.values()]
    items = []
    ready = 0
    for batch in batches:
        shader = batch["candidate_shared_shader"]
        for candidate in batch["candidates"]:
            status, parsed = classify(candidate["stable_id"], shader)
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
                "promotion_gate": "Review 3D shared renderer parameter mapping, render-smoke the mapped formula identity, then regenerate counted ledger.",
            })

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting 3D shared-renderer parameter mapping worklist for existing-app source leads.",
        "counting_rule": "3D formula identities remain uncounted until shared renderer mapping and render validation pass; camera/view presets do not count.",
        "candidate_count": len(items),
        "ready_for_parameter_review_count": ready,
        "needs_manual_review_count": len(items) - ready,
        "items": items,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# 3D Shared Mapping Worklist",
        "",
        "Non-counting parameter mapping worklist for 3D existing-app source leads.",
        "",
        "## Summary",
        "",
        f"- Candidate leads: {payload['candidate_count']}",
        f"- Ready parameter mappings: {payload['ready_for_parameter_review_count']}",
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
        parsed = json.dumps(item["parsed_mapping"], sort_keys=True) if item["parsed_mapping"] else ""
        lines.append(f"| `{item['stable_id']}` | {item['status']} | `{item['candidate_shared_shader']}` | {parsed} |")
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "ready": ready, "total": len(items)}, indent=2))


if __name__ == "__main__":
    main()
