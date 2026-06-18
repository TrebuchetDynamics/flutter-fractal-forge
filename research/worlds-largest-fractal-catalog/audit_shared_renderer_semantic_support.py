#!/usr/bin/env python3
"""Audit semantic support for shared-renderer ready backlog candidates.

A candidate is not safely promotable just because a shared shader asset exists.
When multiple formula/rule identities share one shader, the shader + Dart mapping
must expose parameters that distinguish the identities. This audit classifies
ready-backlog candidates into immediate mapping candidates versus candidates
that need shader/mapper extensions before render-smoke promotion.
"""

from __future__ import annotations

import json
import re
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BACKLOG = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-ready-backlog.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-semantic-support-audit.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-semantic-support-audit.md"

# Uniform names that prove a shared shader can distinguish identities in a batch.
REQUIRED_UNIFORMS_BY_BATCH = {
    "julia": ["uJuliaReal", "uJuliaImag"],
    "phoenix": ["uPhoenixCReal", "uPhoenixCImag", "uPhoenixP", "uPhoenixPower"],
    "elementary_ca": ["uRule"],
    "residual_ca": ["uBirthMask", "uSurvivalMask", "uStates", "uRuleFamily"],
    "mandelbrot": ["uPeriod", "uViewRegion"],
    "multibrot": ["uPower"],
    "orbit_trap": ["uTrapType", "uTrapScale"],
    "3d": ["uPower", "uScale", "uJulia"],
    "escape_variant": ["uPower", "uExpressionType"],
    "sprott": ["uCoeff"],
}

# Some existing bespoke shaders/modules already expose compatible parameter names.
ALIASES = {
    "uPower": ["power", "uPower", "uBulbPower", "uExponent"],
    "uScale": ["uScale", "uBoxScale", "scale"],
    "uJulia": ["uJulia", "uJuliaReal", "uJuliaImag", "uC"],
    "uCoeff": ["uCoeff", "uA", "uB", "uC", "uD"],
}

UNIFORM_RE = re.compile(r"uniform\s+\w+\s+(\w+)")


def shader_uniforms(renderer_candidate: str) -> set[str]:
    path = ROOT / renderer_candidate
    if not path.exists():
        return set()
    text = path.read_text(encoding="utf-8", errors="replace")
    return set(UNIFORM_RE.findall(text))


def has_required(uniforms: set[str], required: list[str]) -> bool:
    for name in required:
        names = ALIASES.get(name, [name])
        if not any(candidate in uniforms for candidate in names):
            return False
    return True


def main() -> None:
    backlog = json.loads(BACKLOG.read_text(encoding="utf-8"))
    items = backlog.get("ready_items", [])
    renderer_uniform_cache: dict[str, set[str]] = {}
    audited = []
    status_counts = Counter()
    by_batch = Counter()
    by_status_batch = defaultdict(Counter)

    for item in items:
        batch = item["batch"]
        renderer = item["renderer_candidate"]
        uniforms = renderer_uniform_cache.setdefault(renderer, shader_uniforms(renderer))
        required = REQUIRED_UNIFORMS_BY_BATCH.get(batch, [])
        if batch == "residual_ca" and item.get("status") == "ready_for_cyclic_state_count_review":
            required = ["uStates"]
        if batch == "residual_ca" and item.get("status") == "ready_for_birth_survival_rule_review":
            required = ["uBirthMask", "uSurvivalMask"]
        supported = has_required(uniforms, required) if required else False
        if batch == "sprott" and item.get("status") == "exact_live_sprott_shader_available":
            supported = True
        status = "semantic_mapping_supported" if supported else "needs_shader_or_mapper_extension"
        status_counts[status] += 1
        by_batch[batch] += 1
        by_status_batch[batch][status] += 1
        audited.append({
            "stable_id": item["stable_id"],
            "batch": batch,
            "renderer_candidate": renderer,
            "required_uniforms_or_aliases": required,
            "shader_uniforms": sorted(uniforms),
            "status": status,
            "counted_entry": False,
            "promotion_gate": "Only semantic_mapping_supported candidates may proceed to reviewed mapping + render-smoke; extension-needed candidates require shader/mapper changes first.",
        })

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting semantic support audit for shared-renderer promotion candidates.",
        "candidate_total": len(items),
        "status_counts": dict(status_counts),
        "batch_counts": dict(sorted(by_batch.items())),
        "status_by_batch": {batch: dict(counts) for batch, counts in sorted(by_status_batch.items())},
        "items": audited,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Shared Renderer Semantic Support Audit",
        "",
        "Non-counting audit: a shared shader asset is insufficient unless it exposes parameters that distinguish formula/rule identities.",
        "",
        "## Summary",
        "",
        f"- Candidate total: {payload['candidate_total']}",
        f"- Semantic mapping supported: {payload['status_counts'].get('semantic_mapping_supported', 0)}",
        f"- Needs shader/mapper extension: {payload['status_counts'].get('needs_shader_or_mapper_extension', 0)}",
        "- Counted now: 0 from this audit",
        "",
        "## By batch",
        "",
        "| Batch | Total | Supported | Needs extension |",
        "|---|---:|---:|---:|",
    ]
    for batch, total in payload["batch_counts"].items():
        counts = payload["status_by_batch"].get(batch, {})
        lines.append(
            f"| {batch} | {total} | {counts.get('semantic_mapping_supported', 0)} | {counts.get('needs_shader_or_mapper_extension', 0)} |"
        )
    lines.extend(["", "## Guardrail", "", "Candidates marked `needs_shader_or_mapper_extension` must not be counted until shader/Dart mapping support distinguishes their formula or rule identity and render-smoke validation passes.", ""])
    MD_OUT.write_text("\n".join(lines), encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "status_counts": payload["status_counts"]}, indent=2))


if __name__ == "__main__":
    main()
