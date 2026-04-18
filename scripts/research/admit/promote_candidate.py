"""Admit approved candidates: assign ID, update registry, emit Dart, render thumbnails.

Entry point: forge admit <batch_id>

Logic:
 1. Load decisions/{batch_id}.yaml
 2. For each approved candidate: assign ID, build registry entry, emit Dart,
    render thumbnail, update registry.
 3. Atomic-ish: registry saved once at end; per-candidate failures logged and
    skipped rather than aborting the batch.
"""
from __future__ import annotations

import re
import traceback
from dataclasses import dataclass, field
from datetime import date
from pathlib import Path

from ruamel.yaml import YAML

from scripts.research.admit.emit_dart import emit
from scripts.research.admit.thumbnail_render import render as render_thumb
from scripts.research.canonicalize.formula_normalizer import hash_ast
from scripts.research.canonicalize.taxonomy_classifier import classify
from scripts.research.lib.registry import Registry
from scripts.research.lib.schema_lint import SchemaLintError, lint


def _yaml() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    y.indent(mapping=2, sequence=4, offset=2)
    return y


@dataclass
class AdmissionReport:
    batch_id: str
    admitted: list[str] = field(default_factory=list)
    merged: list[str] = field(default_factory=list)
    rejected: list[str] = field(default_factory=list)
    failed: list[tuple[str, str]] = field(default_factory=list)  # (candidate_id, error)


def _next_id(registry: Registry, proposed_name: str) -> str:
    """Assign f{NNNN}_{snake_name} with NNNN = max existing + 1. Falls back to 0001."""
    max_n = 0
    pattern = re.compile(r"^f(\d+)_")
    for entry in registry.entries:
        m = pattern.match(entry.get("id", ""))
        if m:
            max_n = max(max_n, int(m.group(1)))
    n = max_n + 1
    snake = re.sub(r"[^a-z0-9]+", "_", proposed_name.lower()).strip("_")
    snake = snake[:40] or "unnamed"
    return f"f{n:04d}_{snake}"


def _build_registry_entry(candidate: dict, new_id: str, classification: dict) -> dict:
    formula_ast = candidate.get("formula_ast", {})
    fhash = hash_ast(formula_ast)
    iter_type = formula_ast.get("iteration_type", "other")
    dim = "3D" if iter_type == "raymarch_3d" else "2D"

    entry: dict = {
        "id": new_id,
        "name": candidate.get("proposed_name", new_id),
        "shader": f"shaders/{new_id}_gpu.frag",
        "category": classification["category_name"],
        "dimension": dim,
        "defaultPower": float(candidate.get("params", {}).get("power", {}).get("default", 2.0)),
        "defaultIterations": float(candidate.get("params", {}).get("iterations", {}).get("default", 500)),
        "defaultSteps": float(candidate.get("params", {}).get("steps", {}).get("default", 120 if dim == "3D" else 0)),
        "defaultBailout": float(candidate.get("params", {}).get("bailout", {}).get("default", 2.0)),
        "defaultColorScheme": 0,
        "hasThumbnail": True,
        "implemented": False,  # shader not yet hand-written; reference tier
        "presets": [p.get("id", "") for p in candidate.get("presets", [])],
        "variants": [v.get("id", "") for v in candidate.get("variants", [])],
        "references": candidate.get("references", []),
        "tier": "reference",  # no working shader yet
        "formula_hash": fhash,
        "aliases": candidate.get("aliases", []),
        "canonical_name": candidate.get("proposed_name"),
        "quality": {
            "formula_hash": fhash,
            "citation_health": {"last_checked": date.today().isoformat(), "status": "unchecked"},
            "shader_compile": {"sksl": "n/a", "glsl": "n/a", "checked": date.today().isoformat()},
            "thumbnail": {"entropy": 0.0, "checked": date.today().isoformat()},
            "review": {"approved_by": "admit", "batch": ""},
            "confidence": float(candidate.get("quality", {}).get("confidence", 0.8)),
        },
    }
    family = classification.get("family")
    if family:
        entry["family"] = family
    return entry


def promote_batch(
    batch_id: str,
    repo_root: Path,
) -> AdmissionReport:
    report = AdmissionReport(batch_id=batch_id)

    decisions_path = repo_root / "research" / "decisions" / f"{batch_id}.yaml"
    if not decisions_path.exists():
        raise FileNotFoundError(f"decisions file not found: {decisions_path}")
    batch_path = repo_root / "research" / "candidates" / batch_id
    registry_path = repo_root / "docs" / "catalog" / "fractal_registry.yaml"

    with decisions_path.open() as f:
        decisions_doc = _yaml().load(f) or {}

    registry = Registry.load(registry_path)

    for cid, verdict in (decisions_doc.get("decisions") or {}).items():
        try:
            action = verdict.get("action")
            if action == "reject":
                report.rejected.append(cid)
                continue
            if action == "approve_merge":
                report.merged.append(cid)
                # TODO: append alias to canonical_aliases.yaml; not critical for Stage B
                continue
            if action != "approve_new":
                continue

            cand_path = batch_path / f"{cid}.yaml"
            if not cand_path.exists():
                # Try fallback lookup by glob
                matches = list(batch_path.glob(f"*{cid}*.yaml"))
                if matches:
                    cand_path = matches[0]
                else:
                    report.failed.append((cid, f"candidate file not found in {batch_path}"))
                    continue

            with cand_path.open() as f:
                candidate = _yaml().load(f)

            classification = classify(candidate.get("formula_ast", {}))
            new_id = _next_id(registry, candidate.get("proposed_name", ""))
            entry = _build_registry_entry(candidate, new_id, classification)
            entry["quality"]["review"]["batch"] = batch_id

            # Schema lint
            lint("registry_entry", entry)

            # Append to registry
            registry.entries.append(entry)

            # Emit Dart
            iter_type = candidate.get("formula_ast", {}).get("iteration_type", "other")
            if iter_type in {"escape_time", "raymarch_3d", "strange_attractor", "ifs", "l_system", "cellular", "newton", "lyapunov", "tiling", "reaction_diffusion", "number_theory"}:
                emit(candidate, entry, iter_type, repo_root)

            # Render thumbnail
            thumb_path = repo_root / "assets" / "catalog_thumbs" / f"{new_id}.png"
            thumb_info = render_thumb(new_id, entry["formula_hash"], thumb_path)
            entry["quality"]["thumbnail"] = thumb_info

            report.admitted.append(new_id)
        except Exception as e:
            report.failed.append((cid, f"{type(e).__name__}: {e}"))
            traceback.print_exc()
            continue

    # Save registry once at the end
    if report.admitted:
        registry.save()

    return report


def run_admit(repo_root: Path, batch_id: str) -> int:
    report = promote_batch(batch_id, repo_root)
    print(f"admit: batch {batch_id}")
    print(f"  admitted: {len(report.admitted)}")
    for aid in report.admitted:
        print(f"    + {aid}")
    print(f"  merged: {len(report.merged)}")
    print(f"  rejected: {len(report.rejected)}")
    if report.failed:
        print(f"  failed: {len(report.failed)}")
        for cid, err in report.failed:
            print(f"    ! {cid}: {err}")
        return 1 if not report.admitted else 0
    return 0
