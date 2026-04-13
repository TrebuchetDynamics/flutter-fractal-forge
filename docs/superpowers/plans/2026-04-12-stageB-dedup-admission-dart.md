# Fractal Pipeline — Stage B: Dedup, Admission & Dart Emission Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- []`) syntax for tracking.

**Goal:** Make the pipeline functional end-to-end for hand-written candidates — from a candidate YAML file through dedup, taxonomy assignment, human review, promotion to the registry, and full Dart module emission (per spec §14). Stage B does NOT include crawlers; by the end a human can hand-author a candidate file, run `forge batch` → `forge review` → `forge admit`, and get a new fractal fully wired into the Flutter app.

**Architecture:** Stage B builds on Stage A's foundation (schemas + registry + forge CLI). Adds: formula_ast normalizer + SHA-256 hasher, deterministic dedup pipeline (hash → fuzzy name → family classifier), taxonomy classifier (iteration_type → one of 19 categories), batch assembly + terminal review UI, `promote_candidate` orchestrator, and Jinja2-based Dart emitter producing 60-120 LOC per fractal with full module classes + typed presets/variants + scaffolded tests.

**Tech Stack:** Python 3.11, `ruamel.yaml` (existing), `jsonschema`/`referencing` (existing), **NEW**: `rapidfuzz==3.9.6` (fast fuzzy matching), `jinja2==3.1.4` (Dart templates), `sympy==1.13.2` (formula normalization). Dart output targets Flutter 3.x module system.

**Reference spec:** §2 architecture, §5 canonicalization, §6 admission gates, §14 Dart emission contract.

**Prerequisites:** Stage A complete (`forge doctor` green on 357-entry registry, all 49 tests passing).

---

## File Structure

### New Python modules

| File | Purpose | ~LOC |
|------|---------|------|
| `scripts/research/canonicalize/formula_normalizer.py` | AST normalize: alpha-rename, sort commutative ops, strip whitespace, canonical LaTeX-free form | 150 |
| `scripts/research/canonicalize/dedup.py` | 3-stage dedup pipeline: hash → fuzzy → family | 200 |
| `scripts/research/canonicalize/taxonomy_classifier.py` | iteration_type → category (1 of 19), with family detection | 180 |
| `scripts/research/review/build_batch.py` | Assemble weekly `candidates/{batch_id}/` from `extracted/` | 100 |
| `scripts/research/review/review_batch.py` | Interactive terminal UI (colored diff, dropdowns) | 250 |
| `scripts/research/admit/promote_candidate.py` | Orchestrator: load approved candidates, assign IDs, update registry, emit Dart, render thumbnails | 200 |
| `scripts/research/admit/thumbnail_render.py` | Flutter driver → headless render at 512×512, entropy check | 120 |
| `scripts/research/admit/emit_dart.py` | Jinja2 template dispatch: metadata.yaml → Dart module files | 180 |
| `scripts/research/admit/templates/dart/base.j2` | Common imports + module scaffold | 60 |
| `scripts/research/admit/templates/dart/escape_time_module.j2` | EscapeTimeModule subclass | 100 |
| `scripts/research/admit/templates/dart/raymarch_3d_module.j2` | Raymarched3DModule subclass | 110 |
| `scripts/research/admit/templates/dart/attractor_module.j2` | AttractorModule subclass | 90 |
| `scripts/research/admit/templates/dart/ifs_module.j2` | IFSModule subclass | 90 |
| `scripts/research/admit/templates/dart/l_system_module.j2` | LSystemModule subclass | 90 |
| `scripts/research/admit/templates/dart/cellular_module.j2` | CellularModule subclass | 90 |
| `scripts/research/admit/templates/dart/presets.j2` | Typed preset factory methods | 50 |
| `scripts/research/admit/templates/dart/variants.j2` | Typed variant factory methods | 50 |
| `scripts/research/admit/templates/dart/metadata.j2` | Immutable metadata record | 60 |
| `scripts/research/admit/templates/dart/module_test.j2` | Scaffolded smoke + round-trip test | 80 |
| `scripts/research/admit/templates/dart/base_classes/escape_time_module_base.dart` | Base class `EscapeTimeModule` if not already present in app | 120 |
| `scripts/research/admit/templates/dart/base_classes/raymarch_3d_module_base.dart` | `Raymarched3DModule` base | 130 |
| `scripts/research/admit/templates/dart/base_classes/attractor_module_base.dart` | `AttractorModule` base | 100 |
| `scripts/research/admit/templates/dart/base_classes/ifs_module_base.dart` | `IFSModule` base | 100 |
| `scripts/research/admit/templates/dart/base_classes/l_system_module_base.dart` | `LSystemModule` base | 100 |
| `scripts/research/admit/templates/dart/base_classes/cellular_module_base.dart` | `CellularModule` base | 100 |

