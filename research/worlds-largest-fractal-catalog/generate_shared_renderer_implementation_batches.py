#!/usr/bin/env python3
"""Generate non-counting implementation batches from shared-renderer ready backlog.

Batches are deterministic slices of mapping-ready, non-duplicate candidates. They
are not counted; each batch requires reviewed shared renderer mapping and
render-smoke validation before any existing-app lead can be promoted.
"""

from __future__ import annotations

import json
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BACKLOG = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-ready-backlog.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-implementation-batches.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-implementation-batches.md"
BATCH_SIZE = 25


def main() -> None:
    backlog = json.loads(BACKLOG.read_text(encoding="utf-8"))
    ready_items = sorted(
        backlog.get("ready_items", []),
        key=lambda item: (str(item.get("batch")), str(item.get("stable_id"))),
    )
    batches = []
    for offset in range(0, len(ready_items), BATCH_SIZE):
        chunk = ready_items[offset : offset + BATCH_SIZE]
        ids = [item["stable_id"] for item in chunk]
        batches.append({
            "batch_index": len(batches),
            "offset": offset,
            "limit": len(chunk),
            "candidate_ids": ids,
            "families": sorted({item["batch"] for item in chunk}),
            "renderer_candidates": sorted({item["renderer_candidate"] for item in chunk}),
            "status": "implementation_batch_not_counted",
            "required_gates": [
                "review shared renderer semantic compatibility",
                "implement parameter mapping/registration for each formula or rule identity",
                "run render-smoke validation for every candidate in this batch",
                "verify thumbnails remain existing bundled assets",
                "rerun duplicate-risk audit and ready-backlog validator",
                "only then regenerate a promoted counted ledger",
            ],
        })

    by_family = defaultdict(int)
    for item in ready_items:
        by_family[item["batch"]] += 1

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting deterministic implementation batches for shared-renderer ready backlog.",
        "counting_rule": "Implementation batches are not counted entries. Count only after renderer mapping, registration, render-smoke validation, duplicate audit, and catalog-goal validators pass.",
        "input_backlog": str(BACKLOG.relative_to(ROOT)),
        "batch_size": BATCH_SIZE,
        "candidate_total": len(ready_items),
        "batch_count": len(batches),
        "ready_by_family": dict(sorted(by_family.items())),
        "batches": batches,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Shared Renderer Implementation Batches",
        "",
        "Non-counting deterministic batches for implementing reviewed shared-renderer mappings.",
        "",
        "## Summary",
        "",
        f"- Input backlog: `{payload['input_backlog']}`",
        f"- Candidate total: {payload['candidate_total']}",
        f"- Batch size: {payload['batch_size']}",
        f"- Batch count: {payload['batch_count']}",
        "- Counted now: 0 from these batches",
        "",
        "## Guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Ready by family",
        "",
        "| Family batch | Candidates |",
        "|---|---:|",
    ]
    for family, count in payload["ready_by_family"].items():
        lines.append(f"| {family} | {count} |")
    lines.extend(["", "## Batches", "", "| Batch | Count | Families | Status |", "|---:|---:|---|---|"])
    for batch in batches:
        lines.append(
            f"| {batch['batch_index']} | {batch['limit']} | {', '.join(batch['families'])} | {batch['status']} |"
        )
    lines.extend(["", "## First batch IDs", ""])
    if batches:
        lines.append(", ".join(batches[0]["candidate_ids"]))
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "candidates": len(ready_items), "batches": len(batches)}, indent=2))


if __name__ == "__main__":
    main()
