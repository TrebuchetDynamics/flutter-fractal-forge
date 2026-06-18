#!/usr/bin/env python3
"""Extract Julia shared-shader parameter mapping candidates.

This is a non-counting worklist. It parses generated metadata aliases for
Julia constants (for example `c=0.0+1.0i`) so a reviewed shared-renderer batch
can be implemented without treating random presets as catalog entries.
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PLAN = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/julia-shared-mapping-worklist.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/julia-shared-mapping-worklist.md"
JULIA_SHADER = "shaders/escape_time_family/core/julia_gpu.frag"

ALIAS_LIST_RE = re.compile(r"List<String>\s+get\s+aliases\s*=>\s*const\s*\[(.*?)\];", re.DOTALL)
STRING_RE = re.compile(r"'([^']+)'")
NUMBER_RE = r"[+-]?\d+(?:\.\d+)?(?:e[+-]?\d+)?"
C_RE = re.compile(
    rf"c\s*=\s*({NUMBER_RE})\s*([+-])\s*({NUMBER_RE})i",
    re.IGNORECASE,
)


def aliases_from_metadata(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    block = ALIAS_LIST_RE.search(text)
    if not block:
        return []
    return STRING_RE.findall(block.group(1))


def parse_c(aliases: list[str]) -> dict | None:
    for alias in aliases:
        match = C_RE.search(alias)
        if match:
            real = float(match.group(1))
            imag = float(match.group(3))
            if match.group(2) == "-":
                imag = -imag
            return {"source_alias": alias, "c_re": real, "c_im": imag}
    return None


def main() -> None:
    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    julia_batch = next(
        batch for batch in plan["batches"] if batch["candidate_shared_shader"] == JULIA_SHADER
    )
    items = []
    ready = 0
    for candidate in julia_batch["candidates"]:
        metadata_path = ROOT / candidate["metadata_source"]
        aliases = aliases_from_metadata(metadata_path)
        parsed = parse_c(aliases)
        status = "ready_for_reviewed_mapping" if parsed else "needs_manual_c_parameter_review"
        if parsed:
            ready += 1
        items.append({
            "stable_id": candidate["stable_id"],
            "metadata_source": candidate["metadata_source"],
            "thumbnail_plan": candidate["thumbnail_plan"],
            "candidate_shared_shader": JULIA_SHADER,
            "aliases": aliases,
            "parsed_c": parsed,
            "status": status,
            "counted_entry": False,
            "promotion_gate": "Implement reviewed Julia c-parameter mapping, render-smoke the mapped formula identity, then regenerate counted ledger.",
        })

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting Julia shared-renderer parameter mapping worklist for existing-app source leads.",
        "counting_rule": "Formula/rule identities remain uncounted until renderer mapping and render validation pass; aliases are used only to derive named Julia constants, not random presets.",
        "candidate_shared_shader": JULIA_SHADER,
        "candidate_count": len(items),
        "ready_for_reviewed_mapping_count": ready,
        "needs_manual_review_count": len(items) - ready,
        "items": items,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Julia Shared Mapping Worklist",
        "",
        "Non-counting parameter mapping worklist for Julia-style existing-app source leads.",
        "",
        "## Summary",
        "",
        f"- Candidate shared shader: `{JULIA_SHADER}`",
        f"- Candidate leads: {payload['candidate_count']}",
        f"- Parseable `c` constants: {payload['ready_for_reviewed_mapping_count']}",
        f"- Needs manual `c` review: {payload['needs_manual_review_count']}",
        "- Counted now: 0 from this worklist",
        "",
        "## Guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Items",
        "",
        "| Stable ID | Status | Parsed c | Source alias |",
        "|---|---|---|---|",
    ]
    for item in items:
        parsed = item["parsed_c"]
        c_text = "" if not parsed else f"{parsed['c_re']} + {parsed['c_im']}i"
        source = "" if not parsed else parsed["source_alias"]
        lines.append(f"| `{item['stable_id']}` | {item['status']} | {c_text} | {source} |")
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "ready": ready, "total": len(items)}, indent=2))


if __name__ == "__main__":
    main()
