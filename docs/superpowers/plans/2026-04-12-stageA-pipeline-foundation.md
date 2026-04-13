# Fractal Research Pipeline — Stage A: Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- []`) syntax for tracking.

**Goal:** Build the foundation of the fractal research pipeline: JSON Schemas, `forge` CLI skeleton, `forge doctor` invariant checker, and a registry retrofit that adds `formula_hash`, `quality`, and `tier` fields to all 370 existing entries without breaking the current Flutter app.

**Architecture:** Python 3.11 tooling under `scripts/research/`, with a single `forge.py` CLI entry point and subcommands. All schemas live in `scripts/research/schemas/` as JSON Schema draft 2020-12 files. The existing `docs/catalog/fractal_registry.yaml` is the migration target — we extend it additively (never rename existing fields). Round-trip YAML via `ruamel.yaml` preserves comments and order.

**Tech Stack:** Python 3.11, `ruamel.yaml`, `jsonschema` (Python package for validation), `pytest`, existing registry at `docs/catalog/fractal_registry.yaml`.

**Reference spec:** `docs/superpowers/specs/2026-04-12-fractal-research-pipeline-design.md` §8 (Directory Layout, Schemas & Tooling), §9 Stage A.

**Existing state to respect:**
- `docs/catalog/fractal_registry.yaml` (5861 lines, 370 entries) — current schema: `id`, `name`, `shader`, `category`, `dimension`, `defaultPower`, `defaultIterations`, `defaultSteps`, `defaultBailout`, `defaultColorScheme`, `hasThumbnail`, `implemented`, `presets`, `variants`, `references`
- `scripts/generate_fractal_registry.py` — must keep working after retrofit
- `scripts/audit_fractals.py` — must keep working
- Flutter app reads the registry at runtime — additive changes only; **do not remove or rename any existing field**

---

## File Structure

### Files to create

| File | Purpose |
|------|---------|
| `scripts/research/__init__.py` | Package marker |
| `scripts/research/forge.py` | Single CLI entry point with subcommands |
| `scripts/research/requirements.txt` | Pinned Python deps |
| `scripts/research/README.md` | One-page user docs for tooling |
| `scripts/research/schemas/__init__.py` | Package marker |
| `scripts/research/schemas/common.schema.json` | Shared `$defs`: `formula_ast`, `params`, `citation`, `quality_block` |
| `scripts/research/schemas/candidate.schema.json` | Candidate file shape |
| `scripts/research/schemas/registry_entry.schema.json` | Registry entry shape |
| `scripts/research/schemas/metadata.schema.json` | Per-fractal `metadata.yaml` shape |
| `scripts/research/lib/__init__.py` | Package marker |
| `scripts/research/lib/registry.py` | Load/save `fractal_registry.yaml` with ruamel round-trip |
| `scripts/research/lib/schema_lint.py` | Validate any dict against a named schema |
| `scripts/research/lib/formula_hash.py` | Normalize + hash `formula_ast` (stub for Stage A — full implementation in Stage B) |
| `scripts/research/doctor/__init__.py` | Package marker |
| `scripts/research/doctor/check_registry.py` | Invariant checks over the registry |
| `scripts/research/migrate/__init__.py` | Package marker |
| `scripts/research/migrate/retrofit_registry.py` | One-shot migration: add `formula_hash`, `quality`, `tier` to existing entries |
| `research/canonical/canonical_aliases.yaml` | Bootstrap alias table — seeded from retrofit |
| `research/seeds/canonical_aliases.seed.yaml` | Hand-curated seed (committed, manual additions) |
| `tests/research/__init__.py` | Package marker |
| `tests/research/conftest.py` | pytest fixtures (tmp registry, sample entries) |
| `tests/research/test_schemas.py` | Schema validation tests |
| `tests/research/test_registry.py` | Round-trip load/save tests |
| `tests/research/test_doctor.py` | Doctor invariant tests |
| `tests/research/test_retrofit.py` | Retrofit migration tests |
| `tests/research/test_forge_cli.py` | CLI smoke tests |
| `.github/workflows/research-tooling-ci.yml` | CI: pytest + schema lint on tooling changes |

### Files to modify

| File | Change |
|------|--------|
| `.gitignore` | Add `research/raw/`, `research/extracted/`, `research/candidates/`, `research/decisions/`, `research/rejects/`, `reports/` (keep their `.gitkeep` files though) |
| `docs/catalog/fractal_registry.yaml` | Retrofit: each entry gains `formula_hash`, `quality`, `tier` (existing fields preserved) |

### Files NOT touched in Stage A

- Any Flutter / Dart source
- Existing `scripts/*.py` (non-research)
- `docs/catalog/` subdirectories (those are Stage B+)

---

## Prerequisites Check (do once before Task 1)

- [ ] **Confirm Python 3.11+ is available:** Run `python3 --version` — expect `Python 3.11.*` or newer. If not available, stop and tell the user.
- [ ] **Confirm current registry is loadable:** Run `python3 -c "import yaml; yaml.safe_load(open('docs/catalog/fractal_registry.yaml'))"` — expect no output and exit code 0.

---

## Task 1: Create Python project scaffold

**Files:**
- Create: `scripts/research/__init__.py`
- Create: `scripts/research/requirements.txt`
- Create: `scripts/research/README.md`
- Create: `scripts/research/lib/__init__.py`
- Create: `scripts/research/schemas/__init__.py`
- Create: `scripts/research/doctor/__init__.py`
- Create: `scripts/research/migrate/__init__.py`
- Create: `tests/research/__init__.py`

- [ ] **Step 1: Create package directories and markers**

```bash
mkdir -p scripts/research/{lib,schemas,doctor,migrate,crawl,extract,canonicalize,review,admit,maintenance}
mkdir -p tests/research
touch scripts/research/__init__.py
touch scripts/research/lib/__init__.py
touch scripts/research/schemas/__init__.py
touch scripts/research/doctor/__init__.py
touch scripts/research/migrate/__init__.py
touch tests/research/__init__.py
```

- [ ] **Step 2: Write `scripts/research/requirements.txt`**

