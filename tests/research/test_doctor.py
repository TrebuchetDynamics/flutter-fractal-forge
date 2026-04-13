import shutil
from pathlib import Path

from scripts.research.doctor.check_registry import DoctorResult, check_registry
from scripts.research.lib.registry import Registry
from scripts.research.migrate.retrofit_registry import retrofit_entries


def _retrofit(path: Path) -> None:
    r = Registry.load(path)
    retrofit_entries(r.entries)
    r.save()


def test_doctor_green_on_retrofitted_registry(tmp_registry):
    _retrofit(tmp_registry)
    result = check_registry(tmp_registry)
    assert result.ok, result.format_errors()


def test_doctor_red_on_un_retrofitted_registry(tmp_registry):
    result = check_registry(tmp_registry)
    assert not result.ok
    assert any("tier" in e or "formula_hash" in e for e in result.errors)


def test_doctor_detects_duplicate_ids(tmp_registry, yaml_rt):
    _retrofit(tmp_registry)
    r = Registry.load(tmp_registry)
    # Duplicate the first entry
    r.entries.append(dict(r.entries[0]))
    r.save()
    result = check_registry(tmp_registry)
    assert not result.ok
    assert any("duplicate" in e.lower() for e in result.errors)


def test_doctor_detects_duplicate_formula_hash(tmp_registry):
    _retrofit(tmp_registry)
    r = Registry.load(tmp_registry)
    # Force a collision: set both entries' formula_hash identical
    r.entries[1]["formula_hash"] = r.entries[0]["formula_hash"]
    r.entries[1]["quality"]["formula_hash"] = r.entries[0]["formula_hash"]
    r.save()
    result = check_registry(tmp_registry)
    assert not result.ok
    assert any("formula_hash collision" in e.lower() or "duplicate formula_hash" in e.lower()
               for e in result.errors)


def test_doctor_summary_includes_counts(tmp_registry):
    _retrofit(tmp_registry)
    result = check_registry(tmp_registry)
    summary = result.format_summary()
    assert "2 entries" in summary or "entries: 2" in summary
