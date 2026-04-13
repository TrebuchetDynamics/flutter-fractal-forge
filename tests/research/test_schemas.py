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


def _candidate_schema():
    return _load("candidate.schema.json")


def _sample_candidate():
    return {
        "candidate_id": "ct_20260412_a4f9",
        "source": {
            "type": "ultra_fractal",
            "url": "https://example.com/formula.ufm",
            "fetched_at": "2026-04-12T14:22:11Z",
            "license": "MIT",
        },
        "canonical": {"id": None, "name_en": None, "category": None},
        "proposed_name": "Tricorn",
        "aliases": ["Mandelbar"],
        "formula_latex": "z_{n+1} = \\overline{z_n}^2 + c",
        "formula_ast": {
            "iteration_type": "escape_time",
            "variables": ["z", "c"],
            "update": "z = conj(z)^2 + c",
            "init": "z = 0",
        },
        "params": {
            "iterations": {"default": 500, "range": [1, 10000]},
        },
        "presets": [],
        "variants": [],
        "description_en": "The tricorn...",
        "references": [{"url": "https://example.com/paper"}],
        "quality": {
            "formula_hash": "sha256:" + "b" * 64,
            "confidence": 0.9,
        },
    }


def test_candidate_schema_valid():
    Draft202012Validator.check_schema(_candidate_schema())


def test_candidate_accepts_sample():
    _validate(_sample_candidate(), _candidate_schema())


def test_candidate_requires_source_type():
    c = _sample_candidate()
    del c["source"]["type"]
    with pytest.raises(ValidationError):
        _validate(c, _candidate_schema())


def test_candidate_source_type_enumerated():
    c = _sample_candidate()
    c["source"]["type"] = "bogus_source"
    with pytest.raises(ValidationError):
        _validate(c, _candidate_schema())


def test_candidate_requires_proposed_name_and_formula_ast():
    c = _sample_candidate()
    del c["proposed_name"]
    with pytest.raises(ValidationError):
        _validate(c, _candidate_schema())