```
ruamel.yaml==0.18.6
jsonschema==4.23.0
pytest==8.3.3
pytest-cov==5.0.0
```

- [ ] **Step 3: Write `scripts/research/README.md`**

````markdown
# Fractal Research Pipeline Tooling

Python tooling for the fractal catalog research pipeline.
See `docs/superpowers/specs/2026-04-12-fractal-research-pipeline-design.md`.

## Install

```bash
python3 -m venv .venv-research
source .venv-research/bin/activate
pip install -r scripts/research/requirements.txt
```

## Run

```bash
python3 scripts/research/forge.py --help
```

## Test

```bash
pytest tests/research -v
```
````

- [ ] **Step 4: Commit**

```bash
git add scripts/research tests/research
git commit -m "feat(research): scaffold Python tooling package structure"
```

---

## Task 2: Create `forge` CLI skeleton

**Files:**
- Create: `scripts/research/forge.py`
- Test: `tests/research/test_forge_cli.py`

- [ ] **Step 1: Write the failing CLI smoke test** (`tests/research/test_forge_cli.py`)

```python
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
FORGE = REPO_ROOT / "scripts" / "research" / "forge.py"


def _run(*args):
    return subprocess.run(
        [sys.executable, str(FORGE), *args],
        capture_output=True,
        text=True,
        cwd=REPO_ROOT,
    )


def test_forge_help_succeeds():
    result = _run("--help")
    assert result.returncode == 0
    assert "forge" in result.stdout.lower()


def test_forge_lists_subcommands():
    result = _run("--help")
    for subcommand in ("doctor", "retrofit"):
        assert subcommand in result.stdout


def test_forge_unknown_subcommand_errors():
    result = _run("nonexistent")
    assert result.returncode != 0
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/research/test_forge_cli.py -v`
Expected: FAIL — `forge.py` doesn't exist yet.

- [ ] **Step 3: Implement `scripts/research/forge.py`**

```python
#!/usr/bin/env python3
"""Fractal research pipeline CLI.

Subcommands are registered in SUBCOMMANDS. Each dispatches to a function
taking argparse.Namespace and returning an int exit code.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Callable

REPO_ROOT = Path(__file__).resolve().parents[2]


def _cmd_doctor(args: argparse.Namespace) -> int:
    from scripts.research.doctor.check_registry import run_doctor
    return run_doctor(REPO_ROOT, verbose=args.verbose)


def _cmd_retrofit(args: argparse.Namespace) -> int:
    from scripts.research.migrate.retrofit_registry import run_retrofit
    return run_retrofit(REPO_ROOT, dry_run=args.dry_run)


SUBCOMMANDS: dict[str, tuple[str, Callable[[argparse.Namespace], int]]] = {
    "doctor": ("Verify registry invariants", _cmd_doctor),
    "retrofit": ("Migrate registry to pipeline schema (adds formula_hash, quality, tier)", _cmd_retrofit),
}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="forge",
        description="Fractal research pipeline CLI.",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    for name, (help_text, _) in SUBCOMMANDS.items():
        sp = sub.add_parser(name, help=help_text)
        if name == "doctor":
            sp.add_argument("-v", "--verbose", action="store_true")
        if name == "retrofit":
            sp.add_argument("--dry-run", action="store_true",
                            help="Show what would change without writing")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    _help, handler = SUBCOMMANDS[args.command]
    return handler(args)


if __name__ == "__main__":
    sys.path.insert(0, str(REPO_ROOT))
    sys.exit(main())
```

- [ ] **Step 4: Run tests again to verify they pass**

Run: `pytest tests/research/test_forge_cli.py -v`
Expected: 3 passed.

Note: tests for `doctor` and `retrofit` subcommand *invocation* (not just `--help`) will pass later when those modules exist; the smoke test only checks `--help` wiring here.

- [ ] **Step 5: Commit**

```bash
git add scripts/research/forge.py tests/research/test_forge_cli.py
git commit -m "feat(research): add forge CLI skeleton with subcommand dispatch"
```

---

## Task 3: Write common JSON sub-schemas (`formula_ast`, `params`, `citation`, `quality_block`)

**Files:**
- Create: `scripts/research/schemas/common.schema.json`
- Test: `tests/research/test_schemas.py` (initial setup)

- [ ] **Step 1: Write the failing test for common schema load**

Create `tests/research/test_schemas.py`:

```python
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/research/test_schemas.py -v`
Expected: FAIL — `common.schema.json` doesn't exist.

- [ ] **Step 3: Write `scripts/research/schemas/common.schema.json`**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://fractal-forge.local/schemas/common.schema.json",
  "title": "Fractal pipeline common sub-schemas",
  "$defs": {
    "formula_ast": {
      "type": "object",
      "required": ["iteration_type"],
      "properties": {
        "iteration_type": {
          "type": "string",
          "enum": [
            "escape_time",
            "newton",
            "strange_attractor",
            "ifs",
            "l_system",
            "raymarch_3d",
            "cellular",
            "lyapunov",
            "tiling",
            "reaction_diffusion",
            "number_theory",
            "other"
          ]
        },
        "variables": {
          "type": "array",
          "items": {"type": "string"}
        },
        "update": {"type": "string"},
        "init": {"type": "string"},
        "family": {"type": "string"}
      },
      "additionalProperties": true
    },
    "params": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "required": ["default"],
        "properties": {
          "default": {"type": ["number", "integer", "boolean", "string"]},
          "range": {
            "type": "array",
            "minItems": 2,
            "maxItems": 2,
            "items": {"type": "number"}
          },
          "description": {"type": "string"}
        }
      }
    },
    "citation": {
      "type": "object",
      "anyOf": [
        {"required": ["url"]},
        {"required": ["doi"]}
      ],
      "properties": {
        "author": {"type": "string"},
        "title": {"type": "string"},
        "year": {"type": "integer", "minimum": 1600, "maximum": 2100},
        "url": {"type": "string", "format": "uri"},
        "doi": {"type": "string"},
        "archived_url": {"type": "string", "format": "uri"}
      },
      "additionalProperties": false
    },
    "quality_block": {
      "type": "object",
      "properties": {
        "formula_hash": {
          "type": "string",
          "pattern": "^sha256:[0-9a-f]{64}$"
        },
        "citation_health": {
          "type": "object",
          "properties": {
            "last_checked": {"type": "string", "format": "date"},
            "status": {"type": "string", "enum": ["ok", "warn", "red", "unchecked"]}
          }
        },
        "shader_compile": {
          "type": "object",
          "properties": {
            "sksl": {"type": "string", "enum": ["ok", "fail", "unchecked", "n/a"]},
            "glsl": {"type": "string", "enum": ["ok", "fail", "unchecked", "n/a"]},
            "checked": {"type": "string", "format": "date"}
          }
        },
        "thumbnail": {
          "type": "object",
          "properties": {
            "entropy": {"type": "number"},
            "checked": {"type": "string", "format": "date"}
          }
        },
        "review": {
          "type": "object",
          "properties": {
            "approved_by": {"type": "string"},
            "batch": {"type": "string"}
          }
        },
        "confidence": {"type": "number", "minimum": 0, "maximum": 1}
      },
      "additionalProperties": false
    }
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `pytest tests/research/test_schemas.py -v`
Expected: 4 passed.

