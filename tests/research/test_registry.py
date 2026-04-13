from scripts.research.lib.registry import Registry


def test_registry_loads_from_path(tmp_registry):
    r = Registry.load(tmp_registry)
    assert len(r.entries) == 2
    assert r.entries[0]["id"] == "mandelbrot"


def test_registry_finds_by_id(tmp_registry):
    r = Registry.load(tmp_registry)
    assert r.by_id("burning_ship")["name"] == "Burning Ship"
    assert r.by_id("nonexistent") is None


def test_registry_round_trip_preserves_fields(tmp_registry):
    r = Registry.load(tmp_registry)
    r.save()
    r2 = Registry.load(tmp_registry)
    assert r.entries == r2.entries


def test_registry_update_entry_writes_changes(tmp_registry):
    r = Registry.load(tmp_registry)
    r.update_entry("mandelbrot", {"tier": "implemented"})
    r.save()
    r2 = Registry.load(tmp_registry)
    assert r2.by_id("mandelbrot")["tier"] == "implemented"


def test_registry_update_unknown_id_raises(tmp_registry):
    import pytest
    r = Registry.load(tmp_registry)
    with pytest.raises(KeyError):
        r.update_entry("does_not_exist", {"tier": "reference"})
