#!/usr/bin/env python3
"""Merge isolated catalog audit batch reports into thumbnail_report.json."""

from __future__ import annotations

import json
import re
import sys
from collections import Counter
from pathlib import Path


LIST_KEYS = [
    "renderMetrics",
    "mathOracle",
    "generated",
    "failed",
    "skipped",
    "qualityWarnings",
    "performance",
    "flutterErrors",
    "launchVisualMetrics",
]


def _max_ratio(metrics: list[dict], key: str) -> float:
    return max((float(metric.get(key, 0) or 0) for metric in metrics), default=0.0)


def _module_id(value: object, context: str) -> str:
    if (not isinstance(value, str) or not value or "," in value
            or any(char.isspace() for char in value)):
        raise ValueError(f"{context}: invalid moduleId {value!r}")
    return value


def _read_report(path: Path) -> dict:
    try:
        data = json.loads(path.read_text())
    except json.JSONDecodeError as error:
        raise ValueError(f"{path}: {error}") from error
    if not isinstance(data, dict):
        raise ValueError(f"{path}: report must be an object")
    return data


def _records(data: dict, key: str, context: str) -> list[dict]:
    records = data.get(key, [])
    if not isinstance(records, list) or any(not isinstance(r, dict) for r in records):
        raise ValueError(f"{context}: {key} must be a list of objects")
    return records


def _unique_ids(records: list[dict], context: str, catalog_ids: dict) -> list[str]:
    ids = []
    for record in records:
        module_id = _module_id(record.get("moduleId"), f"{context} {record.get('reason', '')}")
        if module_id in ids:
            raise ValueError(f"{context}: duplicate moduleId {module_id!r}")
        if "catalogId" in record:
            catalog_id = record["catalogId"]
            if not isinstance(catalog_id, str) or not catalog_id.strip():
                raise ValueError(f"{context}: invalid catalogId for {module_id!r}")
            if module_id in catalog_ids and catalog_ids[module_id] != catalog_id:
                raise ValueError(f"{context}: catalogId mismatch for {module_id!r}")
            catalog_ids[module_id] = catalog_id
        ids.append(module_id)
    return ids


def _same_ids(actual: list[str], expected: list[str], context: str) -> None:
    missing = sorted(set(expected) - set(actual))
    unexpected = sorted(set(actual) - set(expected))
    if missing or unexpected:
        raise ValueError(f"{context}: missing IDs={missing}, unexpected IDs={unexpected}")


def _selection(data: dict, context: str, catalog_ids: dict) -> list[str]:
    ids = _unique_ids(_records(data, "selectedEntries", context), context, catalog_ids)
    if not ids:
        raise ValueError(f"{context}: selectedEntries must be nonempty")
    if "selectedCount" in data and (
        type(data["selectedCount"]) is not int or data["selectedCount"] != len(ids)
    ):
        raise ValueError(f"{context}: selectedCount does not match selectedEntries")
    return ids


def _validate_report(data: dict, expected: list[str], context: str, catalog_ids: dict) -> None:
    selected = _selection(data, context, catalog_ids)
    _same_ids(selected, expected, f"{context} selectedEntries")
    records = {key: _records(data, key, context) for key in LIST_KEYS}
    outcomes = _unique_ids(
        records["generated"] + records["failed"] + records["skipped"],
        f"{context} outcomes", catalog_ids,
    )
    _same_ids(outcomes, expected, f"{context} outcomes")
    metrics = _unique_ids(records["renderMetrics"], f"{context} renderMetrics", catalog_ids)
    _same_ids(metrics, [r["moduleId"] for r in records["generated"]],
              f"{context} generated/renderMetrics")
    # Diagnostics can repeat a module (for example Flutter errors during teardown).
    for key in LIST_KEYS:
        for record in records[key]:
            ids = _unique_ids([record], f"{context} {key}", catalog_ids)
            if ids[0] not in expected:
                raise ValueError(f"{context} {key}: unexpected moduleId {ids[0]!r}")
    summary = data.get("renderHealthSummary", {})
    if not isinstance(summary, dict) or not isinstance(summary.get("thresholds", {}), dict):
        raise ValueError(f"{context}: invalid renderHealthSummary/thresholds")