### New tests

| File | Purpose |
|------|---------|
| `tests/research/test_formula_normalizer.py` | Normalization determinism, alpha-rename, commutative sort |
| `tests/research/test_dedup.py` | Hash collision, fuzzy match, family classifier; 3-stage integration |
| `tests/research/test_taxonomy_classifier.py` | 19-category mapping, uncertainty flagging |
| `tests/research/test_build_batch.py` | Batch assembly from extracted/, idempotent numbering |
| `tests/research/test_review_batch.py` | Non-interactive pathway for automated tests |
| `tests/research/test_promote_candidate.py` | End-to-end: candidate → registry entry + Dart files |
| `tests/research/test_emit_dart.py` | Template rendering, per-iteration-type, LOC target |
| `tests/research/fixtures/sample_candidates/` | 6 hand-crafted candidate YAMLs (one per template type) |

### CLI expansion

`scripts/research/forge.py` gains subcommands:

```bash
forge canonicalize                # dedup + taxonomy pass on extracted/
forge batch [--name <id>]         # build next candidates/ batch
forge review <batch_id>           # interactive review UI
forge admit <batch_id>            # promote approved candidates to registry + emit Dart
```

### CI expansion

`.github/workflows/research-tooling-ci.yml` adds a `dart-emit-ci` job: when admit is run against fixtures, `flutter analyze` must pass on generated Dart.

---

## Task 1: Add Stage-B dependencies and scaffold templates dir

**Files:**
- Modify: `scripts/research/requirements.txt`
- Create: `scripts/research/admit/templates/dart/`

- [ ] **Step 1: Append to `scripts/research/requirements.txt`:**

```
rapidfuzz==3.9.6
jinja2==3.1.4
sympy==1.13.2
Pillow==10.4.0
```

- [ ] **Step 2: Create template dir scaffolds**

```bash
mkdir -p scripts/research/admit/templates/dart/base_classes
mkdir -p tests/research/fixtures/sample_candidates
```

- [ ] **Step 3: Install deps and verify imports**

```bash
pip install -r scripts/research/requirements.txt
python3 -c "import rapidfuzz, jinja2, sympy, PIL; print('ok')"
```

- [ ] **Step 4: Commit**

```bash
git add scripts/research/requirements.txt scripts/research/admit/templates
git commit -m "chore(research): add Stage B deps (rapidfuzz, jinja2, sympy, Pillow)"
```

---

## Task 2: formula_normalizer.py

**Files:**
- Create: `scripts/research/canonicalize/formula_normalizer.py`
- Test: `tests/research/test_formula_normalizer.py`

Normalizes a `formula_ast` dict to a canonical string for hashing. Strategy: walk the AST, alpha-rename free variables (`z, c` → `v0, v1` in binding order), sort terms of commutative ops (+ and *), strip whitespace, emit prefix notation. Not a full CAS; only enough to catch equivalent formulas written differently.

- [ ] **Step 1: Write tests first**

```python
from scripts.research.canonicalize.formula_normalizer import normalize, hash_ast

def test_normalize_deterministic():
    ast = {"iteration_type": "escape_time", "variables": ["z","c"], "update": "z = z^2 + c", "init": "z = 0"}
    assert normalize(ast) == normalize(ast)

def test_normalize_alpha_rename_equivalent():
    ast1 = {"iteration_type": "escape_time", "variables": ["z","c"], "update": "z = z^2 + c", "init": "z = 0"}
    ast2 = {"iteration_type": "escape_time", "variables": ["w","k"], "update": "w = w^2 + k", "init": "w = 0"}
    assert normalize(ast1) == normalize(ast2)

def test_normalize_commutative_sort():
    ast1 = {"iteration_type": "escape_time", "variables": ["z","c"], "update": "z = z^2 + c"}
    ast2 = {"iteration_type": "escape_time", "variables": ["z","c"], "update": "z = c + z^2"}
    assert normalize(ast1) == normalize(ast2)

def test_hash_ast_is_sha256_prefix():
    ast = {"iteration_type": "escape_time", "variables": ["z","c"], "update": "z = z^2 + c"}
    h = hash_ast(ast)
    assert h.startswith("sha256:") and len(h) == 71
```

- [ ] **Step 2: Run tests, expect fail (module missing)**

- [ ] **Step 3: Implement (150 LOC outline)**