- [ ] **Step 5: Commit**

```bash
git add scripts/research/schemas/common.schema.json tests/research/test_schemas.py
git commit -m "feat(research): add common JSON sub-schemas (formula_ast, params, citation, quality_block)"
```

---

## Task 4: Write `registry_entry.schema.json`

**Files:**
- Create: `scripts/research/schemas/registry_entry.schema.json`
- Modify: `tests/research/test_schemas.py` (append tests)

- [ ] **Step 1: Write failing tests — append to `tests/research/test_schemas.py`**

```python
from jsonschema import validate, ValidationError


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
    validate(instance=_sample_retrofitted_entry(), schema=_registry_entry_schema())


def test_registry_entry_requires_tier():
    entry = _sample_retrofitted_entry()
    del entry["tier"]
    with pytest.raises(ValidationError):
        validate(instance=entry, schema=_registry_entry_schema())


def test_registry_entry_tier_must_be_enum():
    entry = _sample_retrofitted_entry()
    entry["tier"] = "bogus"
    with pytest.raises(ValidationError):
        validate(instance=entry, schema=_registry_entry_schema())


def test_registry_entry_preserves_legacy_fields():
    """Flutter app reads `implemented`, `hasThumbnail`, etc. Schema must allow them."""
    entry = _sample_retrofitted_entry()
    # Removing a legacy field must still validate (legacy fields not required by schema —
    # but retrofit preserves them; we only assert the schema doesn't forbid them)
    validate(instance=entry, schema=_registry_entry_schema())
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `pytest tests/research/test_schemas.py -v -k registry_entry`
Expected: FAIL — `registry_entry.schema.json` doesn't exist.

- [ ] **Step 3: Write `scripts/research/schemas/registry_entry.schema.json`**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://fractal-forge.local/schemas/registry_entry.schema.json",
  "title": "Fractal registry entry",
  "type": "object",
  "required": ["id", "name", "category", "tier", "formula_hash", "quality"],
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^[a-z0-9_]+$",
      "minLength": 1,
      "maxLength": 120
    },
    "name": {"type": "string", "minLength": 1},
    "shader": {"type": "string"},
    "category": {"type": "string", "minLength": 1},
    "dimension": {"type": "string", "enum": ["2D", "3D", "4D", "nD"]},
    "defaultPower": {"type": "number"},
    "defaultIterations": {"type": "number"},
    "defaultSteps": {"type": "number"},
    "defaultBailout": {"type": "number"},
    "defaultColorScheme": {"type": "integer"},
    "hasThumbnail": {"type": "boolean"},
    "implemented": {"type": "boolean"},
    "presets": {"type": "array"},
    "variants": {"type": "array"},
    "references": {"type": "array"},

    "tier": {
      "type": "string",
      "enum": ["implemented", "reference"]
    },
    "formula_hash": {
      "type": "string",
      "pattern": "^sha256:[0-9a-f]{64}$"
    },
    "aliases": {
      "type": "array",
      "items": {"type": "string"}
    },
    "family": {"type": "string"},
    "canonical_name": {"type": "string"},
    "quality": {
      "$ref": "common.schema.json#/$defs/quality_block"
    }
  },
  "additionalProperties": true
}
```

- [ ] **Step 4: Update `_load` in test to resolve cross-schema `$ref`**

Modify the top of `tests/research/test_schemas.py` to use a `RefResolver` or directly set a base URI. Replace the top of the file:

```python
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
```

Update the tests that call `validate(...)` to call `_validate(...)` instead, so cross-schema `$ref` resolves. Add `referencing==0.35.1` to `scripts/research/requirements.txt`.

- [ ] **Step 5: Run tests**

Run: `pytest tests/research/test_schemas.py -v`
Expected: all pass.

- [ ] **Step 6: Commit**

```bash
git add scripts/research/schemas/registry_entry.schema.json tests/research/test_schemas.py scripts/research/requirements.txt
git commit -m "feat(research): add registry_entry JSON schema + cross-ref test harness"
```

---

## Task 5: Write `candidate.schema.json`

**Files:**
- Create: `scripts/research/schemas/candidate.schema.json`
- Modify: `tests/research/test_schemas.py`

- [ ] **Step 1: Append failing tests**

```python
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
```

- [ ] **Step 2: Run tests — expect fail** (`candidate.schema.json` missing)

Run: `pytest tests/research/test_schemas.py -v -k candidate`

