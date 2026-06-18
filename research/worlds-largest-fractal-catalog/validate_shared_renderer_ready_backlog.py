#!/usr/bin/env python3
"""Validate the non-counting shared-renderer ready backlog.

This guardrail ensures implementation candidates stay uncounted until reviewed
renderer mapping and render-smoke validation exist. It also checks duplicate
risk, required metadata, and aggregate counts for the current backlog artifact.
"""

from __future__ import annotations

import json
import sys
from collections import Counter
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
BACKLOG = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-ready-backlog.json"
DUP_AUDIT = ROOT / "research/worlds-largest-fractal-catalog/shared-renderer-duplicate-risk-audit.json"

REQUIRED_READY_FIELDS = {
    "batch",
    "stable_id",
    "status",
    "duplicate_risk",
    "mapping_ready",
    "counted_entry",
    "thumbnail_plan",
    "metadata_source",
    "renderer_candidate",
    "implementation_gate",
}


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    backlog = load_json(BACKLOG)
    dup_audit = load_json(DUP_AUDIT)
    errors: list[str] = []
    ready = backlog.get("ready_items", [])
    blocked = backlog.get("blocked_items", [])

    if backlog.get("ready_count") != len(ready):
        errors.append(f"ready_count mismatch: {backlog.get('ready_count')} != {len(ready)}")
    if backlog.get("blocked_count") != len(blocked):
        errors.append(f"blocked_count mismatch: {backlog.get('blocked_count')} != {len(blocked)}")

    seen_ids: set[str] = set()
    duplicate_ids = {item.get("stable_id") for item in dup_audit.get("duplicate_risks", [])}
    ready_by_batch = Counter()
    for index, item in enumerate(ready):
        missing = REQUIRED_READY_FIELDS - set(item)
        if missing:
            errors.append(f"ready[{index}] missing fields: {sorted(missing)}")
        stable_id = item.get("stable_id")
        if stable_id in seen_ids:
            errors.append(f"duplicate ready stable_id: {stable_id}")
        seen_ids.add(stable_id)
        if item.get("counted_entry") is not False:
            errors.append(f"ready {stable_id} must remain counted_entry=false")
        if item.get("duplicate_risk") is not False:
            errors.append(f"ready {stable_id} must not have duplicate_risk=true")
        if item.get("mapping_ready") is not True:
            errors.append(f"ready {stable_id} must have mapping_ready=true")
        if stable_id in duplicate_ids:
            errors.append(f"ready {stable_id} appears in duplicate-risk audit")
        metadata_source = item.get("metadata_source")
        if not metadata_source or not (ROOT / str(metadata_source)).exists():
            errors.append(f"ready {stable_id} metadata_source missing: {metadata_source}")
        thumbnail_plan = item.get("thumbnail_plan")
        if not thumbnail_plan or not (ROOT / str(thumbnail_plan)).exists():
            errors.append(f"ready {stable_id} thumbnail_plan missing: {thumbnail_plan}")
        renderer_candidate = item.get("renderer_candidate")
        if not renderer_candidate or not (ROOT / str(renderer_candidate)).exists():
            errors.append(f"ready {stable_id} renderer_candidate missing: {renderer_candidate}")
        gate = str(item.get("implementation_gate", ""))
        if "render-smoke" not in gate or "Implement reviewed" not in gate:
            errors.append(f"ready {stable_id} implementation_gate must require reviewed mapping and render-smoke")
        ready_by_batch[str(item.get("batch"))] += 1

    if dict(ready_by_batch) != backlog.get("ready_by_batch"):
        errors.append(f"ready_by_batch mismatch: {dict(ready_by_batch)} != {backlog.get('ready_by_batch')}")

    blocked_by_reason = Counter(reason for item in blocked for reason in item.get("blocked_reasons", []))
    if dict(blocked_by_reason) != backlog.get("blocked_by_reason"):
        errors.append(f"blocked_by_reason mismatch: {dict(blocked_by_reason)} != {backlog.get('blocked_by_reason')}")
    for item in blocked:
        if item.get("counted_entry") is not False:
            errors.append(f"blocked {item.get('stable_id')} must remain counted_entry=false")

    summary = {
        "ready_count": len(ready),
        "blocked_count": len(blocked),
        "ready_by_batch": dict(ready_by_batch),
        "blocked_by_reason": dict(blocked_by_reason),
        "errors": errors,
    }
    print(json.dumps(summary, indent=2, sort_keys=True))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
