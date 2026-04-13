"""One-shot migration: add formula_hash, quality, tier to every registry entry.

Idempotent. Safe to re-run. Preserves all existing fields.

Entry point called from `forge retrofit`.
"""
from __future__ import annotations

from datetime import date
from pathlib import Path

from scripts.research.lib.formula_hash import hash_legacy_entry
from scripts.research.lib.registry import Registry
from scripts.research.lib.schema_lint import SchemaLintError, lint


def _derive_tier(entry: dict) -> str:
    return "implemented" if entry.get("implemented") else "reference"


def _derive_quality(entry: dict, formula_hash: str) -> dict:
    existing = entry.get("quality") or {}
    # Preserve anything already populated; only fill gaps.
    return {
        "formula_hash": formula_hash,
        "citation_health": existing.get("citation_health", {
            "last_checked": str(date.today()),
            "status": "unchecked",
        }),
        "shader_compile": existing.get("shader_compile", {
            "sksl": "unchecked",
            "glsl": "unchecked",
            "checked": str(date.today()),
        }),
        "thumbnail": existing.get("thumbnail", {
            "entropy": 0.0,
            "checked": str(date.today()),
        }),
        "review": existing.get("review", {
            "approved_by": "retrofit",
            "batch": "stage_a_retrofit_2026_04",
        }),
        "confidence": existing.get("confidence", 1.0),
    }


def retrofit_entries(entries: list[dict]) -> None:
    """Mutate entries in place to add tier, formula_hash, quality. Idempotent."""
    for entry in entries:
        formula_hash = hash_legacy_entry(entry)
        entry.setdefault("tier", _derive_tier(entry))
        # Always set formula_hash (idempotent because hash is deterministic)
        entry["formula_hash"] = formula_hash
        entry["quality"] = _derive_quality(entry, formula_hash)


def run_retrofit(
    repo_root: Path,
    registry_path: Path | None = None,
    dry_run: bool = False,
) -> int:
    """CLI handler. Returns exit code."""
    path = Path(registry_path) if registry_path else Path(repo_root) / "docs" / "catalog" / "fractal_registry.yaml"
    registry = Registry.load(path)

    retrofit_entries(registry.entries)

    # Validate every entry before writing
    errors: list[tuple[str, str]] = []
    for entry in registry.entries:
        try:
            lint("registry_entry", entry)
        except SchemaLintError as e:
            errors.append((entry.get("id", "?"), str(e)))

    if errors:
        print(f"retrofit: FAIL - {len(errors)} entries failed schema lint")
        for eid, msg in errors[:10]:
            print(f"  {eid}: {msg}")
        return 2

    if dry_run:
        print(f"retrofit: dry-run OK - {len(registry.entries)} entries would be updated")
        return 0

    registry.save()
    print(f"retrofit: OK - {len(registry.entries)} entries updated in {path}")
    return 0
