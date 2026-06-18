#!/usr/bin/env python3
"""Validate non-counting shared-renderer implementation batches."""

from __future__ import annotations

import json
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BATCHES = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-implementation-batches.json"
BACKLOG = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-ready-backlog.json"
REQUIRED_GATES = {
    "review shared renderer semantic compatibility",
    "implement parameter mapping/registration for each formula or rule identity",
    "run render-smoke validation for every candidate in this batch",
    "verify thumbnails remain existing bundled assets",
    "rerun duplicate-risk audit and ready-backlog validator",
    "only then regenerate a promoted counted ledger",
}


def main() -> int:
    data = json.loads(BATCHES.read_text(encoding="utf-8"))
    backlog = json.loads(BACKLOG.read_text(encoding="utf-8"))
    ready_ids = {item["stable_id"] for item in backlog.get("ready_items", [])}
    errors: list[str] = []
    seen: list[str] = []
    for batch in data.get("batches", []):
        if batch.get("status") != "implementation_batch_not_counted":
            errors.append(f"batch {batch.get('batch_index')} has counting status {batch.get('status')}")
        if set(batch.get("required_gates", [])) != REQUIRED_GATES:
            errors.append(f"batch {batch.get('batch_index')} missing required gates")
        ids = batch.get("candidate_ids", [])
        if batch.get("limit") != len(ids):
            errors.append(f"batch {batch.get('batch_index')} limit mismatch")
        seen.extend(ids)
        for stable_id in ids:
            if stable_id not in ready_ids:
                errors.append(f"batch {batch.get('batch_index')} contains non-ready id {stable_id}")
    counts = Counter(seen)
    dupes = [stable_id for stable_id, count in counts.items() if count > 1]
    if dupes:
        errors.append(f"duplicate ids across batches: {dupes[:20]}")
    if set(seen) != ready_ids:
        errors.append(f"batched ids do not match ready backlog: batched={len(set(seen))}, ready={len(ready_ids)}")
    if data.get("candidate_total") != len(seen):
        errors.append(f"candidate_total mismatch: {data.get('candidate_total')} != {len(seen)}")
    summary = {
        "candidate_total": len(seen),
        "batch_count": len(data.get("batches", [])),
        "errors": errors,
    }
    print(json.dumps(summary, indent=2, sort_keys=True))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
