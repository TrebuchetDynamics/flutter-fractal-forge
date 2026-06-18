#!/usr/bin/env python3
"""Extract Mandelbrot-family shared-renderer mapping candidates.

Non-counting worklist for existing-app candidates currently grouped under the
`mandel_julia_dual` shared shader. It parses stable formula signals where
available (period mini-brots, named power d, view aliases) and marks formula
variants for renderer-compatibility review.
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/mandelbrot-shared-mapping-worklist.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/mandelbrot-shared-mapping-worklist.md"
MANDEL_SHADER = "shaders/escape_time_family/core/mandel_julia_dual_gpu.frag"

PERIOD_RE = re.compile(r"mini_mandelbrot_period_(\d+)$")
POWER_RE = re.compile(r"mandelbrot_power_d_(\d+)_(\d+)$")
VIEW_RE = re.compile(r"view\s*\(([-+]?\d+(?:\.\d+)?),\s*([-+]?\d+(?:\.\d+)?)\)\s*zoom\s*([-+]?\d+(?:\.\d+)?)", re.I)
ALIAS_LIST_RE = re.compile(r"List<String>\s+get\s+aliases\s*=>\s*const\s*\[(.*?)\];", re.DOTALL)
STRING_RE = re.compile(r"'([^']+)'")


def aliases_from_metadata(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    block = ALIAS_LIST_RE.search(text)
    return STRING_RE.findall(block.group(1)) if block else []


def parse_view(aliases: list[str]) -> dict | None:
    for alias in aliases:
        match = VIEW_RE.search(alias)
        if match:
            return {"source_alias": alias, "center_re": float(match.group(1)), "center_im": float(match.group(2)), "zoom": float(match.group(3))}
    return None


def classify(stable_id: str, aliases: list[str]) -> tuple[str, dict | None]:
    if match := PERIOD_RE.search(stable_id):
        payload = {"period": int(match.group(1)), "view": parse_view(aliases)}
        return "ready_for_view_region_review", payload
    if match := POWER_RE.search(stable_id):
        power = float(f"{match.group(1)}.{match.group(2)}")
        return "needs_power_uniform_compatibility_review", {"power": power}
    if any(token in stable_id for token in ["celtic", "buffalo", "heart", "perpendicular", "anti", "lambda"]):
        return "needs_formula_variant_shader_review", None
    if any(token in stable_id for token in ["sine", "cosine", "tangent", "hyperbolic", "exponential", "log", "gamma", "z_sin", "z_cos", "z_exp"]):
        return "needs_transcendental_shader_review", None
    return "needs_manual_mandelbrot_mapping_review", None


def main() -> None:
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    batch = next(batch for batch in plan["batches"] if batch["candidate_shared_shader"] == MANDEL_SHADER)
    items = []
    ready = 0
    for candidate in batch["candidates"]:
        metadata_path = ROOT / candidate["metadata_source"]
        aliases = aliases_from_metadata(metadata_path)
        status, parsed = classify(candidate["stable_id"], aliases)
        if status == "ready_for_view_region_review":
            ready += 1
        items.append({
            "stable_id": candidate["stable_id"],
            "metadata_source": candidate["metadata_source"],
            "thumbnail_plan": candidate["thumbnail_plan"],
            "candidate_shared_shader": MANDEL_SHADER,
            "aliases": aliases,
            "parsed_mapping": parsed,
            "status": status,
            "counted_entry": False,
            "promotion_gate": "Review formula/view mapping against shared Mandelbrot shader, render-smoke the mapped identity, then regenerate counted ledger.",
        })

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting Mandelbrot-family shared-renderer mapping worklist for existing-app source leads.",
        "counting_rule": "Mandelbrot-family formula/view identities remain uncounted until shared renderer mapping and render validation pass; view aliases identify named stable regions, not random camera presets.",
        "candidate_shared_shader": MANDEL_SHADER,
        "candidate_count": len(items),
        "ready_for_view_region_review_count": ready,
        "needs_review_count": len(items) - ready,
        "items": items,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Mandelbrot Shared Mapping Worklist",
        "",
        "Non-counting mapping worklist for Mandelbrot-family existing-app source leads.",
        "",
        "## Summary",
        "",
        f"- Candidate shared shader: `{MANDEL_SHADER}`",
        f"- Candidate leads: {payload['candidate_count']}",
        f"- Ready view/period mappings: {payload['ready_for_view_region_review_count']}",
        f"- Needs renderer compatibility review: {payload['needs_review_count']}",
        "- Counted now: 0 from this worklist",
        "",
        "## Guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Items",
        "",
        "| Stable ID | Status | Parsed mapping |",
        "|---|---|---|",
    ]
    for item in items:
        parsed = json.dumps(item["parsed_mapping"], sort_keys=True) if item["parsed_mapping"] else ""
        lines.append(f"| `{item['stable_id']}` | {item['status']} | {parsed} |")
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "ready": ready, "total": len(items)}, indent=2))


if __name__ == "__main__":
    main()
