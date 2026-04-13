from pathlib import Path
from ruamel.yaml import YAML
from scripts.research.lib.registry import Registry
from scripts.research.review.review_batch import review_batch, write_decisions, ReviewResult


def _write_cand(dir_, cid, name="New Fractal", update="z = z**5 + c"):
    path = dir_ / f"{cid}.yaml"
    data = {
        "candidate_id": cid,
        "source": {"type": "manual", "url": "https://example.com/x", "fetched_at": "2026-04-12T00:00:00Z"},
        "proposed_name": name,
        "formula_ast": {"iteration_type": "escape_time", "variables": ["z", "c"], "update": update, "init": "z = 0"},
        "references": [{"url": "https://example.com/ref"}],
        "quality": {"formula_hash": "sha256:" + "0" * 64, "confidence": 0.9},
    }
    y = YAML()
    y.dump(data, path)


def test_review_auto_approves_new(tmp_path, tmp_registry):
    batch = tmp_path / "b_test"
    batch.mkdir()
    _write_cand(batch, "ct_20260412_0001", name="Totally New Fractal", update="z = z**7 + c")
    reg = Registry.load(tmp_registry)
    result = review_batch(batch, reg, aliases={}, auto_approve_new=True)
    assert "ct_20260412_0001" in result.decisions
    assert result.decisions["ct_20260412_0001"]["action"] == "approve_new"


def test_review_interactive_fallback_raises_if_no_handler(tmp_path, tmp_registry):
    batch = tmp_path / "b_test"
    batch.mkdir()
    _write_cand(batch, "ct_20260412_0002", name="Mandelbrot Set", update="z = z**2 + c")
    reg = Registry.load(tmp_registry)
    aliases = {"mandelbrot": {"canonical_name": "Mandelbrot Set", "aliases": ["Mandelbrot Set"]}}
    # The candidate's formula z**2+c hashes into an existing? No — existing registry from tmp_registry
    # has mandelbrot with legacy hash, not sympy hash. So dedup won't auto_merge.
    # But fuzzy name "Mandelbrot Set" matches alias → review_fuzzy → interactive required.
    import pytest
    with pytest.raises(RuntimeError):
        review_batch(batch, reg, aliases, auto_approve_new=False, interactive_input=None)


def test_review_writes_decisions_file(tmp_path, tmp_registry):
    batch = tmp_path / "b_test"
    batch.mkdir()
    _write_cand(batch, "ct_1", name="Unique Fractal", update="z = z**9 + c")
    reg = Registry.load(tmp_registry)
    result = review_batch(batch, reg, aliases={}, auto_approve_new=True)
    decisions_dir = tmp_path / "decisions"
    out = write_decisions(result, decisions_dir)
    assert out.exists()
    y = YAML()
    data = y.load(out.open())
    assert data["batch_id"] == "b_test"
    assert "ct_1" in data["decisions"]
