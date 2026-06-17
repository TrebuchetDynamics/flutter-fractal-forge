from pathlib import Path
import pytest
from ruamel.yaml import YAML
from scripts.research.review.build_batch import build_batch, _default_batch_id


def _write_cand(dir_: Path, cid: str):
    p = dir_ / f"{cid}.yaml"
    y = YAML()
    y.dump({"candidate_id": cid, "proposed_name": f"Fractal {cid}"}, p)
    return p


def test_build_batch_creates_batch_dir(tmp_path):
    extracted = tmp_path / "extracted"
    extracted.mkdir()
    _write_cand(extracted, "ct_20260412_0001")
    _write_cand(extracted, "ct_20260412_0002")
    cands = tmp_path / "candidates"
    batch = build_batch(extracted, cands, batch_id="b_test")
    assert batch.exists()
    assert (batch / "manifest.yaml").exists()
    assert (batch / "ct_20260412_0001.yaml").exists()


def test_build_batch_respects_limit(tmp_path):
    extracted = tmp_path / "extracted"
    extracted.mkdir()
    for i in range(10):
        _write_cand(extracted, f"ct_0000_{i:04d}")
    cands = tmp_path / "candidates"
    batch = build_batch(extracted, cands, batch_id="b_test", limit=3)
    yaml_files = list(batch.glob("ct_*.yaml"))
    assert len(yaml_files) == 3


def test_build_batch_manifest_lists_ids(tmp_path):
    extracted = tmp_path / "extracted"
    extracted.mkdir()
    _write_cand(extracted, "ct_1")
    _write_cand(extracted, "ct_2")
    cands = tmp_path / "candidates"
    batch = build_batch(extracted, cands, batch_id="b_test")
    y = YAML()
    manifest = y.load((batch / "manifest.yaml").open())
    assert manifest["count"] == 2
    assert set(manifest["candidate_ids"]) == {"ct_1", "ct_2"}


def test_build_batch_refuses_overwrite(tmp_path):
    extracted = tmp_path / "extracted"
    extracted.mkdir()
    _write_cand(extracted, "ct_1")
    cands = tmp_path / "candidates"
    build_batch(extracted, cands, batch_id="b_test")
    with pytest.raises(FileExistsError):
        build_batch(extracted, cands, batch_id="b_test")


def test_default_batch_id_format():
    bid = _default_batch_id()
    assert bid.startswith("b_")
    assert "_w" in bid
