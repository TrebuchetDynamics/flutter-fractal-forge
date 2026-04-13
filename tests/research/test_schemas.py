import json
from pathlib import Path

import pytest
from jsonschema import Draft202012Validator, ValidationError, validate
from referencing import Registry, Resource

SCHEMA_DIR = Path(__file__).resolve().parents[2] / "scripts" / "research" / "schemas"


def _load(name: str) -> dict:
    return json.loads((SCHEMA_DIR / name).read_text())


def _registry():
    """Build a referencing Registry so $ref to common.schema.json resolves."""
    reg = Registry()
    for path in SCHEMA_DIR.glob("*.schema.json"):
        schema = json.loads(path.read_text())
        resource = Resource.from_contents(schema)
        reg = reg.with_resource(uri=path.name, resource=resource)
    return reg


def _validate(instance: dict, schema: dict):
    validator = Draft202012Validator(schema, registry=_registry())
    validator.validate(instance)


def test_common_schema_is_valid_draft_2020_12():
    schema = _load("common.schema.json")
    Draft202012Validator.check_schema(schema)


def test_common_schema_defines_required_subschemas():
    schema = _load("common.schema.json")
    defs = schema.get("$defs", {})
    for required in ("formula_ast", "params", "citation", "quality_block"):
        assert required in defs, f"missing $defs/{required}"


def test_formula_ast_requires_iteration_type():
    schema = _load("common.schema.json")
    ast = schema["$defs"]["formula_ast"]
    assert "iteration_type" in ast["required"]


def test_citation_requires_url_or_doi():
    schema = _load("common.schema.json")
    cit = schema["$defs"]["citation"]
    # Either url OR doi must be required via anyOf on required fields
    assert "anyOf" in cit or "required" in cit


def _registry_entry_schema():
    return _load("registry_entry.schema.json")


def _sample_existing_entry():
    # Shape of current registry entries (from docs/catalog/fractal_registry.yaml)
    return {
        "id": "mandelbrot",
        "name": "Mandelbrot",
        "shader": "shaders/mandelbrot_gpu.frag",
        "category": "Escape-Time",
        "dimension": "2D",
        "defaultPower": 2.0,
        "defaultIterations": 500.0,
        "defaultSteps": 0.0,
        "defaultBailout": 2.0,
        "defaultColorScheme": 0,
        "hasThumbnail": True,
        "implemented": True,
        "presets": [],
        "variants": [],
        "references": [],
    }


def _sample_retrofitted_entry():
    e = _sample_existing_entry()
    e.update({
        "tier": "implemented",
        "formula_hash": "sha256:" + "a" * 64,
        "quality": {
            "formula_hash": "sha256:" + "a" * 64,
            "confidence": 1.0,
        },
    })
    return e


def test_registry_entry_schema_valid():
    Draft202012Validator.check_schema(_registry_entry_schema())


def test_registry_entry_accepts_retrofitted_entry():
    _validate(_sample_retrofitted_entry(), _registry_entry_schema())


def test_registry_entry_requires_tier():
    entry = _sample_retrofitted_entry()
    del entry["tier"]
    with pytest.raises(ValidationError):
        _validate(entry, _registry_entry_schema())


def test_registry_entry_tier_must_be_enum():
    entry = _sample_retrofitted_entry()
    entry["tier"] = "bogus"
    with pytest.raises(ValidationError):
        _validate(entry, _registry_entry_schema())


def test_registry_entry_accepts_entry_missing_optional_legacy_field():
    """Legacy fields like hasThumbnail/dimension are optional; their absence must validate."""
    entry = _sample_retrofitted_entry()
    del entry["hasThumbnail"]
    del entry["dimension"]
    _validate(entry, _registry_entry_schema())


def test_registry_entry_accepts_additional_unknown_fields():
    """additionalProperties: true — unknown keys (e.g., future fields, plugin metadata) must pass."""
    entry = _sample_retrofitted_entry()
    entry["some_future_plugin_field"] = {"nested": [1, 2, 3]}
    _validate(entry, _registry_entry_schema())
