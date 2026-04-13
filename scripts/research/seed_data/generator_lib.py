"""Shared helpers for batch fractal generators.

The candidate schema requires `candidate_id` to match ^ct_[0-9]{8}_[0-9a-f]{4,}$
so we construct IDs as:  ct_<8-digit-family-stamp>_<4+ hex slug>
where the 8-digit stamp is `20260413` (today) and the hex slug is derived
from hashing (family, index, slug).
"""
from __future__ import annotations

import hashlib
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from ruamel.yaml import YAML

REPO_ROOT = Path(__file__).resolve().parents[3]
CANDIDATES_DIR = REPO_ROOT / "research" / "candidates"
DECISIONS_DIR = REPO_ROOT / "research" / "decisions"

DATE_STAMP = "20260413"


def _yaml() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    y.indent(mapping=2, sequence=4, offset=2)
    y.width = 200
    return y


def make_candidate_id(family: str, index: int, slug: str) -> str:
    """Deterministic candidate_id matching ^ct_[0-9]{8}_[0-9a-f]{4,}$."""
    digest = hashlib.sha256(f"{family}_{index}_{slug}".encode()).hexdigest()[:8]
    return f"ct_{DATE_STAMP}_{digest}"


def default_source(url: str, note: str = "") -> dict:
    return {
        "type": "manual",
        "url": url,
        "fetched_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "license": note or "Public domain (classical mathematics)",
    }


def placeholder_hash(seed: str) -> str:
    h = hashlib.sha256(seed.encode()).hexdigest()
    return f"sha256:{h}"


_RESERVED = {
    "sin", "cos", "tan", "exp", "log", "sqrt", "abs", "real", "imag",
    "conj", "re", "im", "Abs", "I", "E", "pi",
}


def _extract_vars(update: str, init: str) -> list[str]:
    text = f"{update} {init}"
    tokens = set(re.findall(r"\b([a-zA-Z_][a-zA-Z0-9_]*)\b", text))
    return sorted(v for v in tokens if v not in _RESERVED and not v[0].isupper())


def write_candidate(
    batch_id: str,
    candidate_id: str,
    proposed_name: str,
    iteration_type: str,
    update: str,
    init: str,
    params: dict,
    presets: list,
    variants: list,
    references: list,
    aliases: list,
    description_en: str,
    source_url: str,
    source_note: str = "",
    formula_latex: str = "",
    confidence: float = 0.9,
) -> Path:
    """Write one candidate YAML to candidates/{batch_id}/."""
    batch_dir = CANDIDATES_DIR / batch_id
    batch_dir.mkdir(parents=True, exist_ok=True)
    path = batch_dir / f"{candidate_id}.yaml"

    data = {
        "candidate_id": candidate_id,
        "source": default_source(source_url, source_note),
        "proposed_name": proposed_name,
        "aliases": aliases,
        "formula_latex": formula_latex or f"{proposed_name} iteration",
        "formula_ast": {
            "iteration_type": iteration_type,
            "variables": _extract_vars(update, init),
            "update": update,
            "init": init,
        },
        "params": params,
        "presets": presets,
        "variants": variants,
        "references": references,
        "description_en": description_en,
        "quality": {
            "formula_hash": placeholder_hash(f"{candidate_id}_{update}_{init}"),
            "confidence": confidence,
        },
    }
    with path.open("w") as f:
        _yaml().dump(data, f)
    return path


def write_auto_approve_decisions(batch_id: str, candidate_ids: list[str]) -> Path:
    """Write decisions file approving all as new."""
    DECISIONS_DIR.mkdir(parents=True, exist_ok=True)
    path = DECISIONS_DIR / f"{batch_id}.yaml"
    data = {
        "batch_id": batch_id,
        "decisions": {
            cid: {"action": "approve_new", "reason": f"generator batch {batch_id}"}
            for cid in candidate_ids
        },
    }
    with path.open("w") as f:
        _yaml().dump(data, f)
    return path


def run_family(batch_id: str, family: str, table: list[dict[str, Any]]) -> None:
    """Generic runner used by each family generator."""
    candidate_ids: list[str] = []
    for i, entry in enumerate(table, start=1):
        slug_source = entry.get("slug") or entry["name"]
        slug = re.sub(r"[^a-z0-9]+", "_", slug_source.lower()).strip("_")
        cid = make_candidate_id(family, i, slug)
        write_candidate(
            batch_id=batch_id,
            candidate_id=cid,
            proposed_name=entry["name"],
            iteration_type=entry["iteration_type"],
            update=entry["update"],
            init=entry.get("init", ""),
            params=entry.get("params", {}),
            presets=entry.get("presets", []),
            variants=entry.get("variants", []),
            references=entry["references"],
            aliases=entry.get("aliases", []),
            description_en=entry["description_en"],
            source_url=entry.get("source_url") or entry["references"][0].get("url", ""),
            formula_latex=entry.get("formula_latex", ""),
            confidence=entry.get("confidence", 0.9),
        )
        candidate_ids.append(cid)
    write_auto_approve_decisions(batch_id, candidate_ids)
    print(f"{batch_id}: wrote {len(table)} candidates")