```python
"""Canonicalize formula_ast dicts into a deterministic string, then hash.

Strategy:
 1. Parse the `update` and `init` expressions with sympy.
 2. Alpha-rename free symbols to v0, v1, v2, ... in lexicographic order
    of first occurrence.
 3. Canonicalize via sympy.simplify + sympy.srepr (which sorts
    commutative args and strips whitespace).
 4. Emit a tuple (iteration_type, canonical_init, canonical_update),
    JSON-dump with sort_keys, then SHA-256.
"""
import hashlib, json
from typing import Any
import sympy as sp

def _parse(expr: str):
    # Strip `x = ` prefix if present
    if "=" in expr:
        _, expr = expr.split("=", 1)
    return sp.sympify(expr.strip(), evaluate=False) if expr.strip() else None

def _alpha_rename(expr, mapping: dict[str, sp.Symbol]) -> "sp.Expr":
    if expr is None:
        return None
    symbols = sorted(expr.free_symbols, key=lambda s: s.name)
    for s in symbols:
        if s.name not in mapping:
            mapping[s.name] = sp.Symbol(f"v{len(mapping)}")
    return expr.xreplace({s: mapping[s.name] for s in symbols})

def normalize(ast: dict[str, Any]) -> str:
    update_raw = ast.get("update", "")
    init_raw = ast.get("init", "")
    mapping: dict[str, sp.Symbol] = {}
    update = _alpha_rename(_parse(update_raw), mapping) if update_raw else None
    init = _alpha_rename(_parse(init_raw), mapping) if init_raw else None

    tup = (
        ast.get("iteration_type", "other"),
        sp.srepr(sp.simplify(init)) if init is not None else "",
        sp.srepr(sp.simplify(update)) if update is not None else "",
    )
    return json.dumps(tup, sort_keys=True, separators=(",", ":"))

def hash_ast(ast: dict[str, Any]) -> str:
    normal = normalize(ast).encode("utf-8")
    return "sha256:" + hashlib.sha256(normal).hexdigest()
```

- [ ] **Step 4: Run tests, expect pass**

- [ ] **Step 5: Update `scripts/research/lib/formula_hash.py` to re-export `hash_ast`** so retrofit Stage B can call `formula_hash.hash_formula_ast = formula_normalizer.hash_ast`. Keep `hash_legacy_entry` for legacy cases.

- [ ] **Step 6: Commit**

```bash
git add scripts/research/canonicalize/formula_normalizer.py scripts/research/lib/formula_hash.py tests/research/test_formula_normalizer.py
git commit -m "feat(research): formula_ast normalizer + SHA-256 hasher (sympy-based)"
```

---

## Task 3: taxonomy_classifier.py

**Files:**
- Create: `scripts/research/canonicalize/taxonomy_classifier.py`
- Test: `tests/research/test_taxonomy_classifier.py`

Maps `formula_ast.iteration_type` + ad-hoc keywords → one of 19 categories. Deterministic rules; uncertainty flag when confidence < 0.8.

- [ ] **Step 1: Define the 19-category table** (inline constant in the module):

```python
CATEGORIES = {
    "I": "Escape-Time (Complex Plane)",
    "II": "Newton / Root-Finding",
    "III": "Strange Attractors",
    "IV": "IFS & Geometric Construction",
    "V": "L-Systems & Space-Filling",
    "VI": "3D Raymarching & Hypercomplex",
    "VII": "Cellular & Stochastic",
    "VIII": "Trigonometric & Transcendental",
    "IX": "Lyapunov & Stability",
    "X": "Tiling & Aperiodic",
    "XI": "Deep Chaos & Flows",
    "XII": "High-Dimensional Algebra",
    "XIII": "Other",
    "XIV": "Physical & Constructed",
    "XV": "Reaction-Diffusion & Chemical",
    "XVI": "Musical & Rhythmic",
    "XVII": "Architectural & Structural",
    "XVIII": "Biological & Organic",
    "XIX": "Number-Theory Fractals",
}

ITERATION_TYPE_MAP = {
    "escape_time": ("I", 1.0),
    "newton": ("II", 1.0),
    "strange_attractor": ("III", 1.0),
    "ifs": ("IV", 1.0),
    "l_system": ("V", 1.0),
    "raymarch_3d": ("VI", 1.0),
    "cellular": ("VII", 1.0),
    "lyapunov": ("IX", 1.0),
    "tiling": ("X", 1.0),
    "reaction_diffusion": ("XV", 1.0),
    "number_theory": ("XIX", 1.0),
    "other": ("XIII", 0.5),
}
```

- [ ] **Step 2: Write tests**

