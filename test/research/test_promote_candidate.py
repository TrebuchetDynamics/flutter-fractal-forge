from pathlib import Path

import pytest
from ruamel.yaml import YAML

from scripts.research.admit.promote_candidate import promote_batch, _next_id, _build_registry_entry
from scripts.research.canonicalize.taxonomy_classifier import classify
from scripts.research.lib.registry import Registry


def _write_yaml(path, data):
    y = YAML()
    y.dump(data, path)


def _candidate(cid="ct_1", name="Test Mandelbrot", update="z = z**2 + c"):
    return {
        "candidate_id": cid,
        "source": {"type": "manual", "url": "https://example.com/x", "fetched_at": "2026-04-12T00:00:00Z"},
        "proposed_name": name,
        "formula_ast": {"iteration_type": "escape_time", "variables": ["z", "c"], "update": update, "init": "z = 0"},
        "params": {"iterations": {"default": 500, "range": [1, 10000]}, "bailout": {"default": 2.0, "range": [1.0, 10.0]}, "power": {"default": 2.0, "range": [1.0, 12.0]}},
        "presets": [{"id": "zoom_a", "name": "Zoom A", "params": {"zoom": 1.0}}],
        "variants": [],
        "references": [{"url": "https://example.com/ref"}],
        "quality": {"formula_hash": "sha256:" + "0" * 64, "confidence": 0.9},
    }


def test_next_id_starts_at_1_for_empty_registry():
    class R: entries = []
    assert _next_id(R(), "Foo Bar").startswith("f0001_")


def test_next_id_increments():
    class R: entries = [{"id": "f0003_x"}, {"id": "f0001_y"}]
    assert _next_id(R(), "New").startswith("f0004_")


def test_build_registry_entry_has_required_fields():
    cand = _candidate()
    cls = classify(cand["formula_ast"])
    entry = _build_registry_entry(cand, "f0001_test", cls)
    for k in ("id", "name", "category", "tier", "formula_hash", "quality"):
        assert k in entry


def test_promote_batch_admits_new(tmp_path, tmp_registry):
    # Set up batch + decisions
    batch_id = "b_test"
    repo = tmp_path / "repo"
    repo.mkdir()
    (repo / "docs" / "catalog").mkdir(parents=True)
    import shutil
    shutil.copy(tmp_registry, repo / "docs" / "catalog" / "fractal_registry.yaml")
    (repo / "research" / "candidates" / batch_id).mkdir(parents=True)
    (repo / "research" / "decisions").mkdir(parents=True)
    (repo / "assets" / "catalog_thumbs").mkdir(parents=True)

    cand = _candidate(cid="ct_unique", name="Unique Fractal", update="z = z**9 + c")
    _write_yaml(repo / "research" / "candidates" / batch_id / "ct_unique.yaml", cand)
    _write_yaml(
        repo / "research" / "decisions" / f"{batch_id}.yaml",
        {"batch_id": batch_id, "decisions": {"ct_unique": {"action": "approve_new"}}},
    )

    report = promote_batch(batch_id, repo)
    assert len(report.admitted) == 1
    assert report.admitted[0].startswith("f")
    assert report.failed == []

    # Registry grew
    reg = Registry.load(repo / "docs" / "catalog" / "fractal_registry.yaml")
    assert any(e["id"].startswith("f") and e.get("name") == "Unique Fractal" for e in reg.entries)

    # Dart files emitted
    new_id = report.admitted[0]
    module_glob = list((repo / "lib" / "core" / "modules").rglob(f"{new_id}_module.dart"))
    assert len(module_glob) == 1

    # Thumbnail rendered
    thumb = repo / "assets" / "catalog_thumbs" / f"{new_id}.png"
    assert thumb.exists()


def test_promote_batch_handles_missing_candidate_file(tmp_path, tmp_registry):
    batch_id = "b_test2"
    repo = tmp_path / "repo"
    repo.mkdir()
    (repo / "docs" / "catalog").mkdir(parents=True)
    import shutil
    shutil.copy(tmp_registry, repo / "docs" / "catalog" / "fractal_registry.yaml")
    (repo / "research" / "candidates" / batch_id).mkdir(parents=True)
    (repo / "research" / "decisions").mkdir(parents=True)

    _write_yaml(
        repo / "research" / "decisions" / f"{batch_id}.yaml",
        {"batch_id": batch_id, "decisions": {"ct_ghost": {"action": "approve_new"}}},
    )

    report = promote_batch(batch_id, repo)
    assert len(report.admitted) == 0
    assert len(report.failed) == 1
    assert "ct_ghost" == report.failed[0][0]
