#!/usr/bin/env python3
"""Run or print thumbnail-generation batches for live-registry blockers.

Dry-run by default. Use --update-assets to write bundled thumbnails under
assets/catalog_thumbs via UPDATE_CATALOG_THUMBS=true.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
ROOT = REPO_ROOT
WORKLIST = ROOT / "research/worlds-largest-fractal-catalog/thumbnail-worklist.live-registry.json"
RECEIPTS = ROOT / "research/worlds-largest-fractal-catalog/thumbnail-batch-receipts.jsonl"


def load_worklist(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def batch_by_index(worklist: dict, index: int) -> dict:
    batches = worklist.get("batches", [])
    if index < 0 or index >= len(batches):
        raise SystemExit(f"batch index {index} out of range 0..{len(batches)-1}")
    return batches[index]


def command_for(batch: dict, update_assets: bool, strict: bool) -> tuple[dict[str, str], list[str]]:
    env = {
        "CATALOG_THUMB_ONLY": ",".join(batch["moduleIds"]),
    }
    if update_assets:
        env["UPDATE_CATALOG_THUMBS"] = "true"
    if strict:
        env["STRICT_CATALOG_THUMBS"] = "true"
    command = [
        "/home/xel/flutter/bin/flutter",
        "test",
        "integration_test/catalog/generate_gpu_thumbnails_test.dart",
        "-d",
        "linux",
        "--dart-define=FORCE_GPU_RENDER=true",
    ]
    return env, command


def append_receipt(receipt: dict) -> None:
    RECEIPTS.parent.mkdir(parents=True, exist_ok=True)
    with RECEIPTS.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(receipt, sort_keys=True) + "\n")


def read_thumbnail_report(update_assets: bool) -> dict[str, Any]:
    report_path = (
        REPO_ROOT / "assets/catalog_thumbs/thumbnail_report.json"
        if update_assets
        else REPO_ROOT / "build/test_output/catalog_thumbs_seeded/thumbnail_report.json"
    )
    if not report_path.exists():
        return {"reportPath": str(report_path), "reportFound": False}
    data = json.loads(report_path.read_text(encoding="utf-8"))
    return {
        "reportPath": str(report_path),
        "reportFound": True,
        "selectedCount": data.get("selectedCount"),
        "generatedCount": len(data.get("generated", [])),
        "failedCount": len(data.get("failed", [])),
        "skippedCount": len(data.get("skipped", [])),
        "qualityWarningCount": len(data.get("qualityWarnings", [])),
        "firstSkip": (data.get("skipped") or [None])[0],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--worklist", type=Path, default=WORKLIST)
    parser.add_argument("--batch", type=int, default=0)
    parser.add_argument("--update-assets", action="store_true")
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("--dry-run", action="store_true", default=True)
    parser.add_argument("--execute", action="store_true", help="Actually run the batch. Still requires --update-assets to write bundled assets.")
    args = parser.parse_args()

    worklist = load_worklist(args.worklist)
    batch = batch_by_index(worklist, args.batch)
    env_delta, command = command_for(batch, update_assets=args.update_assets, strict=args.strict)
    shell_prefix = " ".join(f"{key}={value}" for key, value in env_delta.items())
    printable = f"{shell_prefix} {' '.join(command)}"

    receipt = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "batch": args.batch,
        "offset": batch["offset"],
        "limit": batch["limit"],
        "moduleIds": batch["moduleIds"],
        "updateAssets": args.update_assets,
        "strict": args.strict,
        "command": printable,
        "executed": bool(args.execute),
    }

    if not args.execute:
        receipt["result"] = "dry-run"
        print(json.dumps(receipt, indent=2))
        return 0

    full_env = os.environ.copy()
    full_env.update(env_delta)
    completed = subprocess.run(command, cwd=ROOT, env=full_env, text=True)
    receipt["exitCode"] = completed.returncode
    receipt["thumbnailReport"] = read_thumbnail_report(args.update_assets)
    report = receipt["thumbnailReport"]
    generated_count = int(report.get("generatedCount", 0)) if isinstance(report, dict) else 0
    receipt["result"] = "passed" if completed.returncode == 0 and generated_count > 0 else "no-output" if completed.returncode == 0 else "failed"
    append_receipt(receipt)
    print(json.dumps(receipt, indent=2))
    return completed.returncode


if __name__ == "__main__":
    sys.exit(main())
