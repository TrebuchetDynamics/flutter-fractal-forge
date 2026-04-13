"""Round-trip loader/saver for docs/catalog/fractal_registry.yaml.

Uses ruamel.yaml to preserve comments and key ordering. Never rewrites
fields that callers didn't explicitly change.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterator

from ruamel.yaml import YAML


def _make_yaml() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    y.indent(mapping=2, sequence=4, offset=2)
    y.width = 200
    return y


@dataclass
class Registry:
    """In-memory view of fractal_registry.yaml."""

    path: Path
    _doc: Any = field(default=None, repr=False)
    _yaml: YAML = field(default_factory=_make_yaml, repr=False)

    @classmethod
    def load(cls, path: Path) -> "Registry":
        r = cls(path=Path(path))
        with r.path.open("r") as f:
            r._doc = r._yaml.load(f)
        if r._doc is None or "fractals" not in r._doc:
            raise ValueError(f"{path}: missing top-level 'fractals' list")
        return r

    @property
    def entries(self) -> list[dict]:
        return self._doc["fractals"]

    def __iter__(self) -> Iterator[dict]:
        return iter(self.entries)

    def by_id(self, entry_id: str) -> dict | None:
        for entry in self.entries:
            if entry.get("id") == entry_id:
                return entry
        return None

    def update_entry(self, entry_id: str, patch: dict) -> None:
        entry = self.by_id(entry_id)
        if entry is None:
            raise KeyError(entry_id)
        entry.update(patch)

    def save(self, path: Path | None = None) -> None:
        target = Path(path) if path else self.path
        with target.open("w") as f:
            self._yaml.dump(self._doc, f)
