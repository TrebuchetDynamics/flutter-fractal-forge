#!/usr/bin/env python3
"""Generate implementation batches only for semantically supported candidates."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AUDIT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-semantic-support-audit.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/semantic-supported-implementation-batches.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/semantic-supported-implementation-batches.md"
BATCH_SIZE = 25


def main() -> None:
    audit = json.loads(AUDIT.read_text(encoding="utf-8"))
    supported = sorted(
        [i for i in audit["items"] if i["status"] == "semantic_mapping_supported"],
        key=lambda i: (i["batch"], i["stable_id"]),
    )
    blocked = sorted(
        [i for i in audit["items"] if i["status"] != "semantic_mapping_supported"],
        key=lambda i: (i["batch"], i["stable_id"]),
    )
    batches = []
    for offset in range(0, len(supported), BATCH_SIZE):
        chunk = supported[offset:offset + BATCH_SIZE]
        batches.append({
            "batch_index": len(batches),
            "candidate_ids": [i["stable_id"] for i in chunk],
            "families": sorted({i["batch"] for i in chunk}),
            "renderer_candidates": sorted({i["renderer_candidate"] for i in chunk}),
            "status": "semantic_supported_not_counted",
            "required_gates": [
                "implement reviewed Dart parameter mapping for each identity",
                "register renderable module identities without replacing counted live modules",
                "run render-smoke validation for every candidate",
                "rerun duplicate-risk, semantic-support, and catalog-goal validators",
                "only then regenerate a promoted counted ledger",
            ],
        })
    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting implementation batches limited to candidates whose shared renderer already exposes semantic parameters.",
        "source_audit": str(AUDIT.relative_to(ROOT)),
        "candidate_total": len(audit["items"]),
        "semantic_supported_total": len(supported),
        "extension_required_total": len(blocked),
        "batch_size": BATCH_SIZE,
        "batch_count": len(batches),
        "batches": batches,
        "extension_required_ids": [i["stable_id"] for i in blocked],
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    lines = [
        "# Semantic-Supported Implementation Batches",
        "",
        "Non-counting implementation batches restricted to candidates whose shared renderer already exposes semantic identity parameters.",
        "",
        "## Summary",
        "",
        f"- Source audit: `{payload['source_audit']}`",
        f"- Ready-backlog candidates audited: {payload['candidate_total']}",
        f"- Semantic-supported candidates: {payload['semantic_supported_total']}",
        f"- Extension-required candidates: {payload['extension_required_total']}",
        f"- Batch count: {payload['batch_count']}",
        "- Counted now: 0 from these batches",
        "",
        "## Batches",
        "",
        "| Batch | Count | Families | Renderer candidates |",
        "|---:|---:|---|---|",
    ]
    for batch in batches:
        lines.append(
            f"| {batch['batch_index']} | {len(batch['candidate_ids'])} | {', '.join(batch['families'])} | {', '.join(f'`{r}`' for r in batch['renderer_candidates'])} |"
        )
    lines.extend(["", "## First batch IDs", ""])
    if batches:
        lines.append(", ".join(batches[0]["candidate_ids"]))
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "supported": len(supported), "blocked": len(blocked), "batches": len(batches)}, indent=2))


if __name__ == "__main__":
    main()
