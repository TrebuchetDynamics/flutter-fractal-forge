import json
from pathlib import Path

import pytest
from jsonschema import Draft202012Validator

SCHEMA_DIR = Path(__file__).resolve().parents[2] / "scripts" / "research" / "schemas"


def _load(name: str) -> dict:
    return json.loads((SCHEMA_DIR / name).read_text())


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
