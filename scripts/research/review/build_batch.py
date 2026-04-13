"""Assemble a candidates batch from research/extracted/ for human review."""
from __future__ import annotations

import shutil
from datetime import date
from pathlib import Path

from ruamel.yaml import YAML


def _yaml() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    y.indent(mapping=2, sequence=4, offset=2)
    return y


def _default_batch_id() -> str:
    today = date.today()
    iso_year, iso_week, _ = today.isocalendar()
    return f"b_{iso_year}_w{iso_week:02d}"


def build_batch(
    extracted_dir: Path,
    candidates_dir: Path,
    batch_id: str | None = None,
    limit: int = 500,
    overwrite: bool = False,
) -> Path:
    """Copy up to `limit` oldest candidates from extracted_dir to a new batch subdir.

    Returns the batch path.
    """
    batch_id = batch_id or _default_batch_id()
    batch_path = candidates_dir / batch_id
    if batch_path.exists() and not overwrite:
        raise FileExistsError(f"batch {batch_id} already exists: {batch_path}")
    batch_path.mkdir(parents=True, exist_ok=overwrite)

    extracted = sorted(extracted_dir.glob("*.yaml"), key=lambda p: p.stat().st_mtime)
    selected = extracted[:limit]

    candidate_ids = []
    for src in selected:
        dst = batch_path / src.name
        shutil.copy2(src, dst)
        # Extract candidate_id for manifest
        with src.open() as f:
            data = _yaml().load(f) or {}
        candidate_ids.append(data.get("candidate_id", src.stem))

    manifest = {
        "batch_id": batch_id,
        "created": date.today().isoformat(),
        "count": len(selected),
        "limit": limit,
        "candidate_ids": candidate_ids,
    }
    with (batch_path / "manifest.yaml").open("w") as f:
        _yaml().dump(manifest, f)

    return batch_path


def run_build_batch(repo_root: Path, batch_id: str | None = None, limit: int = 500) -> int:
    extracted_dir = repo_root / "research" / "extracted"
    candidates_dir = repo_root / "research" / "candidates"
    if not extracted_dir.exists() or not any(extracted_dir.glob("*.yaml")):
        print(f"build-batch: no candidates in {extracted_dir}")
        return 1
    batch_path = build_batch(extracted_dir, candidates_dir, batch_id=batch_id, limit=limit)
    print(f"build-batch: OK - batch {batch_path.name} at {batch_path}")
    return 0
