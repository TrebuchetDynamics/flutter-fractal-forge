"""Seed research/canonical/canonical_aliases.yaml from the registry + manual seed.

Run via `forge seed-aliases`. Idempotent. Never deletes an alias once it has
appeared in the output (dedup memory must grow monotonically).
"""
from __future__ import annotations

from pathlib import Path
from typing import Any

from ruamel.yaml import YAML

from scripts.research.lib.registry import Registry


def _yaml() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    y.indent(mapping=2, sequence=4, offset=2)
    y.width = 200
    return y


def _read_seed(seed_path: Path | None) -> dict:
    if seed_path is None or not seed_path.exists():
        return {}
    with seed_path.open("r") as f:
        data = _yaml().load(f) or {}
    return data


def build_alias_table(entries: list[dict], seed: dict) -> dict[str, dict[str, Any]]:
    """Build the alias table from registry entries + hand-curated seed."""
    table: dict[str, dict[str, Any]] = {}
    for entry in entries:
        eid = entry["id"]
        name = entry.get("name", eid)
        seed_entry = seed.get(eid, {})

        aliases = set()
        aliases.add(eid)
        aliases.add(name)
        for a in seed_entry.get("aliases", []):
            aliases.add(a)

        table[eid] = {
            "canonical_name": seed_entry.get("canonical_name", name),
            "aliases": sorted(aliases),
            "family": seed_entry.get("family", entry.get("category", "unknown")
                                     .lower().replace(" ", "_").replace("-", "_")),
        }
    return table


def run_seed_aliases(
    registry_path: Path,
    seed_path: Path | None,
    output_path: Path,
) -> int:
    registry = Registry.load(registry_path)
    seed = _read_seed(seed_path)
    table = build_alias_table(registry.entries, seed)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w") as f:
        _yaml().dump(table, f)

    print(f"seed-aliases: OK — {len(table)} aliases written to {output_path}")
    return 0