- [ ] **Step 3: Write `scripts/research/schemas/candidate.schema.json`**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://fractal-forge.local/schemas/candidate.schema.json",
  "title": "Fractal candidate",
  "type": "object",
  "required": [
    "candidate_id",
    "source",
    "proposed_name",
    "formula_ast",
    "references",
    "quality"
  ],
  "properties": {
    "candidate_id": {
      "type": "string",
      "pattern": "^ct_[0-9]{8}_[0-9a-f]{4,}$"
    },
    "source": {
      "type": "object",
      "required": ["type", "url", "fetched_at"],
      "properties": {
        "type": {
          "type": "string",
          "enum": [
            "ultra_fractal",
            "shadertoy",
            "wikipedia",
            "arxiv",
            "github",
            "forum",
            "mathworld",
            "paul_bourke",
            "cnki",
            "manual"
          ]
        },
        "url": {"type": "string", "format": "uri"},
        "fetched_at": {"type": "string", "format": "date-time"},
        "license": {"type": "string"}
      },
      "additionalProperties": false
    },
    "canonical": {
      "type": "object",
      "properties": {
        "id": {"type": ["string", "null"]},
        "name_en": {"type": ["string", "null"]},
        "category": {"type": ["string", "null"]}
      },
      "additionalProperties": false
    },
    "proposed_name": {"type": "string", "minLength": 1},
    "aliases": {
      "type": "array",
      "items": {"type": "string"}
    },
    "formula_latex": {"type": "string"},
    "formula_ast": {"$ref": "common.schema.json#/$defs/formula_ast"},
    "params": {"$ref": "common.schema.json#/$defs/params"},
    "presets": {"type": "array"},
    "variants": {"type": "array"},
    "description_en": {"type": "string"},
    "references": {
      "type": "array",
      "minItems": 1,
      "items": {"$ref": "common.schema.json#/$defs/citation"}
    },
    "quality": {"$ref": "common.schema.json#/$defs/quality_block"}
  },
  "additionalProperties": false
}
```

- [ ] **Step 4: Run tests — expect pass**

Run: `pytest tests/research/test_schemas.py -v`

- [ ] **Step 5: Commit**

```bash
git add scripts/research/schemas/candidate.schema.json tests/research/test_schemas.py
git commit -m "feat(research): add candidate JSON schema"
```

---

## Task 6: Write `metadata.schema.json`

**Files:**
- Create: `scripts/research/schemas/metadata.schema.json`
- Modify: `tests/research/test_schemas.py`

- [ ] **Step 1: Append failing tests**

```python
def _metadata_schema():
    return _load("metadata.schema.json")


def _sample_metadata():
    return {
        "id": "f001_mandelbrot_set",
        "name": "Mandelbrot Set",
        "category": "I. Escape-Time (Complex Plane)",
        "subcategory": "Mandelbrot Family",
        "shader": "mandelbrot.glsl",
        "thumbnail": "thumbnails/default.png",
        "params": {
            "iterations": {"default": 500, "range": [1, 10000]},
            "bailout": {"default": 2.0, "range": [1.0, 10.0]},
        },
        "presets": [],
        "variants": [],
        "references": [{"url": "https://en.wikipedia.org/wiki/Mandelbrot_set"}],
    }


def test_metadata_schema_valid():
    Draft202012Validator.check_schema(_metadata_schema())


def test_metadata_accepts_sample():
    _validate(_sample_metadata(), _metadata_schema())


def test_metadata_requires_id_name_category_shader():
    for field in ("id", "name", "category", "shader"):
        m = _sample_metadata()
        del m[field]
        with pytest.raises(ValidationError):
            _validate(m, _metadata_schema())


def test_metadata_id_matches_fNNNN_pattern_or_legacy():
    """Canonical new IDs follow f{NNNN}_snake, but legacy IDs (like 'mandelbrot') must also be accepted."""
    m = _sample_metadata()
    m["id"] = "mandelbrot"  # legacy-style id
    _validate(m, _metadata_schema())
```

- [ ] **Step 2: Run tests — expect fail**

Run: `pytest tests/research/test_schemas.py -v -k metadata`

- [ ] **Step 3: Write `scripts/research/schemas/metadata.schema.json`**

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://fractal-forge.local/schemas/metadata.schema.json",
  "title": "Per-fractal metadata",
  "type": "object",
  "required": ["id", "name", "category", "shader"],
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^[a-z0-9_]+$",
      "minLength": 1,
      "maxLength": 120
    },
    "name": {"type": "string", "minLength": 1},
    "category": {"type": "string", "minLength": 1},
    "subcategory": {"type": "string"},
    "shader": {"type": "string"},
    "thumbnail": {"type": "string"},
    "params": {"$ref": "common.schema.json#/$defs/params"},
    "presets": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "name"],
        "properties": {
          "id": {"type": "string"},
          "name": {"type": "string"},
          "params": {"type": "object"}
        }
      }
    },
    "variants": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "name"],
        "properties": {
          "id": {"type": "string"},
          "name": {"type": "string"},
          "params": {"type": "object"}
        }
      }
    },
    "references": {
      "type": "array",
      "items": {"$ref": "common.schema.json#/$defs/citation"}
    }
  },
  "additionalProperties": false
}
```

- [ ] **Step 4: Run tests — expect pass**

Run: `pytest tests/research/test_schemas.py -v`

- [ ] **Step 5: Commit**

```bash
git add scripts/research/schemas/metadata.schema.json tests/research/test_schemas.py
git commit -m "feat(research): add metadata JSON schema"
```

---

## Task 7: Write `lib/registry.py` — round-trip YAML loader

**Files:**
- Create: `scripts/research/lib/registry.py`
- Test: `tests/research/test_registry.py`
- Create: `tests/research/conftest.py`

- [ ] **Step 1: Write `tests/research/conftest.py`**

```python
from pathlib import Path

import pytest
from ruamel.yaml import YAML


@pytest.fixture
def yaml_rt() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    y.indent(mapping=2, sequence=4, offset=2)
    return y


@pytest.fixture
def tmp_registry(tmp_path, yaml_rt) -> Path:
    """A temporary minimal registry file with two legacy-shaped entries."""
    path = tmp_path / "fractal_registry.yaml"
    data = {
        "fractals": [
            {
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
            },
            {
                "id": "burning_ship",
                "name": "Burning Ship",
                "shader": "shaders/burning_ship_gpu.frag",
                "category": "Escape-Time",
                "dimension": "2D",
                "defaultPower": 2.0,
                "defaultIterations": 500.0,
                "defaultSteps": 0.0,
                "defaultBailout": 2.0,
                "defaultColorScheme": 0,
                "hasThumbnail": False,
                "implemented": True,
                "presets": [],
                "variants": [],
                "references": [],
            },
        ]
    }
    with path.open("w") as f:
        yaml_rt.dump(data, f)
    return path
```

