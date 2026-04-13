"""L-system classics. Each entry uses a unique axiom+rule production string.

References: Lindenmayer 1968, Prusinkiewicz & Lindenmayer "The Algorithmic
Beauty of Plants" (1990), Paul Bourke's L-system catalog.
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "l_system_classics"
FAMILY = "lsystem"

_PARAMS = {
    "depth": {"default": 5, "range": [1, 12]},
    "angle": {"default": 60.0, "range": [1.0, 180.0]},
    "step_length": {"default": 4.0, "range": [0.1, 50.0]},
}
_PRESETS = [{"id": "default", "name": "Default depth", "params": {}}]

_REFS_PB = lambda url, title: [  # noqa: E731
    {"author": "Paul Bourke", "title": title, "year": 2002, "url": url},
    {"author": "P. Prusinkiewicz, A. Lindenmayer",
     "title": "The Algorithmic Beauty of Plants",
     "year": 1990, "url": "http://algorithmicbotany.org/papers/abop/abop.pdf"},
]


def _e(name: str, axiom: str, rule: str, angle: float, desc: str,
       aliases: list[str] | None = None,
       url: str = "http://paulbourke.net/fractals/lsys/") -> dict:
    update = f"{axiom} -> {rule} [angle={angle}]"
    params = dict(_PARAMS)
    params["angle"] = {"default": angle, "range": [1.0, 180.0]}
    return {
        "name": name,
        "aliases": aliases or [],
        "iteration_type": "l_system",
        "update": update,
        "init": f"axiom: {axiom}",
        "params": params,
        "presets": _PRESETS,
        "variants": [],
        "references": _REFS_PB(url, name),
        "description_en": desc,
        "source_url": url,
    }


TABLE: list[dict] = [
    _e("Koch Curve", "F", "F+F--F+F", 60,
       "Classical Koch curve (Helge von Koch 1904) — constructs the snowflake side segment: each straight segment is replaced by a 4-segment bump.",
       aliases=["Koch"]),
    _e("Koch Square Curve", "F", "F+F-F-F+F", 90,
       "Koch square curve — 90°-angle variant replacing each segment with 5 segments forming a square bump."),
    _e("Quadratic Koch Curve (Type 1)", "F", "F+F-F-FF+F+F-F", 90,
       "Type-1 quadratic Koch curve with 8-segment replacement rule."),
    _e("Quadratic Koch Curve (Type 2)", "F", "F+FF-FF-F-F+F+F", 90,
       "Type-2 quadratic Koch curve — alternative replacement producing different geometric structure."),
    _e("Koch Triangle Island", "F+F+F+F", "F-FF+FF+F+F-F-FF+F+F-F-FF-FF+F", 90,
       "Koch Island variant — space-filling triangular island tiled by recursive replacement."),
    _e("Koch 85°", "F", "F+F--F+F", 85,
       "Koch curve with 85° turn angle — produces a skewed variant of the classical snowflake."),
    _e("Hilbert Curve 3D", "A", "B-F+CFC+F-D&F^D-F+&&CFC+F+B//", 90,
       "3D Hilbert space-filling curve — extension of the 2D Hilbert curve to fill a unit cube.",
       aliases=["Hilbert3D"]),
    _e("Moore Curve", "LFL+F+LFL", "LFL+F+LFL", 90,
       "Moore curve — closed variant of the Hilbert curve, forming a loop that visits every cell of a square grid.",
       aliases=["Moore space-filling"]),
    _e("Heighway Dragon L-system", "FX", "X->X+YF+; Y->-FX-Y", 90,
       "Heighway dragon curve as an L-system with turtle interpretation.",
       aliases=["Heighway dragon"]),
    _e("Lévy C Curve", "F", "+F--F+", 45,
       "Lévy C curve — self-similar fractal; each segment replaced by two segments at ±45°.",
       aliases=["Levy C"]),
    _e("McWorter Pentigree", "F-F-F-F-F", "F-F++F+F-F-F", 72,
       "McWorter pentigree — pentagonal variant of Koch-style curve based on 5-fold symmetry."),
    _e("Hexigree", "F-F-F-F-F-F", "F-F++F-F", 60,
       "Hexagonal Koch-like curve with 6-fold symmetry."),
    _e("Heptigree", "F-F-F-F-F-F-F", "F-F++F-F", 51.428,
       "Heptagonal Koch-like curve with 7-fold symmetry (angle 360/7 ≈ 51.43°)."),
    _e("Octogree", "F-F-F-F-F-F-F-F", "F-F++F-F", 45,
       "Octagonal Koch-like curve with 8-fold symmetry."),
    _e("Cesàro Fractal", "F", "F+F--F+F", 75,
       "Cesàro fractal (Ernesto Cesàro 1905) — Koch-curve variant; here shown at Cesàro's original 75° angle.",
       aliases=["Cesaro"]),
    _e("Anti-Cesàro", "F", "F-F++F-F", 85,
       "Anti-Cesàro curve — sign-flipped version of Cesàro fractal."),
    _e("Sierpinski Triangle L-system", "F-G-G", "F->F-G+F+G-F; G->GG", 120,
       "Sierpinski triangle via L-system with two non-terminal symbols F and G."),
    _e("Sierpinski Square L-system", "F+XF+F+XF", "X->XF-F+F-XF+F+XF-F+F-X", 90,
       "Sierpinski square (carpet-like) via L-system."),
    _e("Sierpinski Median Curve", "L--F--L--F", "L->+R-F-R+; R->-L+F+L-", 45,
       "Sierpinski median curve — space-filling curve whose image is the Sierpinski triangle."),
    _e("Lindenmayer Algae 1", "A", "A->AB; B->A", 90,
       "Lindenmayer's original 1968 algae example — deterministic binary development producing the Fibonacci sequence of cell counts.",
       aliases=["Algae"]),
    _e("Lindenmayer Algae 2", "A", "A->ABA; B->BBB", 90,
       "Variant algae L-system producing ternary expansion."),
    _e("Fractal Plant (Canonical)", "X", "X->F+[[X]-X]-F[-FX]+X; F->FF", 25,
       "Canonical fractal plant L-system from Prusinkiewicz & Lindenmayer — produces leaf-bearing branches with 25° rotations.",
       aliases=["Algorithmic Plant"]),
    _e("Fractal Bush", "Y", "X->X[-FFF][+FFF]FX; Y->YFX[+Y][-Y]", 25.7,
       "Fractal bush with double-branching growth rule."),
    _e("Binary Tree", "0", "0->1[0]0; 1->11", 45,
       "Binary fractal tree — simplest branching L-system.",
       aliases=["binary tree"]),
    _e("Ternary Tree", "F", "F->F[+F]F[-F]F", 25.7,
       "Ternary fractal tree — each stem produces three children."),
    _e("Weed", "F", "F->F[+F]F[-F][F]", 20,
       "Weed-like plant L-system — asymmetric branching."),
    _e("Random Bush", "F", "F->FF-[-F+F+F]+[+F-F-F]", 22.5,
       "Stochastic-style bush with symmetric push/pop branching."),
    _e("Koch-Peano Island", "F+F+F+F", "F->F+F-F-FFF+F+F-F", 90,
       "Koch-Peano space-filling island combining Koch scaling and Peano tiling."),
    _e("Pentadentrite", "F-F-F-F-F", "F->F-F++F+F-F-F", 72,
       "Pentadentrite — 5-fold symmetric dendritic L-system curve."),
    _e("Sierpinski Gasket Arrowhead", "YF", "X->YF+XF+Y; Y->XF-YF-X", 60,
       "Sierpinski arrowhead variant with alternate production rules."),
    _e("Krishna Anklets", "-X--X", "X->XFX--XFX", 45,
       "Krishna anklets L-system — Indian-art-inspired self-similar braid."),
    _e("Pentaplexity", "F++F++F++F++F", "F->F++F++F|F-F++F", 36,
       "Pentaplexity fractal (Mandelbrot & Penrose-style) — 5-fold symmetric aperiodic L-system."),
    _e("Hexagonal Gosper", "A", "A->A+BF++BF-FA--FAFA-BF+; B->-FA+BFBF++BF+FA--FA-B", 60,
       "Hexagonal Gosper curve (flowsnake) in expanded rule form."),
    _e("Moore-like Hilbert", "X", "X->-YF+XFX+FY-; Y->+XF-YFY-FX+", 90,
       "Alternative Hilbert-like space-filling curve using alternating production rules."),
    _e("Island and Lakes", "F+F+F+F", "F->F+f-FF+F+FF+Ff+FF-f+FF-F-FF-Ff-FFF; f->ffffff", 90,
       "Island-and-lakes pattern — Prusinkiewicz's 'Island and lakes' from ABOP §1.4."),
    _e("Dragon-Tree Hybrid", "F", "F->F+G; G->F-G", 90,
       "Heighway-dragon-style tree hybrid."),
    _e("Snowflake of Snowflakes", "F++F++F", "F->F-F++F-F", 60,
       "Nested snowflake L-system — recursive Koch snowflake."),
    _e("Rauzy Fractal (L-system form)", "A", "A->AB; B->AC; C->A", 120,
       "Rauzy fractal as L-system encoding Tribonacci substitution dynamics.",
       aliases=["Rauzy"]),
    _e("Lute of Pythagoras", "A", "A->F[+A][-A]F", 60,
       "Lute of Pythagoras — classical pentagonal fractal from ancient geometry."),
    _e("Fern (Prusinkiewicz)", "X", "X->F-[[X]+X]+F[+FX]-X; F->FF", 22.5,
       "Fern L-system from ABOP — alternative angle variant (22.5°) producing tighter fronds."),
]


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