```python
def test_each_iteration_type_maps_to_one_category():
    for it, (roman, conf) in ITERATION_TYPE_MAP.items():
        result = classify({"iteration_type": it})
        assert result["category_roman"] == roman
        assert result["confidence"] == conf

def test_uncertain_flag_on_other():
    result = classify({"iteration_type": "other"})
    assert result["uncertain"] is True

def test_family_detection_mandelbrot():
    ast = {"iteration_type": "escape_time", "update": "z = z**2 + c", "variables": ["z","c"]}
    result = classify(ast)
    assert result["family"] == "mandelbrot"
```

- [ ] **Step 3: Implement**

```python
def classify(formula_ast: dict) -> dict:
    it = formula_ast.get("iteration_type", "other")
    roman, conf = ITERATION_TYPE_MAP.get(it, ("XIII", 0.3))
    family = _detect_family(formula_ast)
    return {
        "category_roman": roman,
        "category_name": CATEGORIES[roman],
        "confidence": conf,
        "uncertain": conf < 0.8,
        "family": family,
    }

def _detect_family(ast: dict) -> str | None:
    u = (ast.get("update") or "").replace(" ", "").lower()
    if "z**2+c" in u or "z^2+c" in u: return "mandelbrot"
    if "conj(z)**2+c" in u or "conj(z)^2+c" in u: return "tricorn"
    if "abs(re(z))" in u and "abs(im(z))" in u: return "burning_ship"
    if "z**3" in u or "z^3" in u: return "multibrot_cubic"
    # ... more families
    return None
```

- [ ] **Step 4: Run tests; commit**

```bash
git add scripts/research/canonicalize/taxonomy_classifier.py tests/research/test_taxonomy_classifier.py
git commit -m "feat(research): taxonomy classifier (iteration_type → 19 categories + family detection)"
```

---

## Task 4: dedup.py 3-stage pipeline

**Files:**
- Create: `scripts/research/canonicalize/dedup.py`
- Test: `tests/research/test_dedup.py`

Stage 1: Formula hash exact match (via `formula_normalizer.hash_ast`). Stage 2: Name/alias fuzzy match using rapidfuzz over `canonical_aliases.yaml`. Stage 3: Family classifier — if same family + numeric-only param diff → flag as variant.

- [ ] **Step 1: Tests**

```python
def test_dedup_hash_exact_collision_auto_merges():
    existing = [{"id":"f001_mandel", "formula_hash":"sha256:..."}]  # known hash
    candidate = {"formula_ast": {...same as existing...}, "proposed_name": "M-set"}
    result = dedup(candidate, existing, aliases={})
    assert result.action == "auto_merge"
    assert result.merge_into == "f001_mandel"

def test_dedup_fuzzy_name_flags_review():
    existing = [{"id":"f001_mandel", "name":"Mandelbrot Set"}]
    candidate = {"proposed_name": "Mandelbrot-Set", "formula_ast": {"iteration_type":"escape_time","update":"z = z^3 + c"}}  # different formula
    aliases = {"f001_mandel":{"canonical_name":"Mandelbrot Set","aliases":["Mandelbrot","M-set"]}}
    result = dedup(candidate, existing, aliases)
    assert result.action == "review_fuzzy"
    assert result.suggested_id == "f001_mandel"

def test_dedup_new_passes_through():
    result = dedup(candidate_with_unique_hash, existing=[], aliases={})
    assert result.action == "new"
```

- [ ] **Step 2: Implement**

```python
from dataclasses import dataclass
from rapidfuzz import fuzz, process
from scripts.research.canonicalize.formula_normalizer import hash_ast
from scripts.research.canonicalize.taxonomy_classifier import classify

@dataclass
class DedupResult:
    action: str  # new | auto_merge | review_fuzzy | review_family
    merge_into: str | None = None
    suggested_id: str | None = None
    reason: str = ""

def dedup(candidate: dict, existing: list[dict], aliases: dict) -> DedupResult:
    # Stage 1: hash exact
    c_hash = hash_ast(candidate["formula_ast"])
    for e in existing:
        if e.get("formula_hash") == c_hash:
            return DedupResult("auto_merge", merge_into=e["id"], reason=f"formula_hash match")

    # Stage 2: fuzzy name
    all_aliases = []
    for eid, info in aliases.items():
        for a in info.get("aliases", []):
            all_aliases.append((a, eid))
    if all_aliases:
        choices = [a[0] for a in all_aliases]
        best = process.extractOne(candidate["proposed_name"], choices, scorer=fuzz.token_set_ratio)
        if best and best[1] >= 85:
            eid = all_aliases[best[2]][1]
            return DedupResult("review_fuzzy", suggested_id=eid, reason=f"fuzzy {best[1]}%")

    # Stage 3: family
    fam = classify(candidate["formula_ast"]).get("family")
    if fam:
        same_family = [e for e in existing if e.get("family") == fam]
        if same_family:
            return DedupResult("review_family", suggested_id=same_family[0]["id"], reason=f"family={fam}")

    return DedupResult("new")
```

