#!/usr/bin/env python3
"""Completion audit for the world-largest fractal catalog objective.

Audits the explicit goal:
- target 5,000-10,000 curated renderable entries
- count formulas/rules, not random presets

This script is stricter than the ledger validator: it maps each requirement to
evidence and reports whether the goal can be called complete.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parent
REPO_ROOT = ROOT.parents[1]
DEFAULT_TARGETS = ROOT / "catalog-targets.json"
DEFAULT_ENTRIES = ROOT / "curated-entry-ledger.live-registry.json"
VALIDATOR = ROOT / "validate_catalog_goal.py"


def load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def run_validator(targets: Path, entries: Path) -> dict[str, Any]:
    command = [
        sys.executable,
        str(VALIDATOR),
        "--targets",
        str(targets),
        "--entries",
        str(entries),
    ]
    completed = subprocess.run(command, check=False, text=True, capture_output=True)
    try:
        payload = json.loads(completed.stdout)
    except json.JSONDecodeError:
        payload = {"summary": {}, "errors": [completed.stdout, completed.stderr]}
    payload["exit_code"] = completed.returncode
    return payload


def checklist_item(name: str, passed: bool, evidence: str, gap: str = "") -> dict[str, Any]:
    return {
        "requirement": name,
        "passed": passed,
        "evidence": evidence,
        "gap": gap,
    }


def audit(targets_path: Path, entries_path: Path) -> dict[str, Any]:
    targets = load_json(targets_path)
    entries_doc = load_json(entries_path)
    entries = entries_doc.get("entries", [])
    validator = run_validator(targets_path, entries_path)
    validator_errors = validator.get("errors", []) or validator.get("summary", {}).get("errors", [])
    summary = validator.get("summary", {})

    counted_entries = [entry for entry in entries if entry.get("counted_entry") is True]
    counted_total = len(counted_entries)
    target_min = int(targets.get("target_totals", {}).get("counted_entry_min", 0))
    target_max = int(targets.get("target_totals", {}).get("counted_entry_max", 0))
    families = {entry.get("family") for entry in counted_entries}
    target_families = {item.get("family") for item in targets.get("counted_entry_targets", [])}

    forbidden_terms = [
        "random seed",
        "camera-only preset",
        "palette-only preset",
        "thumbnail-only variant",
        "renderer implementation detail",
    ]
    forbidden_hits = []
    missing_formula = []
    missing_renderer = []
    missing_thumbnail = []
    missing_provenance = []
    missing_validation = []
    non_promoted_counted = []

    for entry in counted_entries:
        stable_id = entry.get("stable_id", "<unknown>")
        formula = str(entry.get("formula_or_rule", "")).strip().lower()
        if not formula:
            missing_formula.append(stable_id)
        for term in forbidden_terms:
            if term in formula:
                forbidden_hits.append({"stable_id": stable_id, "term": term})
        renderer = str(entry.get("renderer_path", ""))
        if not renderer or renderer == "unassigned" or not (REPO_ROOT / renderer).exists():
            missing_renderer.append(stable_id)
        thumbnail = str(entry.get("thumbnail_plan", ""))
        if not thumbnail or thumbnail == "pending" or not (REPO_ROOT / thumbnail).exists():
            missing_thumbnail.append(stable_id)
        provenance = entry.get("provenance") or {}
        if not provenance.get("source") or not provenance.get("reuse_decision"):
            missing_provenance.append(stable_id)
        validation = entry.get("validation") or {}
        if validation.get("status") not in {"validated", "passed"}:
            missing_validation.append(stable_id)
        if entry.get("ingest_status") != "promoted":
            non_promoted_counted.append(stable_id)

    checklist = [
        checklist_item(
            "Target ledger defines a 5,000-10,000 counted-entry range",
            5000 <= target_min <= 10000 and 5000 <= target_max <= 10000,
            f"{targets_path}: target_min={target_min}, target_max={target_max}",
            "Target totals must be in objective range.",
        ),
        checklist_item(
            "Active counted ledger validates structurally",
            validator.get("exit_code") == 0,
            f"validate_catalog_goal.py exit={validator.get('exit_code')}, summary={summary}",
            f"Validator errors: {validator_errors}",
        ),
        checklist_item(
            "Actual counted entries are between 5,000 and 10,000",
            5000 <= counted_total <= 10000,
            f"{entries_path}: counted_total={counted_total}",
            "Need more promoted renderable formula/rule entries.",
        ),
        checklist_item(
            "Counted entries belong to target families",
            families.issubset(target_families),
            f"families={sorted(str(f) for f in families)}",
            "All counted families must appear in catalog-targets.json.",
        ),
        checklist_item(
            "Every counted entry has formula/rule identity",
            not missing_formula,
            f"missing_formula_count={len(missing_formula)}",
            f"Missing formula/rule IDs: {missing_formula[:20]}",
        ),
        checklist_item(
            "No counted entry is a random preset/camera/palette/thumbnail/renderer-only item",
            not forbidden_hits,
            f"forbidden_hits_count={len(forbidden_hits)}",
            f"Forbidden hits: {forbidden_hits[:20]}",
        ),
        checklist_item(
            "Every counted entry has existing renderer path",
            not missing_renderer,
            f"missing_renderer_count={len(missing_renderer)}",
            f"Missing renderer IDs: {missing_renderer[:20]}",
        ),
        checklist_item(
            "Every counted entry has existing thumbnail or accepted thumbnail plan",
            not missing_thumbnail,
            f"missing_thumbnail_count={len(missing_thumbnail)}",
            f"Missing thumbnail IDs: {missing_thumbnail[:20]}",
        ),
        checklist_item(
            "Every counted entry has provenance and license decision context",
            not missing_provenance,
            f"missing_provenance_count={len(missing_provenance)}",
            f"Missing provenance IDs: {missing_provenance[:20]}",
        ),
        checklist_item(
            "Every counted entry is validated and promoted",
            not missing_validation and not non_promoted_counted,
            f"missing_validation_count={len(missing_validation)}, non_promoted_counted={len(non_promoted_counted)}",
            f"Missing validation IDs: {missing_validation[:20]}, non-promoted IDs: {non_promoted_counted[:20]}",
        ),
    ]

    complete = all(item["passed"] for item in checklist)
    return {
        "objective": "target 5,000-10,000 curated renderable entries; count formulas/rules, not random presets",
        "targets": str(targets_path),
        "entries": str(entries_path),
        "counted_total": counted_total,
        "target_min": target_min,
        "target_max": target_max,
        "complete": complete,
        "checklist": checklist,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--targets", type=Path, default=DEFAULT_TARGETS)
    parser.add_argument("--entries", type=Path, default=DEFAULT_ENTRIES)
    parser.add_argument("--out", type=Path, default=ROOT / "completion-audit.live-registry.json")
    args = parser.parse_args()

    result = audit(args.targets, args.entries)
    args.out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0 if result["complete"] else 1


if __name__ == "__main__":
    sys.exit(main())
