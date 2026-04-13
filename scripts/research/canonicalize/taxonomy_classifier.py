"""Classify a formula_ast into one of the 19 canonical categories + family.

iteration_type → category is deterministic. Family is pattern-matched on update
expression.
"""
from __future__ import annotations

from typing import Any

CATEGORIES: dict[str, str] = {
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

ITERATION_TYPE_MAP: dict[str, tuple[str, float]] = {
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


def _detect_family(ast: dict[str, Any]) -> str | None:
    """Pattern-match the update expression to a known family."""
    update = (ast.get("update") or "").replace(" ", "").lower()

    # Strip "z=" LHS if present
    if "=" in update:
        update = update.split("=", 1)[1]

    # Family detection rules (order matters — most specific first)
    if "conj(z)**2+c" in update or "conj(z)^2+c" in update:
        return "tricorn"
    if "abs(re(z))" in update or "abs(real(z))" in update:
        return "burning_ship"
    if "z**3+c" in update or "z^3+c" in update:
        return "multibrot_cubic"
    if "z**4+c" in update or "z^4+c" in update:
        return "multibrot_quartic"
    if "z**2+c" in update or "z^2+c" in update:
        return "mandelbrot"
    if "sin(z)" in update and "+c" in update:
        return "trigonometric_sine"
    if "cos(z)" in update and "+c" in update:
        return "trigonometric_cosine"
    if "exp(z)" in update:
        return "transcendental_exp"

    return None


def classify(formula_ast: dict[str, Any]) -> dict[str, Any]:
    """Return classification for this formula_ast.

    Returns dict with keys:
      category_roman: 'I'..'XIX'
      category_name: human name
      confidence: 0.0..1.0
      uncertain: True if confidence < 0.8
      family: optional str (e.g. 'mandelbrot', 'tricorn')
    """
    it = formula_ast.get("iteration_type", "other")
    roman, conf = ITERATION_TYPE_MAP.get(it, ("XIII", 0.3))
    return {
        "category_roman": roman,
        "category_name": CATEGORIES[roman],
        "confidence": conf,
        "uncertain": conf < 0.8,
        "family": _detect_family(formula_ast),
    }