def _validated_reports(chunks_dir: Path, allow_missing: bool) -> tuple[dict, list[Path], list[dict]]:
    catalog = _read_report(chunks_dir / "catalog.json")
    catalog_ids: dict[str, str] = {}
    selected = _selection(catalog, "catalog.json", catalog_ids)
    lines = (chunks_dir / "batches.txt").read_text().splitlines()
    if not lines:
        raise ValueError("batches.txt: empty batch plan")
    plan = [line.split(",") for line in lines]
    planned = _unique_ids(
        [{"moduleId": module_id} for batch in plan for module_id in batch],
        "batches.txt", {},
    )
    _same_ids(planned, selected, "batches.txt/catalog.json")

    indexed = {}
    for path in chunks_dir.glob("batch_*.json"):
        match = re.fullmatch(r"batch_(0|[1-9][0-9]*)(?:_(0|[1-9][0-9]*))?\.json", path.name)
        if not match:
            raise ValueError(f"unexpected batch report name: {path.name}")
        batch = int(match[1])
        retry = int(match[2]) if match[2] is not None else None
        if batch >= len(plan):
            raise ValueError(f"unexpected batch report: {path.name}")
        indexed.setdefault(batch, {})[retry] = path

    chunks, reports = [], []
    for batch, expected in enumerate(plan):
        evidence = indexed.get(batch, {})
        if not evidence:
            if allow_missing:
                continue
            raise ValueError(f"batch_{batch}: missing batch evidence")
        if None in evidence:
            if len(evidence) != 1:
                raise ValueError(f"batch_{batch}: ambiguous aggregate-plus-retry evidence")
            selections = [(evidence[None], expected)]
        else:
            if set(evidence) != set(range(len(expected))):
                raise ValueError(f"batch_{batch}: incomplete or extra indexed retry evidence")
            selections = [(evidence[i], [module_id]) for i, module_id in enumerate(expected)]
        for path, selection in selections:
            data = _read_report(path)
            _validate_report(data, selection, path.name, catalog_ids)
            chunks.append(path)
            reports.append(data)
    return catalog, chunks, reports


def main() -> int:
    validate_existing = len(sys.argv) == 5 and sys.argv[4] == "--validate-existing"
    if len(sys.argv) != 4 and not validate_existing:
        print(
            "usage: merge_catalog_audit_batches.py <chunks_dir> <out_report.json> <batch_size> "
            "[--validate-existing]",
            file=sys.stderr,
        )
        return 2

    chunks_dir = Path(sys.argv[1])
    out = Path(sys.argv[2])
    batch_size = int(sys.argv[3])
    catalog, chunks, reports = _validated_reports(chunks_dir, allow_missing=validate_existing)
    if validate_existing:
        return 0

    merged = dict(catalog)
    for key in LIST_KEYS:
        merged[key] = [item for report in reports for item in report.get(key, [])]
    merged["selectedCount"] = len(catalog.get("selectedEntries", []))
    merged["isolatedBatches"] = True
    merged["batchSize"] = batch_size
    merged["batchReports"] = [str(path) for path in chunks]

    metrics = merged.get("renderMetrics", [])
    verdicts = Counter(metric.get("verdict") for metric in metrics)
    thresholds = {}
    for report in reports:
        thresholds = report.get("renderHealthSummary", {}).get("thresholds") or thresholds

    merged["renderHealthSummary"] = {
        "selectedCount": merged["selectedCount"],
        "evaluated": len(metrics),
        "pass": verdicts.get("pass", 0),
        "allBlack": verdicts.get("all-black", 0),
        "mostlyBlack": verdicts.get("mostly-black", 0),
        "transparent": verdicts.get("transparent", 0),
        "lowColor": verdicts.get("low-color", 0),
        "flat": verdicts.get("flat", 0),
        "blank": verdicts.get("blank", 0),
        "maxBlackPixelRatio": _max_ratio(metrics, "blackPixelRatio"),
        "maxTransparentPixelRatio": _max_ratio(metrics, "transparentPixelRatio"),
        "thresholds": thresholds,
    }

    oracle = merged.get("mathOracle", [])
    oracle_counts = Counter(item.get("verdict") for item in oracle)
    merged["mathOracleSummary"] = {
        "selectedCount": merged["selectedCount"],
        "evaluated": len(oracle),
        "pass": oracle_counts.get("pass", 0),
        "fail": oracle_counts.get("fail", 0),
        "skipped": oracle_counts.get("skipped", 0),
    }

    out.write_text(json.dumps(merged, indent=2) + "\n")
    print(f"[fractal-audit] merged {len(chunks)} batches -> {out}")
    print(
        "[fractal-audit] generated={generated} failed={failed} "
        "skipped={skipped} warnings={warnings}".format(
            generated=len(merged.get("generated", [])),
            failed=len(merged.get("failed", [])),
            skipped=len(merged.get("skipped", [])),
            warnings=len(merged.get("qualityWarnings", [])),
        )
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, TypeError) as error:
        raise SystemExit(f"catalog audit coverage: {error}") from None