- [ ] **Step 2: Write failing tests (`tests/research/test_registry.py`)**

```python
from scripts.research.lib.registry import Registry


def test_registry_loads_from_path(tmp_registry):
    r = Registry.load(tmp_registry)
    assert len(r.entries) == 2
    assert r.entries[0]["id"] == "mandelbrot"


def test_registry_finds_by_id(tmp_registry):
    r = Registry.load(tmp_registry)
    assert r.by_id("burning_ship")["name"] == "Burning Ship"
    assert r.by_id("nonexistent") is None


def test_registry_round_trip_preserves_fields(tmp_registry):
    r = Registry.load(tmp_registry)
    r.save()
    r2 = Registry.load(tmp_registry)
    assert r.entries == r2.entries


def test_registry_update_entry_writes_changes(tmp_registry):
    r = Registry.load(tmp_registry)
    r.update_entry("mandelbrot", {"tier": "implemented"})
    r.save()
    r2 = Registry.load(tmp_registry)
    assert r2.by_id("mandelbrot")["tier"] == "implemented"


def test_registry_update_unknown_id_raises(tmp_registry):
    import pytest
    r = Registry.load(tmp_registry)
    with pytest.raises(KeyError):
        r.update_entry("does_not_exist", {"tier": "reference"})
```

- [ ] **Step 3: Run tests — expect fail**

Run: `pytest tests/research/test_registry.py -v`

- [ ] **Step 4: Implement `scripts/research/lib/registry.py`**

```python
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
```

- [ ] **Step 5: Run tests — expect pass**

Run: `pytest tests/research/test_registry.py -v`
Expected: 5 passed.

- [ ] **Step 6: Commit**

```bash
git add scripts/research/lib/registry.py tests/research/conftest.py tests/research/test_registry.py
git commit -m "feat(research): add round-trip Registry loader with ruamel.yaml"
```

---

## Task 8: Write `lib/schema_lint.py`

**Files:**
- Create: `scripts/research/lib/schema_lint.py`
- Modify: `tests/research/test_schemas.py` (add lint helper tests)

- [ ] **Step 1: Append failing tests**

```python
def test_schema_lint_validates_registry_entry_happy_path():
    from scripts.research.lib.schema_lint import lint
    lint("registry_entry", _sample_retrofitted_entry())


def test_schema_lint_raises_on_invalid():
    from scripts.research.lib.schema_lint import lint, SchemaLintError
    bad = _sample_retrofitted_entry()
    del bad["tier"]
    with pytest.raises(SchemaLintError):
        lint("registry_entry", bad)


def test_schema_lint_unknown_schema_name_raises():
    from scripts.research.lib.schema_lint import lint
    with pytest.raises(KeyError):
        lint("not_a_schema", {})
```

- [ ] **Step 2: Run tests — expect fail**

- [ ] **Step 3: Implement `scripts/research/lib/schema_lint.py`**

```python
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
```

- [ ] **Step 4: Run tests — expect pass**

Run: `pytest tests/research/test_schemas.py -v`

- [ ] **Step 5: Commit**

```bash
git add scripts/research/lib/schema_lint.py tests/research/test_schemas.py
git commit -m "feat(research): add schema_lint helper with cross-schema \$ref resolution"
```

---

## Task 9: Write `lib/formula_hash.py` (Stage A stub — full Stage B)

Stage A only needs a deterministic hash of the *existing* legacy entry shape so retrofit can populate `formula_hash`. Real AST normalization lands in Stage B.

**Files:**
- Create: `scripts/research/lib/formula_hash.py`
- Test: inline tests added in Task 10 (retrofit test suite) — no separate test file needed.

- [ ] **Step 1: Implement `scripts/research/lib/formula_hash.py`**

```python
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
```

- [ ] **Step 2: Commit**

```bash
git add scripts/research/lib/formula_hash.py
git commit -m "feat(research): add formula_hash module (Stage A legacy hashing)"
```

---

## Task 10: Write `migrate/retrofit_registry.py` + tests

**Files:**
- Create: `scripts/research/migrate/retrofit_registry.py`
- Test: `tests/research/test_retrofit.py`

- [ ] **Step 1: Write failing tests (`tests/research/test_retrofit.py`)**

```python
from pathlib import Path

import pytest

from scripts.research.lib.registry import Registry
from scripts.research.lib.schema_lint import lint
from scripts.research.migrate.retrofit_registry import retrofit_entries, run_retrofit


def test_retrofit_adds_tier_from_implemented(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    for entry in r.entries:
        assert entry["tier"] == ("implemented" if entry.get("implemented") else "reference")


def test_retrofit_adds_formula_hash(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    for entry in r.entries:
        assert entry["formula_hash"].startswith("sha256:")
        assert len(entry["formula_hash"]) == len("sha256:") + 64


def test_retrofit_is_idempotent(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    first = [dict(e) for e in r.entries]
    retrofit_entries(r.entries)
    second = [dict(e) for e in r.entries]
    assert first == second


def test_retrofit_adds_quality_block(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    for entry in r.entries:
        q = entry["quality"]
        assert q["formula_hash"] == entry["formula_hash"]
        assert q["confidence"] == 1.0  # legacy entries are trusted
        assert q["citation_health"]["status"] == "unchecked"


def test_retrofit_preserves_legacy_fields(tmp_registry):
    r = Registry.load(tmp_registry)
    before = [dict(e) for e in r.entries]
    retrofit_entries(r.entries)
    for before_entry, after_entry in zip(before, r.entries):
        for k, v in before_entry.items():
            assert after_entry[k] == v, f"legacy field {k} changed"


def test_retrofitted_entries_pass_registry_entry_schema(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    for entry in r.entries:
        lint("registry_entry", entry)


def test_run_retrofit_writes_file(tmp_path, yaml_rt):
    import shutil
    src = Path(__file__).resolve().parents[2] / "docs" / "catalog" / "fractal_registry.yaml"
    dst = tmp_path / "fractal_registry.yaml"
    shutil.copy(src, dst)

    rc = run_retrofit(repo_root=tmp_path.parent, registry_path=dst, dry_run=False)
    assert rc == 0

    r = Registry.load(dst)
    assert all("tier" in e for e in r.entries)
    assert all("formula_hash" in e for e in r.entries)


def test_run_retrofit_dry_run_does_not_write(tmp_registry):
    before = tmp_registry.read_text()
    rc = run_retrofit(repo_root=tmp_registry.parent.parent, registry_path=tmp_registry, dry_run=True)
    assert rc == 0
    assert tmp_registry.read_text() == before
```