- [ ] **Step 3: Commit**

```bash
git add scripts/research/canonicalize/dedup.py tests/research/test_dedup.py
git commit -m "feat(research): dedup pipeline (hash → fuzzy → family, 3 stages)"
```

---

## Task 5: build_batch.py

Gathers candidates from `research/extracted/` into a weekly `research/candidates/{batch_id}/` directory. Throttles at 500/week.

- [ ] **Step 1: Tests + implementation (100 LOC).**

```python
def build_batch(extracted_dir, candidates_dir, limit=500, batch_id=None):
    """Move up to `limit` oldest candidates from extracted/ to a new batch subdir.

    Returns the batch path. Idempotent if called with same batch_id."""
```

- [ ] **Step 2: Wire `forge batch` subcommand in forge.py.**

- [ ] **Step 3: Commit.**

---

## Task 6: review_batch.py (interactive terminal UI)

**Files:**
- Create: `scripts/research/review/review_batch.py`
- Test: `tests/research/test_review_batch.py`

Colored terminal diff: shows new vs merge candidates, lets reviewer approve / reject / override category / edit name. Writes verdicts to `research/decisions/{batch_id}.yaml`. Supports non-interactive `--auto-approve-new` flag for testing.

- [ ] **Step 1: Tests (use --auto-approve-new for automation).**

- [ ] **Step 2: Implement (250 LOC). Use `rich` library for colors if already installed, else raw ANSI.** (Add `rich==13.7.1` to requirements if using.)

- [ ] **Step 3: Wire `forge review <batch_id>` subcommand.**

- [ ] **Step 4: Commit.**

---

## Task 7: emit_dart.py — Jinja2 Dart emitter (§14)

**Files:**
- Create: `scripts/research/admit/emit_dart.py`
- Create: 9 Jinja2 templates in `scripts/research/admit/templates/dart/`
- Test: `tests/research/test_emit_dart.py`

This is the heart of §14. Given a metadata.yaml + formula_ast + iteration_type, generate a complete Dart module + presets + variants + metadata + scaffolded test. Output 60-120 LOC per fractal.

- [ ] **Step 1: Write base template `base.j2`:**

```jinja
// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage ({{ admitted_at }}).
// Regenerate via: forge admit <batch_id>

import 'package:flutter/widgets.dart';
import '../base_classes/{{ base_class | snake }}_base.dart';
import '{{ id }}_presets.dart';
import '{{ id }}_variants.dart';
import '{{ id }}_metadata.dart';

{% block module_class %}{% endblock %}
```

- [ ] **Step 2: Write per-iteration-type templates (escape_time, raymarch_3d, attractor, ifs, l_system, cellular).**

Example `escape_time_module.j2`:

```jinja
{% extends "base.j2" %}
{% block module_class %}
class {{ class_name }} extends EscapeTimeModule {
  {{ class_name }}() : super(
    id: '{{ id }}',
    shader: '{{ shader }}',
    defaults: const {{ class_name }}Defaults(),
  );

  @override
  {{ class_name }}Metadata get metadata => {{ class_name }}Metadata.instance;

  @override
  List<{{ class_name }}Preset> get presets => {{ class_name }}Presets.all;

  @override
  List<{{ class_name }}Variant> get variants => {{ class_name }}Variants.all;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', {{ defaults.power }});
    p.setFloat('bailout', {{ defaults.bailout }});
    p.setInt('iterations', {{ defaults.iterations }});
    {% for k, v in extra_uniforms.items() %}
    p.setFloat('{{ k }}', {{ v }});
    {% endfor %}
  }

  {% if deep_zoom_capable %}
  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;
  {% endif %}
}

class {{ class_name }}Defaults {
  const {{ class_name }}Defaults();
  double get power => {{ defaults.power }};
  double get bailout => {{ defaults.bailout }};
  int get iterations => {{ defaults.iterations }};
}
{% endblock %}
```

- [ ] **Step 3: Write presets.j2:**

