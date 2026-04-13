"""Validate dicts against named pipeline schemas.

Known schemas: candidate, registry_entry, metadata. Cross-schema $ref to
common.schema.json is resolved via a pre-built referencing.Registry.
"""
from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path
from typing import Any

from jsonschema import Draft202012Validator, ValidationError
from referencing import Registry as RefRegistry, Resource

SCHEMA_DIR = Path(__file__).resolve().parents[1] / "schemas"
KNOWN = {"candidate", "registry_entry", "metadata"}


class SchemaLintError(Exception):
    """Raised when an instance fails schema validation."""


@lru_cache(maxsize=1)
def _registry() -> RefRegistry:
    reg = RefRegistry()
    for path in SCHEMA_DIR.glob("*.schema.json"):
        schema = json.loads(path.read_text())
        resource = Resource.from_contents(schema)
        reg = reg.with_resource(uri=path.name, resource=resource)
    return reg


@lru_cache(maxsize=8)
def _validator(schema_name: str) -> Draft202012Validator:
    if schema_name not in KNOWN:
        raise KeyError(f"unknown schema: {schema_name}")
    schema = json.loads((SCHEMA_DIR / f"{schema_name}.schema.json").read_text())
    return Draft202012Validator(schema, registry=_registry())


def lint(schema_name: str, instance: Any) -> None:
    """Validate or raise SchemaLintError with a human-readable message."""
    validator = _validator(schema_name)
    errors = sorted(validator.iter_errors(instance), key=lambda e: e.path)
    if not errors:
        return
    msgs = [f"  - {'/'.join(map(str, e.path)) or '<root>'}: {e.message}" for e in errors]
    raise SchemaLintError(
        f"{schema_name} validation failed ({len(errors)} error(s)):\n" + "\n".join(msgs)
    )
