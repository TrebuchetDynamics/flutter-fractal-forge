"""Compute a stable sha256 hash that identifies a fractal entry.

STAGE A: We have no formula_ast yet for legacy entries. Hash a canonical
tuple of the fields that *define* the fractal: (id, category, shader,
dimension, defaultPower, defaultBailout). This is stable and unique per
entry in the current 370-entry registry and serves as the dedup key
until Stage B introduces true formula_ast normalization.

STAGE B: This module will be replaced with a normalizer that hashes
the canonicalized formula_ast. Migration path: re-run retrofit, which
will recompute and update all hashes in place.
"""
from __future__ import annotations

import hashlib
import json
from typing import Any


LEGACY_KEY_FIELDS = (
    "id",
    "category",
    "shader",
    "dimension",
    "defaultPower",
    "defaultBailout",
)


def hash_legacy_entry(entry: dict[str, Any]) -> str:
    """Return 'sha256:<hex>' for an existing registry entry."""
    payload = {k: entry.get(k) for k in LEGACY_KEY_FIELDS}
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    digest = hashlib.sha256(canonical.encode("utf-8")).hexdigest()
    return f"sha256:{digest}"


def hash_formula_ast(formula_ast: dict[str, Any]) -> str:
    """STAGE A PLACEHOLDER: not used by retrofit.

    Stage B will implement real normalization (alpha-rename vars,
    sort commutative ops, strip whitespace).
    """
    canonical = json.dumps(formula_ast, sort_keys=True, separators=(",", ":"))
    digest = hashlib.sha256(canonical.encode("utf-8")).hexdigest()
    return f"sha256:{digest}"