```jinja
// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class {{ class_name }}Preset {
  final String id;
  final String name;
  final Map<String, double> params;
  const {{ class_name }}Preset({required this.id, required this.name, required this.params});
}

class {{ class_name }}Presets {
  {% for p in presets %}
  static const {{ class_name }}Preset {{ p.id | camel }} = {{ class_name }}Preset(
    id: '{{ p.id }}',
    name: '{{ p.name }}',
    params: {
      {% for k, v in p.params.items() %}'{{ k }}': {{ v }},{% endfor %}
    },
  );
  {% endfor %}

  static const List<{{ class_name }}Preset> all = [
    {% for p in presets %}{{ p.id | camel }},{% endfor %}
  ];
}
```

- [ ] **Step 4: Write variants.j2 (similar structure).**

- [ ] **Step 5: Write metadata.j2:**

```jinja
// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class Citation {
  final String? author;
  final String? title;
  final int? year;
  final String url;
  const Citation({this.author, this.title, this.year, required this.url});
}

@immutable
class {{ class_name }}Metadata {
  static const instance = {{ class_name }}Metadata._();
  const {{ class_name }}Metadata._();

  String get id => '{{ id }}';
  String get name => '{{ name }}';
  String get category => '{{ category }}';
  String? get subcategory => {{ subcategory | q_or_null }};
  String get family => '{{ family }}';
  List<String> get aliases => const [{% for a in aliases %}'{{ a }}',{% endfor %}];
  List<Citation> get references => const [
    {% for r in references %}
    Citation(
      {% if r.author %}author: '{{ r.author }}',{% endif %}
      {% if r.title %}title: "{{ r.title }}",{% endif %}
      {% if r.year %}year: {{ r.year }},{% endif %}
      url: '{{ r.url }}',
    ),
    {% endfor %}
  ];
}
```

- [ ] **Step 6: Write module_test.j2:**

```jinja
// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/{{ category_slug }}/{{ id }}/{{ id }}_module.dart';

void main() {
  test('{{ class_name }} instantiates', () {
    final m = {{ class_name }}();
    expect(m.id, '{{ id }}');
    expect(m.shader, '{{ shader }}');
  });

  test('{{ class_name }} params round-trip', () {
    final m = {{ class_name }}();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.params, isA<Map<String, double>>());
    }
  });
}
```

- [ ] **Step 7: Implement `emit_dart.py`:**

```python
"""Emit rich Dart per §14 from a metadata.yaml + formula_ast."""
from pathlib import Path
from jinja2 import Environment, FileSystemLoader, select_autoescape
import re

TEMPLATE_DIR = Path(__file__).parent / "templates" / "dart"

def _env():
    env = Environment(
        loader=FileSystemLoader(TEMPLATE_DIR),
        autoescape=select_autoescape(disabled_extensions=("j2",)),
        trim_blocks=True, lstrip_blocks=True,
    )
    env.filters["snake"] = lambda s: re.sub(r"(?<!^)(?=[A-Z])", "_", s).lower()
    env.filters["camel"] = lambda s: "".join(x.title() for x in s.split("_"))
    env.filters["q_or_null"] = lambda s: f"'{s}'" if s else "null"
    return env

def emit(
    candidate: dict,
    registry_entry: dict,
    iteration_type: str,
    output_root: Path,
) -> list[Path]:
    """Render all Dart files for one admitted fractal. Returns paths written."""
    env = _env()
    ctx = _build_context(candidate, registry_entry, iteration_type)

    files: list[tuple[str, str]] = [
        ("module.dart", f"{iteration_type}_module.j2"),
        ("presets.dart", "presets.j2"),
        ("variants.dart", "variants.j2"),
        ("metadata.dart", "metadata.j2"),
    ]
    written = []
    id_ = ctx["id"]
    module_dir = output_root / "lib" / "core" / "modules" / ctx["category_slug"] / id_
    module_dir.mkdir(parents=True, exist_ok=True)

    for suffix, template in files:
        path = module_dir / f"{id_}_{suffix}"
        content = env.get_template(template).render(**ctx)
        path.write_text(content)
        written.append(path)

    # Test scaffold
    test_dir = output_root / "test" / "modules" / id_
    test_dir.mkdir(parents=True, exist_ok=True)
    test_path = test_dir / f"{id_}_module_test.dart"
    test_path.write_text(env.get_template("module_test.j2").render(**ctx))
    written.append(test_path)

    return written

def _build_context(candidate, registry_entry, iteration_type):
    class_name = "".join(p.title() for p in registry_entry["id"].split("_"))
    return {
        "id": registry_entry["id"],
        "class_name": class_name,
        "name": registry_entry["name"],
        "category": registry_entry["category"],
        "category_slug": _slugify(registry_entry["category"]),
        "subcategory": registry_entry.get("subcategory"),
        "family": registry_entry.get("family", ""),
        "aliases": registry_entry.get("aliases", []),
        "shader": registry_entry.get("shader", f"shaders/{registry_entry['id']}_gpu.frag"),
        "defaults": {
            "power": registry_entry.get("defaultPower", 2.0),
            "bailout": registry_entry.get("defaultBailout", 2.0),
            "iterations": int(registry_entry.get("defaultIterations", 500)),
        },
        "extra_uniforms": candidate.get("extra_uniforms", {}),
        "presets": candidate.get("presets", []),
        "variants": candidate.get("variants", []),
        "references": candidate.get("references", []),
        "deep_zoom_capable": iteration_type == "escape_time",
        "base_class": f"{_cap(iteration_type)}Module",
        "admitted_at": "{{ CI-injected timestamp }}",
    }

def _slugify(cat): return re.sub(r"[^a-z0-9]+", "_", cat.lower()).strip("_")
def _cap(s): return "".join(x.title() for x in s.split("_"))
```

