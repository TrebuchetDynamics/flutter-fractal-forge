import json
from pathlib import Path

from ruamel.yaml import YAML

from scripts.research.academic.coverage import build_coverage


def test_coverage_has_explicit_row_for_each_namespace_identity_without_name_guessing():
    coverage = build_coverage(
        {
            "app": [{"id": "core.mandelbrot", "name": "Mandelbrot"}],
            "registry": [{"id": "mandelbrot", "name": "Mandelbrot"}],
            "reference": [{"id": "f001_mandelbrot", "name": "Mandelbrot"}],
            "planned": [{"id": "core.number_wall", "name": "Number Walls"}],
        }
    )

    assert [(row["namespace"], row["identity"]) for row in coverage["rows"]] == [
        ("app", "core.mandelbrot"),
        ("planned", "core.number_wall"),
        ("reference", "f001_mandelbrot"),
        ("registry", "mandelbrot"),
    ]
    assert all(row["status"] == "gap" for row in coverage["rows"])
    assert all(row["paper_ids"] == [] for row in coverage["rows"])


def test_generated_coverage_exactly_reconciles_repository_identity_namespaces():
    root = Path(__file__).resolve().parents[2]
    coverage = json.loads((root / "research/academic/coverage.json").read_text())
    inventory = json.loads((root / "docs/planning/visual-audit-inventory.json").read_text())
    registry = YAML(typ="safe").load((root / "docs/catalog/fractal_registry.yaml").read_text())["fractals"]
    manifest = json.loads((root / "research/fractals-library/data/fractal_manifest.json").read_text())
    expected = {
        "app": {identity for ids in inventory["explore_ids_by_group"].values() for identity in ids},
        "registry": {row["id"] for row in registry},
        "reference": {row["id"] for row in manifest},
        "planned": {"core.number_wall"},
    }
    actual = {namespace: {row["identity"] for row in coverage["rows"] if row["namespace"] == namespace} for namespace in expected}

    assert actual == expected
    assert coverage["counts"] == {namespace: len(ids) for namespace, ids in sorted(expected.items())}


def test_coverage_accepts_only_explicit_reviewed_alias_mapping():
    coverage = build_coverage(
        {"app": [{"id": "core.demo", "name": "Same title"}], "registry": []},
        reviewed_aliases={"core.demo": "paper-1"},
        papers=[{"paper_id": "paper-1", "title": "Different title"}],
    )

    assert coverage["rows"][0]["paper_ids"] == ["paper-1"]
    assert coverage["rows"][0]["status"] == "metadata_only"
