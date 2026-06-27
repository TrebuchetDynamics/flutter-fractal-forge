"""Stage B end-to-end test: candidate YAML → full admission pipeline."""
from pathlib import Path

from ruamel.yaml import YAML

from scripts.research.admit.promote_candidate import promote_batch
from scripts.research.lib.registry import Registry


def test_e2e_full_admission_pipeline(tmp_path, tmp_registry):
    repo = tmp_path / "repo"
    (repo / "docs" / "catalog").mkdir(parents=True)
    (repo / "research" / "candidates" / "e2e").mkdir(parents=True)
    (repo / "research" / "decisions").mkdir(parents=True)
    (repo / "assets" / "catalog_thumbs").mkdir(parents=True)

    import shutil
    shutil.copy(tmp_registry, repo / "docs" / "catalog" / "fractal_registry.yaml")

    y = YAML()
    candidate = {
        "candidate_id": "ct_e2e",
        "source": {"type": "manual", "url": "https://example.com/x", "fetched_at": "2026-04-13T00:00:00Z"},
        "proposed_name": "E2E Test Fractal",
        "aliases": ["e2e-test"],
        "formula_ast": {
            "iteration_type": "escape_time",
            "variables": ["z", "c"],
            "update": "z = z**11 + c",
            "init": "z = 0",
        },
        "params": {
            "iterations": {"default": 400, "range": [1, 10000]},
            "bailout": {"default": 2.5, "range": [1.0, 10.0]},
            "power": {"default": 11.0, "range": [1.0, 20.0]},
        },
        "presets": [{"id": "default_view", "name": "Default View", "params": {"zoom": 1.0}}],
        "variants": [],
        "references": [{"url": "https://example.com/ref"}],
        "quality": {"formula_hash": "sha256:" + "e" * 64, "confidence": 0.9},
    }
    y.dump(candidate, repo / "research" / "candidates" / "e2e" / "ct_e2e.yaml")
    y.dump(
        {"batch_id": "e2e", "decisions": {"ct_e2e": {"action": "approve_new"}}},
        repo / "research" / "decisions" / "e2e.yaml",
    )

    report = promote_batch("e2e", repo)

    # Done-definition checks
    assert len(report.admitted) == 1, f"admission failed: {report.failed}"
    new_id = report.admitted[0]

    # 1. Registry has new entry
    reg = Registry.load(repo / "docs" / "catalog" / "fractal_registry.yaml")
    new_entry = next((e for e in reg.entries if e["id"] == new_id), None)
    assert new_entry is not None
    assert new_entry["tier"] == "reference"
    assert new_entry["formula_hash"].startswith("sha256:")
    assert "quality" in new_entry

    # 2. Dart module file emitted
    module_files = list((repo / "lib" / "core" / "modules").rglob(f"{new_id}_module.dart"))
    assert len(module_files) == 1
    module_content = module_files[0].read_text()
    assert "extends EscapeTimeModule" in module_content
    assert "GENERATED" in module_content

    # 3. Dart presets/variants/metadata files
    base = module_files[0].parent
    for suffix in ("_presets.dart", "_variants.dart", "_metadata.dart"):
        assert (base / f"{new_id}{suffix}").exists()

    # 4. Per-module test scaffolds are intentionally not emitted; the app repo
    # uses a consolidated generated module contract test instead.
    test_files = list((repo / "test" / "modules").rglob(f"{new_id}_module_test.dart"))
    assert test_files == []

    # 5. Thumbnail
    thumb = repo / "assets" / "catalog_thumbs" / f"{new_id}.png"
    assert thumb.exists()
    assert thumb.stat().st_size > 0


def test_e2e_forge_doctor_stays_green_after_admission(tmp_path, tmp_registry):
    from scripts.research.doctor.check_registry import check_registry

    # Use the same setup as the previous test
    repo = tmp_path / "repo"
    (repo / "docs" / "catalog").mkdir(parents=True)
    (repo / "research" / "candidates" / "e2e").mkdir(parents=True)
    (repo / "research" / "decisions").mkdir(parents=True)
    (repo / "assets" / "catalog_thumbs").mkdir(parents=True)

    import shutil
    shutil.copy(tmp_registry, repo / "docs" / "catalog" / "fractal_registry.yaml")

    # Retrofit first so doctor will pass baseline
    from scripts.research.migrate.retrofit_registry import retrofit_entries
    reg = Registry.load(repo / "docs" / "catalog" / "fractal_registry.yaml")
    retrofit_entries(reg.entries)
    reg.save()

    y = YAML()
    candidate = {
        "candidate_id": "ct_doctor_test",
        "source": {"type": "manual", "url": "https://example.com/x", "fetched_at": "2026-04-13T00:00:00Z"},
        "proposed_name": "Doctor Test",
        "aliases": [],
        "formula_ast": {"iteration_type": "escape_time", "variables": ["z", "c"], "update": "z = z**13 + c", "init": "z = 0"},
        "params": {"iterations": {"default": 400}, "bailout": {"default": 2.5}, "power": {"default": 13.0}},
        "presets": [],
        "variants": [],
        "references": [{"url": "https://example.com/ref"}],
        "quality": {"formula_hash": "sha256:" + "d" * 64, "confidence": 0.9},
    }
    y.dump(candidate, repo / "research" / "candidates" / "e2e" / "ct_doctor_test.yaml")
    y.dump(
        {"batch_id": "e2e", "decisions": {"ct_doctor_test": {"action": "approve_new"}}},
        repo / "research" / "decisions" / "e2e.yaml",
    )

    promote_batch("e2e", repo)
    result = check_registry(repo / "docs" / "catalog" / "fractal_registry.yaml")
    assert result.ok, result.format_errors()