- [ ] **Step 8: Tests — render against a fixture candidate and assert file count + LOC target.**

```python
def test_emit_dart_produces_all_5_files(tmp_path, sample_escape_time_candidate):
    files = emit(sample_escape_time_candidate, sample_registry_entry, "escape_time", tmp_path)
    assert len(files) == 5  # module + presets + variants + metadata + test
    assert all(f.exists() for f in files)

def test_emit_dart_hits_loc_target(tmp_path, sample_escape_time_candidate):
    files = emit(sample_escape_time_candidate, sample_registry_entry, "escape_time", tmp_path)
    module_loc = len((tmp_path / "lib" / "core" / "modules" / "i_escape_time_complex_plane" / "f001_mandel" / "f001_mandel_module.dart").read_text().splitlines())
    assert 60 <= module_loc <= 120
```

- [ ] **Step 9: Commit.**

---

## Task 8: Dart base classes

Create 6 base class files that the emitted modules import:

- `escape_time_module_base.dart` — abstract `EscapeTimeModule`
- `raymarch_3d_module_base.dart`
- `attractor_module_base.dart`
- `ifs_module_base.dart`
- `l_system_module_base.dart`
- `cellular_module_base.dart`

Path: `lib/core/modules/base_classes/` (committed in the Flutter app tree, not templates).

- [ ] **Step 1: Check if any base classes already exist in the Flutter app.**

Search with `grep -r "abstract class.*Module" lib/core/modules/` — if Mandelbulb etc. already use a base, reuse it. Otherwise create new.

- [ ] **Step 2: Write base class (example for EscapeTimeModule).**

```dart
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

enum DeepZoomStrategy { none, perturbation, seriesApproximation }

@immutable
abstract class EscapeTimeModule {
  final String id;
  final String shader;
  final Object defaults;
  const EscapeTimeModule({required this.id, required this.shader, required this.defaults});

  Object get metadata;
  List<Object> get presets;
  List<Object> get variants;
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.none;
  void configureShader(Object p);
}

abstract class ShaderParams {
  void setFloat(String name, double value);
  void setInt(String name, int value);
}
```

- [ ] **Step 3: Verify `flutter analyze` green on new base classes.**

- [ ] **Step 4: Commit.**

---

## Task 9: thumbnail_render.py

Uses Flutter test driver to render at 512×512 → PNG. Computes Shannon entropy on the result; rejects if entropy < 3.0 (all-black or all-noise).

- [ ] **Step 1: Research Flutter headless render approach** — likely `flutter test --device=linux` or `flutter drive` with a minimal app that reads `metadata.yaml` and renders the shader offscreen.

- [ ] **Step 2: Implement wrapper in Python that shells out to Flutter.**

```python
def render_thumbnail(id: str, metadata_path: Path, output_path: Path) -> dict:
    """Render a 512x512 PNG. Returns {entropy: float, ok: bool}."""
```

- [ ] **Step 3: Tests: mock the subprocess call, assert entropy check logic.**

- [ ] **Step 4: Commit.**

---

## Task 10: promote_candidate.py orchestrator

Ties everything together.

- [ ] **Step 1: Implement `promote(batch_path, registry_path, decisions)`:**

