#!/usr/bin/env python3
"""Validate the world-largest fractal catalog target ledger.

This is intentionally dependency-free. It validates the local target ledger and,
when present, a curated entry ledger. Counted entries must be promoted formula /
rule identities, not presets or random seeds.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parent
REPO_ROOT = ROOT.parents[1]
DEFAULT_TARGETS = ROOT / "catalog-targets.json"
DEFAULT_ENTRIES = ROOT / "curated-entry-ledger.seed.json"

FORBIDDEN_COUNT_TERMS = (
    "random seed",
    "camera-only preset",
    "palette-only preset",
    "thumbnail-only variant",
    "renderer implementation detail",
)
REQUIRED_COUNTED_FIELDS = (
    "stable_id",
    "display_name",
    "family",
    "mathematical_identity_type",
    "formula_or_rule",
    "renderer_path",
    "provenance",
    "license_context",
    "thumbnail_plan",
    "validation",
    "accessibility_label",
)
VALID_ID = re.compile(r"^[a-z0-9][a-z0-9_\-]*$")


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def validate_targets(path: Path) -> list[str]:
    data = load_json(path)
    errors: list[str] = []
    targets = data.get("counted_entry_targets", [])
    if not targets:
        errors.append("catalog-targets.json has no counted_entry_targets")
        return errors

    min_total = sum(int(item.get("target_min", 0)) for item in targets)
    max_total = sum(int(item.get("target_max", 0)) for item in targets)
    recorded = data.get("target_totals", {})
    if recorded.get("counted_entry_min") != min_total:
        errors.append(
            f"target min mismatch: recorded={recorded.get('counted_entry_min')} computed={min_total}"
        )
    if recorded.get("counted_entry_max") != max_total:
        errors.append(
            f"target max mismatch: recorded={recorded.get('counted_entry_max')} computed={max_total}"
        )
    if not (5000 <= min_total <= 10000):
        errors.append(f"target minimum outside objective range: {min_total}")
    if not (5000 <= max_total <= 10000):
        errors.append(f"target maximum outside objective range: {max_total}")

    for item in targets:
        family = item.get("family", "<unknown>")
        if int(item.get("target_min", 0)) > int(item.get("target_max", 0)):
            errors.append(f"{family}: target_min > target_max")
        count_rule = str(item.get("count_rule", "")).lower()
        if "random" in count_rule and "not random" not in count_rule:
            errors.append(f"{family}: count_rule may allow random counting: {count_rule}")
        if "preset" in count_rule and "not random" not in count_rule:
            errors.append(f"{family}: count_rule may count presets: {count_rule}")
    return errors


def validate_entries(path: Path, target_families: set[str]) -> tuple[list[str], dict[str, Any]]:
    if not path.exists():
        return [], {"entry_ledger_present": False, "counted_total": 0}

    data = load_json(path)
    entries = data.get("entries", [])
    errors: list[str] = []
    seen_ids: set[str] = set()
    counted_by_family: Counter[str] = Counter()
    counted_total = 0

    for index, entry in enumerate(entries):
        label = entry.get("stable_id", f"entry[{index}]")
        stable_id = entry.get("stable_id")
        if not isinstance(stable_id, str) or not VALID_ID.match(stable_id):
            errors.append(f"{label}: invalid stable_id")
        elif stable_id in seen_ids:
            errors.append(f"{label}: duplicate stable_id")
        else:
            seen_ids.add(stable_id)

        counted = bool(entry.get("counted_entry"))
        if counted:
            counted_total += 1
            family = str(entry.get("family", "<missing>"))
            counted_by_family[family] += 1
            if family not in target_families:
                errors.append(f"{label}: family {family!r} is not in catalog-targets.json")
            if entry.get("ingest_status") != "promoted":
                errors.append(f"{label}: counted entries must have ingest_status=promoted")
            for field in REQUIRED_COUNTED_FIELDS:
                if not entry.get(field):
                    errors.append(f"{label}: counted entry missing {field}")
            formula = str(entry.get("formula_or_rule", "")).strip().lower()
            if not formula:
                errors.append(f"{label}: counted entry has empty formula_or_rule")
            for forbidden in FORBIDDEN_COUNT_TERMS:
                if forbidden in formula:
                    errors.append(f"{label}: formula_or_rule contains forbidden count term {forbidden!r}")
            renderer_path = str(entry.get("renderer_path", ""))
            if renderer_path and renderer_path != "unassigned" and not (REPO_ROOT / renderer_path).exists():
                errors.append(f"{label}: renderer_path does not exist: {renderer_path}")
            thumbnail_plan = str(entry.get("thumbnail_plan", ""))
            if thumbnail_plan and thumbnail_plan != "pending" and not (REPO_ROOT / thumbnail_plan).exists():
                errors.append(f"{label}: thumbnail_plan does not exist: {thumbnail_plan}")
            provenance = entry.get("provenance") or {}
            if not provenance.get("source") or not provenance.get("reuse_decision"):
                errors.append(f"{label}: counted entry missing provenance source/reuse_decision")
            source = str(provenance.get("source", ""))
            if source and not source.startswith(("http://", "https://", "DOI:")) and not (REPO_ROOT / source).exists():
                errors.append(f"{label}: provenance source path does not exist: {source}")
            validation = entry.get("validation") or {}
            if validation.get("status") not in {"validated", "passed"}:
                errors.append(f"{label}: counted entry validation status is not validated/passed")

    summary = {
        "entry_ledger_present": True,
        "entries_total": len(entries),
        "counted_total": counted_total,
        "counted_by_family": dict(sorted(counted_by_family.items())),
    }
    return errors, summary


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--targets", type=Path, default=DEFAULT_TARGETS)
    parser.add_argument("--entries", type=Path, default=DEFAULT_ENTRIES)
    parser.add_argument("--require-objective-complete", action="store_true")
    args = parser.parse_args()

    target_data = load_json(args.targets)
    target_families = {str(item.get("family")) for item in target_data.get("counted_entry_targets", [])}
    errors = validate_targets(args.targets)
    entry_errors, summary = validate_entries(args.entries, target_families)
    errors.extend(entry_errors)

    counted_total = int(summary.get("counted_total", 0))
    if args.require_objective_complete and not (5000 <= counted_total <= 10000):
        errors.append(
            f"objective incomplete: counted_total={counted_total}, required 5000-10000"
        )

    print(json.dumps({"summary": summary, "errors": errors}, indent=2, sort_keys=True))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