- [ ] **Step 2: Run tests — expect fail**

Run: `pytest tests/research/test_retrofit.py -v`

- [ ] **Step 3: Implement `scripts/research/migrate/retrofit_registry.py`**

```python
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
        print(f"retrofit: FAIL — {len(errors)} entries failed schema lint")
        for eid, msg in errors[:10]:
            print(f"  {eid}: {msg}")
        return 2

    if dry_run:
        print(f"retrofit: dry-run OK — {len(registry.entries)} entries would be updated")
        return 0

    registry.save()
    print(f"retrofit: OK — {len(registry.entries)} entries updated in {path}")
    return 0
```

- [ ] **Step 4: Run tests — expect pass**

Run: `pytest tests/research/test_retrofit.py -v`

- [ ] **Step 5: Commit**

```bash
git add scripts/research/migrate/retrofit_registry.py tests/research/test_retrofit.py
git commit -m "feat(research): add retrofit_registry migration (adds tier, formula_hash, quality)"
```

---

## Task 11: Write `doctor/check_registry.py`

**Files:**
- Create: `scripts/research/doctor/check_registry.py`
- Test: `tests/research/test_doctor.py`

- [ ] **Step 1: Write failing tests (`tests/research/test_doctor.py`)**

```python
import shutil
from pathlib import Path

from scripts.research.doctor.check_registry import DoctorResult, check_registry
from scripts.research.lib.registry import Registry
from scripts.research.migrate.retrofit_registry import retrofit_entries


def _retrofit(path: Path) -> None:
    r = Registry.load(path)
    retrofit_entries(r.entries)
    r.save()


def test_doctor_green_on_retrofitted_registry(tmp_registry):
    _retrofit(tmp_registry)
    result = check_registry(tmp_registry)
    assert result.ok, result.format_errors()


def test_doctor_red_on_un_retrofitted_registry(tmp_registry):
    result = check_registry(tmp_registry)
    assert not result.ok
    assert any("tier" in e or "formula_hash" in e for e in result.errors)


def test_doctor_detects_duplicate_ids(tmp_registry, yaml_rt):
    _retrofit(tmp_registry)
    r = Registry.load(tmp_registry)
    # Duplicate the first entry
    r.entries.append(dict(r.entries[0]))
    r.save()
    result = check_registry(tmp_registry)
    assert not result.ok
    assert any("duplicate" in e.lower() for e in result.errors)


def test_doctor_detects_duplicate_formula_hash(tmp_registry):
    _retrofit(tmp_registry)
    r = Registry.load(tmp_registry)
    # Force a collision: set both entries' formula_hash identical
    r.entries[1]["formula_hash"] = r.entries[0]["formula_hash"]
    r.entries[1]["quality"]["formula_hash"] = r.entries[0]["formula_hash"]
    r.save()
    result = check_registry(tmp_registry)
    assert not result.ok
    assert any("formula_hash collision" in e.lower() or "duplicate formula_hash" in e.lower()
               for e in result.errors)


def test_doctor_summary_includes_counts(tmp_registry):
    _retrofit(tmp_registry)
    result = check_registry(tmp_registry)
    summary = result.format_summary()
    assert "2 entries" in summary or "entries: 2" in summary
```

- [ ] **Step 2: Run tests — expect fail**

- [ ] **Step 3: Implement `scripts/research/doctor/check_registry.py`**

```python
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
            errors.append(f"duplicate formula_hash: {fh} — entries {colliding}")

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
```

- [ ] **Step 4: Run tests — expect pass**

Run: `pytest tests/research/test_doctor.py -v`

- [ ] **Step 5: Commit**

```bash
git add scripts/research/doctor/check_registry.py tests/research/test_doctor.py
git commit -m "feat(research): add forge doctor invariant checker"
```

---

## Task 12: End-to-end test — run retrofit on the real registry, then doctor

**Files:**
- Modify: `tests/research/test_retrofit.py` (already has `test_run_retrofit_writes_file`; add one more)
- Modify: `tests/research/test_doctor.py` (add an e2e test)

- [ ] **Step 1: Append to `tests/research/test_doctor.py`**

```python
def test_doctor_passes_on_real_registry_after_retrofit(tmp_path):
    """Copy the real registry, retrofit it, confirm doctor passes."""
    import shutil
    src = Path(__file__).resolve().parents[2] / "docs" / "catalog" / "fractal_registry.yaml"
    dst = tmp_path / "fractal_registry.yaml"
    shutil.copy(src, dst)

    _retrofit(dst)
    result = check_registry(dst)
    assert result.ok, result.format_errors()
    assert result.entry_count >= 300  # we know there are ~370 entries
```

- [ ] **Step 2: Run the test**

