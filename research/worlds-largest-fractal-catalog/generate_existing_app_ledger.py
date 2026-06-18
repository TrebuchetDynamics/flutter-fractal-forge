#!/usr/bin/env python3
"""Generate a count-safe ledger from existing generated app modules.

This creates a discovery ledger from generated metadata. Entries are promoted
only when they have:
- generated metadata
- generated module file
- shader asset path that exists
- thumbnail asset that exists

Entries with metadata+thumbnail but missing shader remain source leads and do
not count. It does not count presets. Variants files are intentionally ignored.
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "research/worlds-largest-fractal-catalog/curated-entry-ledger.existing-app.json"
META_ROOT = ROOT / "lib/core/modules"

CATEGORY_TO_TARGET_FAMILY = {
    "Escape-Time (Complex Plane)": "escape_time_polynomial_complex",
    "Convergent/Root-Finding": "root_finding_polynomiography",
    "Strange Attractors": "strange_attractors_maps",
    "IFS & Geometric Construction": "ifs_geometric",
    "L-Systems & Space-Filling Curves": "l_systems_plants_curves",
    "3D Raymarching & Hypercomplex": "distance_estimated_3d_raymarch",
    "Trigonometric & Transcendental": "rational_transcendental_maps",
    "Advanced Rational & Polynomial": "rational_transcendental_maps",
    "Lyapunov & Stability": "number_theory_special_functions",
    "Deep Chaos & Flows": "strange_attractors_maps",
    "High-Dimensional Algebra": "number_theory_special_functions",
    "Tiling & Graph Fractals": "tilings_substitution_graphs",
    "Cellular & Stochastic": "cellular_automata",
    "Number-Theory Fractals": "number_theory_special_functions",
}

CATEGORY_TO_IDENTITY_TYPE = {
    "IFS & Geometric Construction": "transform_system",
    "L-Systems & Space-Filling Curves": "grammar",
    "Tiling & Graph Fractals": "rule",
    "Cellular & Stochastic": "rule",
    "Strange Attractors": "map",
    "Deep Chaos & Flows": "map",
    "Lyapunov & Stability": "map",
}

MODULE_BASE_TO_RENDERER = {
    "EscapeTimeModule": "fragment_shader",
    "RaymarchModule": "raymarch_shader",
    "CellularModule": "grid_simulation",
    "AttractorModule": "point_accumulation",
    "IFSModule": "point_mesh_accumulation",
    "LSystemModule": "grammar_turtle_mesh",
}


def match(pattern: str, text: str) -> str | None:
    found = re.search(pattern, text, flags=re.MULTILINE | re.DOTALL)
    return found.group(1).strip() if found else None


def first_reference_url(metadata_text: str) -> str | None:
    return match(r"url:\s*'([^']+)'", metadata_text)


def module_base(module_text: str) -> str | None:
    found = re.search(r"class\s+\w+\s+extends\s+(\w+)", module_text)
    return found.group(1) if found else None


def renderer_note(module_text: str) -> str:
    base = module_base(module_text)
    if base and base in MODULE_BASE_TO_RENDERER:
        return MODULE_BASE_TO_RENDERER[base]
    return "shader_or_app_renderer"


def build_entry(metadata_path: Path) -> dict | None:
    metadata_text = metadata_path.read_text(encoding="utf-8")
    module_path = metadata_path.with_name(metadata_path.name.replace("_metadata.dart", "_module.dart"))
    if not module_path.exists():
        return None
    module_text = module_path.read_text(encoding="utf-8")

    stable_id = match(r"String\s+get\s+id\s*=>\s*'([^']+)'", metadata_text)
    name = match(r"String\s+get\s+name\s*=>\s*'([^']+)'", metadata_text)
    category = match(r"String\s+get\s+category\s*=>\s*'([^']+)'", metadata_text)
    family = match(r"String\s+get\s+family\s*=>\s*'([^']+)'", metadata_text)
    shader = match(r"shader:\s*'([^']+)'", module_text)
    if not stable_id or not name or not category or not shader:
        return None

    shader_path = ROOT / shader
    thumbnail = ROOT / f"assets/catalog_thumbs/{stable_id}.png"
    if not thumbnail.exists():
        return None

    shader_exists = shader_path.exists()

    target_family = CATEGORY_TO_TARGET_FAMILY.get(category)
    if target_family is None:
        return None
    identity_type = CATEGORY_TO_IDENTITY_TYPE.get(category, "named_stable_variant")
    ref_url = first_reference_url(metadata_text)
    source = str(metadata_path.relative_to(ROOT))

    return {
        "stable_id": stable_id,
        "display_name": name,
        "family": target_family,
        "mathematical_identity_type": identity_type,
        "formula_or_rule": f"Named stable fractal identity: {name}; category: {category}; source family: {family or category}",
        "renderer_path": shader if shader_exists else "unassigned",
        "parameter_schema": {"source": str(module_path.relative_to(ROOT)), "renderer_kind": renderer_note(module_text), "declared_shader": shader},
        "provenance": {
            "source_type": "app_generated_metadata",
            "source": source,
            **({"doi": ref_url} if ref_url and ref_url.startswith("10.") else {}),
            **({"url": ref_url} if ref_url and not ref_url.startswith("10.") else {}),
            "reuse_decision": "metadata and renderer are local generated project artifacts; count only the named formula/rule identity, not presets or random seeds",
        },
        "license_context": "local generated app artifact; referenced formula/rule identity only; no upstream source copied by this ledger",
        "thumbnail_plan": str(thumbnail.relative_to(ROOT)),
        "validation": {
            "status": "validated" if shader_exists else "not_validated",
            "signals": [
                "metadata file exists",
                "module file exists",
                *( ["shader asset exists"] if shader_exists else ["declared shader asset missing"] ),
                "thumbnail asset exists",
                "presets ignored for counted-entry total",
            ],
        },
        "accessibility_label": f"{name} fractal" if shader_exists else "",
        "counted_entry": shader_exists,
        "ingest_status": "promoted" if shader_exists else "source_lead",
        "notes": "Batch-discovered from existing app module metadata; review formula detail before using in educational copy." if shader_exists else "Has metadata and thumbnail, but is not counted until renderer shader path exists and validation is complete.",
    }


def main() -> None:
    entries = []
    for metadata_path in sorted(META_ROOT.rglob("*_metadata.dart")):
        entry = build_entry(metadata_path)
        if entry is not None:
            entries.append(entry)

    ledger = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Discovery ledger of existing generated app metadata with thumbnails; only shader-backed validated entries are counted.",
        "counting_rule": "Counts named stable formula/rule identities only when renderer and validation gates pass; presets and random seeds are ignored.",
        "entries": entries,
    }
    OUT.write_text(json.dumps(ledger, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "entries": len(entries)}, indent=2))


if __name__ == "__main__":
    main()
