import shutil
from pathlib import Path

import pytest

from scripts.research import forge
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


def test_doctor_passes_on_real_registry_after_retrofit(tmp_path):
    """Copy the real registry, retrofit it, confirm doctor passes."""
    import shutil
    src = Path(__file__).resolve().parents[2] / "docs" / "catalog" / "fractal_registry.yaml"
    dst = tmp_path / "fractal_registry.yaml"
    shutil.copy(src, dst)

    _retrofit(dst)
    result = check_registry(dst)
    assert result.ok, result.format_errors()
    assert result.entry_count >= 300  # we know there are ~370 entries


@pytest.mark.parametrize(("content", "diagnostic"), [
    (b"[]\n", "expected mapping"),
    (b"42\n", "expected mapping"),
    (b"fractals\n", "expected mapping"),
    (b"", "expected mapping"),
    (b"{}\n", "missing"),
    (b"fractals: {}\n", "expected list"),
    (b'fractals: ""\n', "expected list"),
    (b"fractals: null\n", "expected list"),
    (b"fractals: 42\n", "expected list"),
    (b"fractals: [\n", "unreadable"),
    (b"\xff", "unreadable"),
    (None, "unreadable"),
    ("directory", "unreadable"),
    (b"fractals: []\n", None),
])
def test_doctor_validates_input_read_only(tmp_path, monkeypatch, capsys, content, diagnostic):
    path = tmp_path / "docs/catalog/fractal_registry.yaml"
    path.parent.mkdir(parents=True)
    if isinstance(content, bytes):
        path.write_bytes(content)
    elif content == "directory":
        path.mkdir()
    before = {p: p.read_bytes() for p in tmp_path.rglob("*") if p.is_file()}
    paths_before = set(tmp_path.rglob("*"))
    monkeypatch.setattr(forge, "REPO_ROOT", tmp_path)

    result = check_registry(path)
    assert result.ok is (diagnostic is None)
    assert result.entry_count == 0
    assert forge.main(["doctor"]) == (1 if diagnostic else 0)
    output = capsys.readouterr().out
    assert ("FAIL" if diagnostic else "OK") in output
    if diagnostic:
        assert str(path) in result.format_errors()
        assert diagnostic in result.format_errors()
        assert diagnostic in output
    assert set(tmp_path.rglob("*")) == paths_before
    assert {p: p.read_bytes() for p in tmp_path.rglob("*") if p.is_file()} == before


@pytest.mark.parametrize(("field", "value"), [
    (None, None), (None, "invalid"), (None, 42), (None, []),
    ("quality", "invalid"), ("quality", []), ("quality", None),
    ("quality", {"formula_hash": []}),
    ("id", []), ("id", {}),
    ("formula_hash", []), ("formula_hash", {}),
])
def test_doctor_invalid_entries_preserve_valid_invariants(
    tmp_registry, tmp_path, yaml_rt, monkeypatch, capsys, field, value,
):
    _retrofit(tmp_registry)
    valid = Registry.load(tmp_registry).entries[0]
    invalid = dict(valid, **{field: value}) if field else value
    path = tmp_path / "docs/catalog/fractal_registry.yaml"
    path.parent.mkdir(parents=True)
    with path.open("w") as stream:
        yaml_rt.dump({"fractals": [valid, dict(valid), invalid]}, stream)
    before = {p: p.read_bytes() for p in tmp_path.rglob("*") if p.is_file()}
    paths_before = set(tmp_path.rglob("*"))
    monkeypatch.setattr(forge, "REPO_ROOT", tmp_path)

    result = check_registry(path)
    assert not result.ok
    assert result.entry_count == 3
    assert any("fractals[2]" in e and "registry_entry validation failed" in e
               for e in result.errors)
    assert any("duplicate id" in e for e in result.errors)
    assert any("duplicate formula_hash" in e for e in result.errors)
    assert forge.main(["doctor"]) == 1
    output = capsys.readouterr().out
    assert "FAIL" in output and "fractals[2]" in output
    assert set(tmp_path.rglob("*")) == paths_before
    assert {p: p.read_bytes() for p in tmp_path.rglob("*") if p.is_file()} == before
