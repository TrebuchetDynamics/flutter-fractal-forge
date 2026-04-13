from pathlib import Path

import pytest

from scripts.research.lib.registry import Registry
from scripts.research.lib.schema_lint import lint
from scripts.research.migrate.retrofit_registry import retrofit_entries, run_retrofit


def test_retrofit_adds_tier_from_implemented(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    for entry in r.entries:
        assert entry["tier"] == ("implemented" if entry.get("implemented") else "reference")


def test_retrofit_adds_formula_hash(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    for entry in r.entries:
        assert entry["formula_hash"].startswith("sha256:")
        assert len(entry["formula_hash"]) == len("sha256:") + 64


def test_retrofit_is_idempotent(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    first = [dict(e) for e in r.entries]
    retrofit_entries(r.entries)
    second = [dict(e) for e in r.entries]
    assert first == second


def test_retrofit_adds_quality_block(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    for entry in r.entries:
        q = entry["quality"]
        assert q["formula_hash"] == entry["formula_hash"]
        assert q["confidence"] == 1.0  # legacy entries are trusted
        assert q["citation_health"]["status"] == "unchecked"


def test_retrofit_preserves_legacy_fields(tmp_registry):
    r = Registry.load(tmp_registry)
    before = [dict(e) for e in r.entries]
    retrofit_entries(r.entries)
    for before_entry, after_entry in zip(before, r.entries):
        for k, v in before_entry.items():
            assert after_entry[k] == v, f"legacy field {k} changed"


def test_retrofitted_entries_pass_registry_entry_schema(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    for entry in r.entries:
        lint("registry_entry", entry)


def test_run_retrofit_writes_file(tmp_path, yaml_rt):
    import shutil
    src = Path(__file__).resolve().parents[2] / "docs" / "catalog" / "fractal_registry.yaml"
    dst = tmp_path / "fractal_registry.yaml"
    shutil.copy(src, dst)

    rc = run_retrofit(repo_root=tmp_path.parent, registry_path=dst, dry_run=False)
    assert rc == 0

    r = Registry.load(dst)
    assert all("tier" in e for e in r.entries)
    assert all("formula_hash" in e for e in r.entries)


def test_run_retrofit_dry_run_does_not_write(tmp_registry):
    before = tmp_registry.read_text()
    rc = run_retrofit(repo_root=tmp_registry.parent.parent, registry_path=tmp_registry, dry_run=True)
    assert rc == 0
    assert tmp_registry.read_text() == before
