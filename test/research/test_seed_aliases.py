from pathlib import Path

from scripts.research.lib.registry import Registry
from scripts.research.migrate.retrofit_registry import retrofit_entries
from scripts.research.migrate.seed_aliases import build_alias_table, run_seed_aliases


def test_seed_builds_one_entry_per_registry_entry(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    table = build_alias_table(r.entries, seed={})
    assert set(table.keys()) == {"mandelbrot", "burning_ship"}


def test_seed_canonical_name_defaults_to_entry_name(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    table = build_alias_table(r.entries, seed={})
    assert table["mandelbrot"]["canonical_name"] == "Mandelbrot"


def test_seed_merges_hand_curated_aliases(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    seed = {
        "mandelbrot": {
            "canonical_name": "Mandelbrot Set",
            "aliases": ["M-set", "曼德勃罗集合"],
            "family": "mandelbrot",
        }
    }
    table = build_alias_table(r.entries, seed=seed)
    assert table["mandelbrot"]["canonical_name"] == "Mandelbrot Set"
    assert "M-set" in table["mandelbrot"]["aliases"]
    assert "曼德勃罗集合" in table["mandelbrot"]["aliases"]
    assert table["mandelbrot"]["family"] == "mandelbrot"


def test_seed_merges_registry_entry_aliases(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    r.entries[0]["aliases"] = ["M-set", "z^2 + c set"]
    table = build_alias_table(r.entries, seed={})
    assert "M-set" in table["mandelbrot"]["aliases"]
    assert "z^2 + c set" in table["mandelbrot"]["aliases"]


def test_seed_always_includes_entry_id_and_name_as_aliases(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    table = build_alias_table(r.entries, seed={})
    assert "mandelbrot" in table["mandelbrot"]["aliases"]
    assert "Mandelbrot" in table["mandelbrot"]["aliases"]


def test_run_seed_aliases_writes_file(tmp_path, tmp_registry):
    out = tmp_path / "canonical_aliases.yaml"
    rc = run_seed_aliases(registry_path=tmp_registry, seed_path=None, output_path=out)
    assert rc == 0
    assert out.exists()
    content = out.read_text()
    assert "mandelbrot" in content
    assert "burning_ship" in content
