#!/usr/bin/env python3
"""Validate the checked-in VIS-005 reconciliation inventory."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
INVENTORY = ROOT / "docs/planning/visual-audit-inventory.json"
MANIFEST = ROOT / "research/fractals-library/data/fractal_manifest.json"


def main() -> None:
    inventory = json.loads(INVENTORY.read_text())
    manifest = json.loads(MANIFEST.read_text())
    rows = inventory["rows"]
    ids = [row["id"] for row in rows]
    assert len(ids) == len(set(ids)), "duplicate inventory IDs"
    assert len({item["id"] for item in manifest}) == 200

    explore = [row for row in rows if row["source"] == "Explore"]
    research = [row for row in rows if row["source"] == "research_manifest"]
    assert {row["id"] for row in research} == {item["id"] for item in manifest}
    assert len(research) == 200
    assert len({row["id"] for row in explore}) == len(explore)

    by_group = inventory["explore_ids_by_group"]
    assert set(by_group) == {"core", "performance"}
    for group in by_group:
        selected = [row for row in explore if row["group"] == group]
        assert {row["id"] for row in selected} == set(by_group[group])
        assert all(row["status"] == "renderer_registered" for row in selected)
    assert len(explore) == inventory["counts"]["explore_core"] + inventory["counts"]["explore_performance"]
    assert len(research) == inventory["counts"]["manifest"] == 200

    for row in rows:
        assert row["status"] and row["references"], row["id"]
        assert all(reference.strip() for reference in row["references"])
        assert all(
            (ROOT / reference.rstrip("/")).exists()
            for reference in row["references"]
        ), row["id"]
        if row["source"] == "research_manifest":
            assert row["status"] == "missing_app_renderer"
            assert row["module_id"] is None and row["shader"] is None
        elif row["source"] == "Explore":
            assert row["status"] == "renderer_registered"
            assert row["id"] == f"{row['group']}.{row['source_id']}"
            assert row["module_id"] == row["source_id"]
            assert row["module_id"] and row["shader"]
            assert (ROOT / row["shader"]).is_file(), row["shader"]
        else:
            raise AssertionError(f"unknown inventory source: {row['source']}")
    print(
        f"OK: {len(explore)} Explore IDs "
        f"(core={inventory['counts']['explore_core']}, "
        f"performance={inventory['counts']['explore_performance']}) + "
        f"{len(research)} manifest IDs; {len(ids)} unique rows"
    )


if __name__ == "__main__":
    main()
