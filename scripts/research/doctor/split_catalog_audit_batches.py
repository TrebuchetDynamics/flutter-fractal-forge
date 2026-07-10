#!/usr/bin/env python3
"""Split a catalog audit list-only report into module-id batches."""

from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: split_catalog_audit_batches.py <report.json> <out.txt> <batch_size>",
            file=sys.stderr,
        )
        return 2

    report_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])
    batch_size = int(sys.argv[3])
    entries = json.loads(report_path.read_text()).get("selectedEntries", [])
    if batch_size <= 0:
        batch_size = len(entries) or 1

    with out_path.open("w") as f:
        for i in range(0, len(entries), batch_size):
            f.write(",".join(e["moduleId"] for e in entries[i : i + batch_size]) + "\n")

    print(f"[fractal-audit] catalog entries={len(entries)} batch_size={batch_size}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
