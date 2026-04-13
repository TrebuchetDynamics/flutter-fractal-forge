"""forge doctor: verify invariants over fractal_registry.yaml.

Invariants:
  1. Every entry passes registry_entry schema lint.
  2. No duplicate ids.
  3. No duplicate formula_hash (dedup invariant).
  4. quality.formula_hash matches top-level formula_hash (consistency).
  5. tier matches implemented flag (legacy consistency).
"""
from __future__ import annotations

from collections import Counter
from dataclasses import dataclass, field
from pathlib import Path

from scripts.research.lib.registry import Registry
from scripts.research.lib.schema_lint import SchemaLintError, lint


@dataclass
class DoctorResult:
    ok: bool
    errors: list[str] = field(default_factory=list)
    entry_count: int = 0

    def format_errors(self) -> str:
        if not self.errors:
            return "(no errors)"
        return "\n".join(f"  - {e}" for e in self.errors)

    def format_summary(self) -> str:
        status = "OK" if self.ok else "FAIL"
        return f"forge doctor: {status} ({self.entry_count} entries, {len(self.errors)} error(s))"


def check_registry(path: Path) -> DoctorResult:
    registry = Registry.load(path)
    entries = registry.entries
    errors: list[str] = []

    # 1. Schema lint
    for entry in entries:
        eid = entry.get("id", "?")
        try:
            lint("registry_entry", entry)
        except SchemaLintError as e:
            errors.append(f"{eid}: {e}")

    # 2. Duplicate ids
    id_counts = Counter(e.get("id") for e in entries)
    for eid, count in id_counts.items():
        if count > 1:
            errors.append(f"duplicate id: {eid} appears {count} times")

    # 3. Duplicate formula_hash
    hash_counts = Counter(e.get("formula_hash") for e in entries if e.get("formula_hash"))
    for fh, count in hash_counts.items():
        if count > 1:
            colliding = [e["id"] for e in entries if e.get("formula_hash") == fh]
            errors.append(f"duplicate formula_hash: {fh} - entries {colliding}")

    # 4. Consistency: quality.formula_hash == top-level formula_hash
    for entry in entries:
        q = entry.get("quality") or {}
        if q.get("formula_hash") and q["formula_hash"] != entry.get("formula_hash"):
            errors.append(
                f"{entry.get('id')}: quality.formula_hash ({q['formula_hash']}) "
                f"!= formula_hash ({entry.get('formula_hash')})"
            )

    # 5. Tier consistency
    for entry in entries:
        expected_tier = "implemented" if entry.get("implemented") else "reference"
        if entry.get("tier") != expected_tier:
            errors.append(
                f"{entry.get('id')}: tier={entry.get('tier')} but implemented={entry.get('implemented')}"
            )

    return DoctorResult(ok=not errors, errors=errors, entry_count=len(entries))


def run_doctor(repo_root: Path, verbose: bool = False) -> int:
    path = Path(repo_root) / "docs" / "catalog" / "fractal_registry.yaml"
    result = check_registry(path)
    print(result.format_summary())
    if not result.ok or verbose:
        print(result.format_errors())
    return 0 if result.ok else 1
