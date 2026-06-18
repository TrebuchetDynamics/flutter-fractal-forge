#!/usr/bin/env python3
"""Audit duplicate-count risk for shared-renderer promotion candidates.

This is non-counting. It checks whether generated existing-app candidates appear
to represent formula/rule identities already counted in the live-registry
ledger, so future promotion does not inflate totals by duplicate IDs.
"""

from __future__ import annotations

import json
import re
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LIVE_LEDGER = ROOT / "research/worlds-largest-fractal-catalog/curated-entry-ledger.live-registry.json"
WORKLISTS = [
    ROOT / "research/worlds-largest-fractal-catalog/julia-shared-mapping-worklist.json",
    ROOT / "research/worlds-largest-fractal-catalog/sprott-shared-mapping-worklist.json",
    ROOT / "research/worlds-largest-fractal-catalog/phoenix-shared-mapping-worklist.json",
    ROOT / "research/worlds-largest-fractal-catalog/elementary-ca-shared-mapping-worklist.json",
    ROOT / "research/worlds-largest-fractal-catalog/mandelbrot-shared-mapping-worklist.json",
    ROOT / "research/worlds-largest-fractal-catalog/orbit-trap-shared-mapping-worklist.json",
    ROOT / "research/worlds-largest-fractal-catalog/multibrot-shared-mapping-worklist.json",
    ROOT / "research/worlds-largest-fractal-catalog/3d-shared-mapping-worklist.json",
    ROOT / "research/worlds-largest-fractal-catalog/escape-variant-shared-mapping-worklist.json",
    ROOT / "research/worlds-largest-fractal-catalog/residual-ca-shared-mapping-worklist.json",
]
OUT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-duplicate-risk-audit.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-duplicate-risk-audit.md"
PREFIX_RE = re.compile(r"^f\d+_")


def canonical(stable_id: str) -> str:
    return PREFIX_RE.sub("", stable_id).lower()


def worklist_family(path: Path) -> str:
    name = path.name
    return name.split("-", 1)[0]


def main() -> None:
    live = json.loads(LIVE_LEDGER.read_text(encoding="utf-8"))
    live_by_canonical = {canonical(entry["stable_id"]): entry["stable_id"] for entry in live["entries"]}
    items = []
    duplicates = []
    not_duplicates = []
    for path in WORKLISTS:
        data = json.loads(path.read_text(encoding="utf-8"))
        batch = worklist_family(path)
        for item in data.get("items", []):
            stable_id = item["stable_id"]
            key = canonical(stable_id)
            live_id = live_by_canonical.get(key)
            record = {
                "batch": batch,
                "stable_id": stable_id,
                "canonical_identity": key,
                "live_registry_match": live_id,
                "duplicate_risk": live_id is not None,
                "candidate_status": item.get("status"),
                "counted_entry": False,
            }
            items.append(record)
            (duplicates if live_id else not_duplicates).append(record)

    by_batch = Counter(item["batch"] for item in items)
    duplicates_by_batch = Counter(item["batch"] for item in duplicates)
    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Non-counting duplicate-risk audit for shared-renderer candidates against counted live-registry identities.",
        "counting_rule": "Do not promote a generated candidate as a new counted entry if it is the same formula/rule identity as an already counted live module; aliases/presets must not inflate totals.",
        "live_ledger": str(LIVE_LEDGER.relative_to(ROOT)),
        "candidate_total": len(items),
        "duplicate_risk_count": len(duplicates),
        "non_duplicate_candidate_count": len(not_duplicates),
        "candidates_by_batch": dict(by_batch),
        "duplicates_by_batch": dict(duplicates_by_batch),
        "duplicate_risks": duplicates,
        "non_duplicate_candidates": not_duplicates,
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Shared Renderer Duplicate-Risk Audit",
        "",
        "Non-counting audit to prevent duplicate formula/rule counting when promoting existing-app shared-renderer candidates.",
        "",
        "## Summary",
        "",
        f"- Candidate total: {payload['candidate_total']}",
        f"- Duplicate-risk candidates: {payload['duplicate_risk_count']}",
        f"- Non-duplicate candidates: {payload['non_duplicate_candidate_count']}",
        "- Counted now: 0 from this audit",
        "",
        "## Guardrail",
        "",
        payload["counting_rule"],
        "",
        "## Duplicate risks",
        "",
        "| Batch | Candidate | Canonical identity | Counted live match |",
        "|---|---|---|---|",
    ]
    for item in duplicates:
        lines.append(
            f"| {item['batch']} | `{item['stable_id']}` | `{item['canonical_identity']}` | `{item['live_registry_match']}` |"
        )
    lines.extend([
        "",
        "## Non-duplicate candidate counts by batch",
        "",
        "| Batch | Non-duplicate candidates |",
        "|---|---:|",
    ])
    nondup_by_batch = Counter(item["batch"] for item in not_duplicates)
    for batch, count in nondup_by_batch.most_common():
        lines.append(f"| {batch} | {count} |")
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "duplicates": len(duplicates), "non_duplicates": len(not_duplicates)}, indent=2))


if __name__ == "__main__":
    main()