```python
def promote(batch_path: Path, registry_path: Path, decisions: dict) -> list[str]:
    """Admit each approved candidate. Returns list of admitted IDs."""
    registry = Registry.load(registry_path)
    admitted = []
    for candidate_file, verdict in decisions.items():
        if verdict["action"] == "reject": continue
        if verdict["action"] == "auto_merge": continue  # no new entry

        candidate = load_yaml(candidate_file)
        new_id = _assign_id(registry, candidate, verdict)
        entry = _build_registry_entry(candidate, new_id, verdict)

        # Schema lint
        lint("registry_entry", entry)
        registry.entries.append(entry)

        # Emit Dart
        emit(candidate, entry, candidate["formula_ast"]["iteration_type"], REPO_ROOT)

        # Thumbnail (implemented tier only)
        if _has_shader(candidate):
            render_thumbnail(new_id, metadata_path=..., output_path=...)

        admitted.append(new_id)

    registry.save()
    return admitted
```

- [ ] **Step 2: Tests using fixture candidates end-to-end.**

- [ ] **Step 3: Wire `forge admit <batch_id>` subcommand.**

- [ ] **Step 4: Commit.**

---

## Task 11: Sample candidate fixtures

**Files:**
- Create: `tests/research/fixtures/sample_candidates/f_sample_mandelbrot.yaml`
- Create: `tests/research/fixtures/sample_candidates/f_sample_burning_ship.yaml`
- Create: `tests/research/fixtures/sample_candidates/f_sample_mandelbulb.yaml` (raymarch_3d)
- Create: `tests/research/fixtures/sample_candidates/f_sample_lorenz.yaml` (attractor)
- Create: `tests/research/fixtures/sample_candidates/f_sample_sierpinski.yaml` (ifs)
- Create: `tests/research/fixtures/sample_candidates/f_sample_koch.yaml` (l_system)

Each exercises a different template path. Used by test_promote_candidate and test_emit_dart.

- [ ] **Step 1: Hand-author the 6 YAMLs with realistic fields.**

- [ ] **Step 2: Commit.**

---

## Task 12: CI expansion — Dart analyze on emitted output

Extend `.github/workflows/research-tooling-ci.yml`:

```yaml
jobs:
  test:
    # ... existing ...
  dart-emit-check:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r scripts/research/requirements.txt
      - name: Emit from fixtures
        run: |
          for f in tests/research/fixtures/sample_candidates/*.yaml; do
            python3 -m scripts.research.admit.emit_dart --candidate "$f" --dry-run-out /tmp/emit/
          done
      - name: Flutter analyze on emitted Dart
        run: |
          mkdir -p /tmp/flutter-check/lib/core/modules
          cp -r /tmp/emit/* /tmp/flutter-check/lib/core/modules/
          cd /tmp/flutter-check && flutter analyze
```

- [ ] **Step 1: Add the job, test locally, commit.**

---

## Task 13: End-to-end test: hand-write candidate → admit → flutter analyze

This is the Stage B done-definition test. A human writes a candidate YAML by hand, places it in `research/candidates/stage_b_manual/`, runs `forge admit stage_b_manual`, and confirms:

1. Registry gains one new entry
2. Dart files appear in `lib/core/modules/{category}/{id}/`
3. `flutter analyze` still green
4. Scaffolded test passes

- [ ] **Step 1: Write fixture + end-to-end test.**

- [ ] **Step 2: Manual dry-run on a real candidate (e.g., admit a new `barnsley_m1` fractal).**

- [ ] **Step 3: Commit and tag Stage B done.**

---

## Done-Definition for Stage B

- [ ] `formula_normalizer.normalize()` returns identical hash for alpha-equivalent ASTs (≥20 paired test cases)
- [ ] `dedup()` correctly classifies hash-match, fuzzy-match, family-match, and new candidates
- [ ] `taxonomy_classifier` maps all 12 iteration_type enums + a synthesized "other" case
- [ ] `emit_dart.emit()` produces 5 files per candidate totaling 60-120 LOC for the module file specifically
- [ ] 6 fixture candidates render without Dart analyzer errors
- [ ] `forge admit stage_b_manual` on a hand-authored candidate: registry entry added + Dart generated + `flutter analyze` green
- [ ] CI job `dart-emit-check` passes on main
- [ ] Test count: ≥ 90 (Stage A had 49, Stage B adds ~40+)

## Risks

| Risk | Mitigation |
|------|-----------|
| Sympy can't parse some formulas (e.g., quaternion syntax) | Fall back to string-normalized hash with explicit "unparseable" flag; skip dedup family stage |
| Flutter headless render brittle in CI | Start with entropy check skipped in CI, run only locally; add later |
| Dart base classes conflict with existing app patterns | Audit existing custom modules first (Mandelbulb, Phoenix, Nova) before creating bases |
| LOC target 60-120 hard to hit for minimal fractals | Relax to 40-150; the goal is "rich" not "padded" |
