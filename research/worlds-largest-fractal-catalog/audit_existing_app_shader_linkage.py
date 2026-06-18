#!/usr/bin/env python3
"""Audit renderer-linkage blockers for existing generated app source leads.

This is intentionally conservative: it does not promote entries. It reports
whether a generated module's declared shader exists exactly, whether a basename
match exists elsewhere, and groups unresolved leads by family/renderer kind so
promotion batches can be chosen without counting random presets.
"""

from __future__ import annotations

import json
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path

SHARED_SHADER_RULES = [
    ("escape_time_polynomial_complex", "burning_ship", "shaders/escape_time_family/families/burning_ship/parameter_plane/burning_ship_gpu.frag"),
    ("escape_time_polynomial_complex", "julia", "shaders/escape_time_family/core/julia_gpu.frag"),
    ("escape_time_polynomial_complex", "mandelbrot", "shaders/escape_time_family/core/mandel_julia_dual_gpu.frag"),
    ("escape_time_polynomial_complex", "mandelbar", "shaders/escape_time_family/families/mandelbar/mandelbar_cubic_gpu.frag"),
    ("escape_time_polynomial_complex", "multibrot", "shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag"),
    ("escape_time_polynomial_complex", "tricorn", "shaders/escape_time_family/families/tricorn/parameter_plane/tricorn_gpu.frag"),
    ("escape_time_polynomial_complex", "nova", "shaders/escape_time_family/families/nova/parameter_plane/nova_gpu.frag"),
    ("escape_time_polynomial_complex", "phoenix", "shaders/escape_time_family/core/phoenix_gpu.frag"),
    ("escape_time_polynomial_complex", "sin", "shaders/trigonometric_and_transcendental/elementary_trig/sine_mandelbrot_gpu.frag"),
    ("escape_time_polynomial_complex", "cos", "shaders/trigonometric_and_transcendental/elementary_trig/cosine_mandelbrot_gpu.frag"),
    ("escape_time_polynomial_complex", "inverse", "shaders/escape_time_family/mandelbrot_variants/iterative_maps/inverse_mandelbrot_gpu.frag"),
    ("escape_time_polynomial_complex", "orbit_trap", "shaders/escape_time_family/mandelbrot_variants/exterior_coloring/mandelbrot_orbit_trap_gpu.frag"),
    ("root_finding_polynomiography", "newton", "shaders/root_finding/newton_general_gpu.frag"),
    ("root_finding_polynomiography", "halley", "shaders/root_finding/halley_gpu.frag"),
    ("strange_attractors_maps", "sprott", "shaders/strange_attractors/sprott_a_gpu.frag"),
    ("cellular_automata", "elementary_ca", "shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag"),
    ("cellular_automata", "rule_", "shaders/cellular_and_stochastic/wolfram_rule30_gpu.frag"),
    ("cellular_automata", "game_of_life", "shaders/cellular_and_stochastic/highlife_gpu.frag"),
    ("cellular_automata", "highlife", "shaders/cellular_and_stochastic/highlife_gpu.frag"),
    ("cellular_automata", "replicator", "shaders/cellular_and_stochastic/replicator_ca_gpu.frag"),
    ("cellular_automata", "cyclic", "shaders/cellular_and_stochastic/cyclic_ca_gpu.frag"),
    ("cellular_automata", "maze", "shaders/cellular_and_stochastic/maze_ca_gpu.frag"),
    ("cellular_automata", "forest_fire", "shaders/cellular_and_stochastic/forest_fire_gpu.frag"),
    ("cellular_automata", "sandpile", "shaders/cellular_and_stochastic/sandpile_gpu.frag"),
    ("ifs_geometric", "sierpinski", "shaders/ifs_and_geometric/sierpinski_triangle_gpu.frag"),
    ("distance_estimated_3d_raymarch", "mandelbulb", "shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag"),
    ("distance_estimated_3d_raymarch", "mandelbox", "shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag"),
    ("distance_estimated_3d_raymarch", "quaternion_julia", "shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag"),
    ("distance_estimated_3d_raymarch", "menger", "shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag"),
]

ROOT = Path(__file__).resolve().parents[2]
LEDGER = ROOT / "research/worlds-largest-fractal-catalog/curated-entry-ledger.existing-app.json"
OUT = ROOT / "research/worlds-largest-fractal-catalog/existing-app-shader-linkage-audit.json"
MD_OUT = ROOT / "research/worlds-largest-fractal-catalog/existing-app-shader-linkage-audit.md"


def recommend_shared_shader(item: dict, shader_rel: set[str]) -> str | None:
    stable_id = str(item.get("stable_id") or "").lower()
    family = item.get("family")
    for target_family, token, shader in SHARED_SHADER_RULES:
        if family == target_family and token in stable_id and shader in shader_rel:
            return shader
    return None


