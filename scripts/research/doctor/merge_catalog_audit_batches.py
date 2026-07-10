#!/usr/bin/env python3
"""Merge isolated catalog audit batch reports into thumbnail_report.json."""

from __future__ import annotations

import json
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


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: merge_catalog_audit_batches.py <chunks_dir> <out_report.json> <batch_size>",
            file=sys.stderr,
        )
        return 2

    chunks_dir = Path(sys.argv[1])
    out = Path(sys.argv[2])
    batch_size = int(sys.argv[3])
    catalog = json.loads((chunks_dir / "catalog.json").read_text())
    chunks = sorted(
        chunks_dir.glob("batch_*.json"),
        key=lambda p: int(p.stem.split("_")[1]),
    )
    reports = [json.loads(path.read_text()) for path in chunks]
    if not reports:
        raise SystemExit("no batch reports produced")

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
    raise SystemExit(main())