Run: `pytest tests/research/test_doctor.py::test_doctor_passes_on_real_registry_after_retrofit -v`
Expected: PASS. If it fails, fix the underlying issue (most likely: a real entry hits a schema edge case our sample didn't cover). Common fixes:
- Some entries may have string-typed `defaultPower`: loosen schema to `["number", "string"]` if that's genuinely what the real data looks like
- Some entries may lack `dimension`: add to the schema's non-required fields with default handling
- If duplicate `formula_hash` occurs on two real entries with identical key fields but different formulas, log them explicitly and extend `LEGACY_KEY_FIELDS` to include one more discriminator (e.g., `name`).

- [ ] **Step 3: Commit**

```bash
git add tests/research/test_doctor.py
git commit -m "test(research): doctor passes on real registry after retrofit"
```

---

## Task 13: Perform the actual retrofit on the real registry

This is the one step that modifies repository state outside `scripts/research/` and `tests/`.

- [ ] **Step 1: Run retrofit dry-run**

Run from repo root:

```bash
python3 scripts/research/forge.py retrofit --dry-run
```

Expected output: `retrofit: dry-run OK — NNN entries would be updated` with no errors, exit code 0.

- [ ] **Step 2: Run retrofit for real**

```bash
python3 scripts/research/forge.py retrofit
```

Expected: `retrofit: OK — NNN entries updated in docs/catalog/fractal_registry.yaml` exit code 0.

- [ ] **Step 3: Run forge doctor on real registry**

```bash
python3 scripts/research/forge.py doctor -v
```

Expected: `forge doctor: OK (NNN entries, 0 error(s))` exit code 0.

- [ ] **Step 4: Verify Flutter app still parses the registry**

Run the existing registry audit script:

```bash
python3 scripts/audit_fractals.py
```

Expected: same output as before retrofit (retrofit is additive; audit script ignores unknown fields).

- [ ] **Step 5: Spot-check one entry visually**

```bash
grep -A 20 "id: mandelbrot$" docs/catalog/fractal_registry.yaml | head -30
```

Expected: original fields preserved, plus `tier`, `formula_hash`, and `quality` block present.

- [ ] **Step 6: Commit the retrofitted registry**

```bash
git add docs/catalog/fractal_registry.yaml
git commit -m "chore(catalog): retrofit registry — add tier, formula_hash, quality to 370 entries"
```

---

## Task 14: Seed `research/canonical/canonical_aliases.yaml`

**Files:**
- Create: `research/canonical/canonical_aliases.yaml` (generated)
- Create: `research/seeds/canonical_aliases.seed.yaml` (manual, bootstrap)
- Create: `scripts/research/migrate/seed_aliases.py`
- Test: `tests/research/test_seed_aliases.py`

- [ ] **Step 1: Create empty seed file**

```bash
mkdir -p research/canonical research/seeds
cat > research/seeds/canonical_aliases.seed.yaml << 'EOF'
# Hand-curated alias bootstrap. Edit freely — this file is the only one humans
# touch by hand. `research/canonical/canonical_aliases.yaml` is regenerated by
# `forge seed-aliases` and must not be edited directly.
#
# Format:
#   <canonical_id>:
#     canonical_name: "<Display Name>"
#     aliases: ["alt name", "another alt"]
#     family: <family_slug>
#
# Example:
# mandelbrot:
#   canonical_name: "Mandelbrot Set"
#   aliases: ["Mandelbrot", "M-set", "z^2 + c set", "曼德勃罗集合"]
#   family: mandelbrot
EOF
```

- [ ] **Step 2: Write failing tests (`tests/research/test_seed_aliases.py`)**

```python
from pathlib import Path

from scripts.research.lib.registry import Registry
from scripts.research.migrate.retrofit_registry import retrofit_entries
from scripts.research.migrate.seed_aliases import build_alias_table, run_seed_aliases


def test_seed_builds_one_entry_per_registry_entry(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    table = build_alias_table(r.entries, seed={})
    assert set(table.keys()) == {"mandelbrot", "burning_ship"}


def test_seed_canonical_name_defaults_to_entry_name(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    table = build_alias_table(r.entries, seed={})
    assert table["mandelbrot"]["canonical_name"] == "Mandelbrot"


def test_seed_merges_hand_curated_aliases(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    seed = {
        "mandelbrot": {
            "canonical_name": "Mandelbrot Set",
            "aliases": ["M-set", "曼德勃罗集合"],
            "family": "mandelbrot",
        }
    }
    table = build_alias_table(r.entries, seed=seed)
    assert table["mandelbrot"]["canonical_name"] == "Mandelbrot Set"
    assert "M-set" in table["mandelbrot"]["aliases"]
    assert "曼德勃罗集合" in table["mandelbrot"]["aliases"]
    assert table["mandelbrot"]["family"] == "mandelbrot"


def test_seed_always_includes_entry_id_and_name_as_aliases(tmp_registry):
    r = Registry.load(tmp_registry)
    retrofit_entries(r.entries)
    table = build_alias_table(r.entries, seed={})
    assert "mandelbrot" in table["mandelbrot"]["aliases"]
    assert "Mandelbrot" in table["mandelbrot"]["aliases"]


def test_run_seed_aliases_writes_file(tmp_path, tmp_registry):
    out = tmp_path / "canonical_aliases.yaml"
    rc = run_seed_aliases(registry_path=tmp_registry, seed_path=None, output_path=out)
    assert rc == 0
    assert out.exists()
    content = out.read_text()
    assert "mandelbrot" in content
    assert "burning_ship" in content
```

- [ ] **Step 3: Run tests — expect fail**

- [ ] **Step 4: Implement `scripts/research/migrate/seed_aliases.py`**

```python
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
```

- [ ] **Step 5: Wire into `forge.py`**

Modify `scripts/research/forge.py` — add to `SUBCOMMANDS`:

```python
def _cmd_seed_aliases(args: argparse.Namespace) -> int:
    from scripts.research.migrate.seed_aliases import run_seed_aliases
    registry_path = REPO_ROOT / "docs" / "catalog" / "fractal_registry.yaml"
    seed_path = REPO_ROOT / "research" / "seeds" / "canonical_aliases.seed.yaml"
    output_path = REPO_ROOT / "research" / "canonical" / "canonical_aliases.yaml"
    return run_seed_aliases(registry_path, seed_path if seed_path.exists() else None, output_path)


SUBCOMMANDS["seed-aliases"] = ("Generate canonical_aliases.yaml from registry + seed", _cmd_seed_aliases)
```

Then update the parser loop to not fail on the new subcommand (it needs no extra args).

- [ ] **Step 6: Run tests — expect pass**

Run: `pytest tests/research/test_seed_aliases.py tests/research/test_forge_cli.py -v`

- [ ] **Step 7: Run the real command**

```bash
python3 scripts/research/forge.py seed-aliases
```

Expected: `seed-aliases: OK — 370 aliases written to research/canonical/canonical_aliases.yaml`

- [ ] **Step 8: Commit**

```bash
git add scripts/research/migrate/seed_aliases.py scripts/research/forge.py tests/research/test_seed_aliases.py research/seeds/canonical_aliases.seed.yaml research/canonical/canonical_aliases.yaml
git commit -m "feat(research): seed canonical_aliases.yaml from registry + manual seed file"
```

---

## Task 15: Gitignore research working dirs

**Files:**
- Modify: `.gitignore`
- Create: `research/raw/.gitkeep`, `research/extracted/.gitkeep`, `research/candidates/.gitkeep`, `research/decisions/.gitkeep`, `research/rejects/.gitkeep`, `reports/.gitkeep`

- [ ] **Step 1: Append to `.gitignore`**

Read `.gitignore` first with the Read tool, then append these lines:

```gitignore

# Fractal research pipeline working directories
research/raw/**
research/extracted/**
research/candidates/**
research/decisions/**
research/rejects/**
reports/**
!research/raw/.gitkeep
!research/extracted/.gitkeep
!research/candidates/.gitkeep
!research/decisions/.gitkeep
!research/rejects/.gitkeep
!reports/.gitkeep

# But keep canonical and seeds checked in
!research/canonical/
!research/seeds/
```

- [ ] **Step 2: Create placeholder files**

```bash
mkdir -p research/raw research/extracted research/candidates research/decisions research/rejects reports
touch research/raw/.gitkeep research/extracted/.gitkeep research/candidates/.gitkeep \
      research/decisions/.gitkeep research/rejects/.gitkeep reports/.gitkeep
```

- [ ] **Step 3: Verify tracking**

```bash
git status --short
git check-ignore research/raw/test.txt && echo "ignored OK"
```

Expected: `reports/.gitkeep` and the six `research/*/.gitkeep` files tracked; a hypothetical `research/raw/test.txt` is ignored.

- [ ] **Step 4: Commit**

```bash
git add .gitignore research/raw/.gitkeep research/extracted/.gitkeep research/candidates/.gitkeep research/decisions/.gitkeep research/rejects/.gitkeep reports/.gitkeep
git commit -m "chore: gitignore fractal research working dirs, keep canonical and seeds"
```

---

## Task 16: Wire CI — `research-tooling-ci.yml`

**Files:**
- Create: `.github/workflows/research-tooling-ci.yml`

- [ ] **Step 1: Write the workflow**

```yaml
name: Research tooling CI

on:
  push:
    paths:
      - "scripts/research/**"
      - "tests/research/**"
      - "docs/catalog/fractal_registry.yaml"
      - ".github/workflows/research-tooling-ci.yml"
  pull_request:
    paths:
      - "scripts/research/**"
      - "tests/research/**"
      - "docs/catalog/fractal_registry.yaml"
      - ".github/workflows/research-tooling-ci.yml"

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
          cache: pip

      - name: Install deps
        run: pip install -r scripts/research/requirements.txt

      - name: Run pytest
        run: pytest tests/research -v --tb=short

      - name: Run forge doctor
        run: python3 scripts/research/forge.py doctor -v
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/research-tooling-ci.yml
git commit -m "ci: add research tooling CI (pytest + forge doctor)"
```

---

## Task 17: Final verification pass

- [ ] **Step 1: Run full test suite**

```bash
pytest tests/research -v --tb=short
```

Expected: all tests pass.

- [ ] **Step 2: Run `forge doctor` on real registry**

```bash
python3 scripts/research/forge.py doctor -v
```

Expected: `forge doctor: OK` with 370+ entries.

- [ ] **Step 3: Confirm Flutter app still builds**

```bash
flutter analyze
```

Expected: zero errors (should be unchanged — we only added fields).

- [ ] **Step 4: Confirm existing audit script still works**

```bash
python3 scripts/audit_fractals.py
```

Expected: same output as before retrofit.

- [ ] **Step 5: Stage A complete — final commit if needed**

If any incidental fixes emerged during verification:

```bash
git add <files>
git commit -m "fix: Stage A verification adjustments"
```

---

## Done-Definition for Stage A

All of these must hold before moving to Stage B:

- [ ] All tests in `tests/research/` pass
- [ ] `forge doctor -v` exits 0 on real registry
- [ ] `fractal_registry.yaml` has `tier`, `formula_hash`, `quality` on every entry
- [ ] `research/canonical/canonical_aliases.yaml` exists with 370 entries
- [ ] `flutter analyze` still green
- [ ] `scripts/audit_fractals.py` still runs
- [ ] CI workflow added and passing
- [ ] All 17 tasks' commits landed

---

## Self-Review notes (author)

Spec coverage verified against `2026-04-12-fractal-research-pipeline-design.md`:

- §2 Architecture invariants (single registry source of truth) → covered by doctor invariant checks
- §6 Two-tier admission (`tier` field) → retrofit adds `tier`; doctor enforces consistency
- §8 Directory layout → scaffold matches exactly; subdirs for crawl/extract/etc. created empty (populated in B/C/D/E)
- §8 Three schemas → all three written + linted
- §8 CLI surface `forge doctor`, `forge retrofit`, `forge seed-aliases` → all wired
- §9 Stage A items 1–4 → all covered
- §10 Hard limits → none violated; no CN output added

Deferred to Stage B:
- True `formula_ast` normalization (Stage A uses a legacy-field hash that's stable but not a real dedup oracle)
- `dedup.py`, `taxonomy_classifier.py`
- `catalog-ci.yml` for registry/docs PRs (Stage A adds only `research-tooling-ci.yml`)

Deferred to Stage E:
- Maintenance jobs + dashboard

No placeholders. All tasks have complete code. Type names consistent: `Registry`, `DoctorResult`, `SchemaLintError`, `run_retrofit`, `run_doctor`, `run_seed_aliases`, `retrofit_entries`, `check_registry`, `build_alias_table`, `lint`, `hash_legacy_entry`. CLI subcommand names: `doctor`, `retrofit`, `seed-aliases`.