def main() -> None:
    ledger = json.loads(LEDGER.read_text(encoding="utf-8"))
    entries = ledger.get("entries", [])
    shader_files = sorted(ROOT.glob("shaders/**/*.frag"))
    shader_rel = {str(path.relative_to(ROOT)) for path in shader_files}
    shader_by_name = defaultdict(list)
    for rel in shader_rel:
        shader_by_name[Path(rel).name].append(rel)

    exact = []
    basename = []
    unresolved = []
    for entry in entries:
        declared = entry.get("parameter_schema", {}).get("declared_shader", "")
        item = {
            "stable_id": entry.get("stable_id"),
            "family": entry.get("family"),
            "renderer_kind": entry.get("parameter_schema", {}).get("renderer_kind"),
            "declared_shader": declared,
            "metadata_source": entry.get("provenance", {}).get("source"),
            "thumbnail_plan": entry.get("thumbnail_plan"),
        }
        if declared in shader_rel:
            exact.append({**item, "resolved_shader": declared})
            continue
        matches = shader_by_name.get(Path(declared).name, [])
        if matches:
            basename.append({**item, "candidate_shaders": matches})
            continue
        unresolved.append(item)

    shared_candidates = []
    still_unmapped = []
    for item in unresolved:
        shared_shader = recommend_shared_shader(item, shader_rel)
        if shared_shader:
            shared_candidates.append({**item, "candidate_shared_shader": shared_shader})
        else:
            still_unmapped.append(item)

    unresolved_by_family = Counter(item["family"] for item in unresolved)
    unresolved_by_renderer = Counter(item["renderer_kind"] for item in unresolved)
    unresolved_by_pair = Counter((item["family"], item["renderer_kind"]) for item in unresolved)
    shared_by_shader = Counter(item["candidate_shared_shader"] for item in shared_candidates)

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "purpose": "Conservative shader-linkage audit for generated existing-app source leads; does not promote entries.",
        "input_ledger": str(LEDGER.relative_to(ROOT)),
        "shader_inventory_count": len(shader_rel),
        "entry_count": len(entries),
        "exact_declared_shader_matches": len(exact),
        "basename_shader_matches": len(basename),
        "unresolved_count": len(unresolved),
        "shared_shader_candidate_count": len(shared_candidates),
        "still_unmapped_count": len(still_unmapped),
        "unresolved_by_family": dict(unresolved_by_family.most_common()),
        "unresolved_by_renderer_kind": dict(unresolved_by_renderer.most_common()),
        "unresolved_by_family_renderer_kind": [
            {"family": family, "renderer_kind": renderer, "count": count}
            for (family, renderer), count in unresolved_by_pair.most_common()
        ],
        "shared_shader_candidates_by_shader": dict(shared_by_shader.most_common()),
        "exact_matches": exact,
        "basename_matches": basename,
        "shared_shader_candidates": shared_candidates,
        "unresolved_samples": still_unmapped[:50],
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# Existing App Shader Linkage Audit",
        "",
        "Conservative audit for generated existing-app source leads. This artifact does not promote entries or count presets.",
        "",
        "## Summary",
        "",
        f"- Input ledger: `{payload['input_ledger']}`",
        f"- Existing shader inventory: {payload['shader_inventory_count']} `.frag` files",
        f"- Existing-app source leads: {payload['entry_count']}",
        f"- Exact declared shader matches: {payload['exact_declared_shader_matches']}",
        f"- Basename shader matches elsewhere: {payload['basename_shader_matches']}",
        f"- Unresolved missing shader links: {payload['unresolved_count']}",
        f"- Shared-shader candidate leads: {payload['shared_shader_candidate_count']}",
        f"- Still-unmapped leads: {payload['still_unmapped_count']}",
        "",
        "## Unresolved by family",
        "",
        "| Family | Count |",
        "|---|---:|",
    ]
    for family, count in unresolved_by_family.most_common():
        lines.append(f"| {family} | {count} |")
    lines.extend([
        "",
        "## Unresolved by renderer kind",
        "",
        "| Renderer kind | Count |",
        "|---|---:|",
    ])
    for renderer, count in unresolved_by_renderer.most_common():
        lines.append(f"| {renderer} | {count} |")
    lines.extend([
        "",
        "## Shared-shader candidates by shader",
        "",
        "These are not counted yet; they are implementation candidates that need reviewed parameter mapping and render smoke.",
        "",
        "| Candidate shared shader | Leads |",
        "|---|---:|",
    ])
    for shader, count in shared_by_shader.most_common():
        lines.append(f"| `{shader}` | {count} |")
    lines.extend([
        "",
        "## Next safe promotion actions",
        "",
        "1. Do not count any existing-app source lead until its renderer path exists and validation passes.",
        "2. Prioritize a shared-renderer strategy for `escape_time_polynomial_complex` source leads because they are numerous and use `EscapeTimeModule` defaults.",
        "3. Add generated-module registration/render smoke only after shader paths are real or mapped to reviewed shared shaders.",
        "4. Keep variants/presets excluded from counted totals unless a named stable formula/rule identity is promoted as its own module.",
    ])
    MD_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"wrote": str(OUT), "markdown": str(MD_OUT), "unresolved": len(unresolved)}, indent=2))


if __name__ == "__main__":
    main()
