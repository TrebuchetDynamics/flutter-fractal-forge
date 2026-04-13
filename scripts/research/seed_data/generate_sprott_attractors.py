"""Sprott A-S, Sprott-Linz A-J, and selected Elegant-Chaos attractors.

Sources:
  - J. C. Sprott, "Some simple chaotic flows", Phys. Rev. E 50 R647 (1994).
  - https://sprott.physics.wisc.edu/chaos/abchaos.htm
  - Sprott & Linz 1999, 2000.
  - J. C. Sprott, "Elegant Chaos: Algebraically Simple Chaotic Flows" (2010).

Full 3-ODE update strings (semicolon-separated) yield unique raw-fallback hashes.
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "sprott_attractors"
FAMILY = "sprott"

SPROTT_CAT = "https://sprott.physics.wisc.edu/chaos/abchaos.htm"
SPROTT_PAPER = "https://sprott.physics.wisc.edu/pubs/paper229.pdf"
SPROTT_LINZ_PAPER = "https://sprott.physics.wisc.edu/pubs/paper270.pdf"
SPROTT_ELEGANT = "https://sprott.physics.wisc.edu/pubs/paper356.pdf"

_PARAMS = {
    "iterations": {"default": 100000, "range": [1000, 500000]},
    "step_size": {"default": 0.01, "range": [0.001, 0.1]},
}
_PRESETS = [{"id": "classic", "name": "Classic view", "params": {"step_size": 0.01}}]


def _entry(name: str, update: str, desc: str, refs: list[dict]) -> dict:
    return {
        "name": name,
        "aliases": [name.replace(" ", "-")],
        "iteration_type": "strange_attractor",
        "update": update,
        "init": "x=0.05; y=0.05; z=0.05",
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": refs,
        "description_en": desc,
        "source_url": refs[-1].get("url", ""),
        "formula_latex": "",
    }


_REFS = [
    {"author": "J. C. Sprott", "title": "Some simple chaotic flows",
     "year": 1994, "url": SPROTT_PAPER},
    {"author": "J. C. Sprott", "title": "A to S chaotic flows catalog",
     "year": 1994, "url": SPROTT_CAT},
]
_REFS_LINZ = [
    {"author": "S. J. Linz, J. C. Sprott",
     "title": "Elementary chaotic flow", "year": 1999,
     "url": SPROTT_LINZ_PAPER},
]
_REFS_ELEGANT = [
    {"author": "J. C. Sprott",
     "title": "Elegant Chaos: Algebraically Simple Chaotic Flows", "year": 2010,
     "url": SPROTT_ELEGANT},
]

# Sprott A-S catalog (Phys Rev E 50 R647)
SPROTT = [
    ("Sprott A",
     "dx = y; dy = -x + y*z; dz = 1 - y**2",
     "Sprott A — the first entry in Sprott's 1994 catalog of 19 algebraically simplest chaotic 3D flows. Conservative (volume-preserving)."),
    ("Sprott B",
     "dx = y*z; dy = x - y; dz = 1 - x*y",
     "Sprott B — second in the 1994 catalog; has a quadratic nonlinearity in each equation."),
    ("Sprott C",
     "dx = y*z; dy = x - y; dz = 1 - x**2",
     "Sprott C — differs from B by an x^2 term instead of x*y in the z equation."),
    ("Sprott D",
     "dx = -y; dy = x + z; dz = x*z + 3*y**2",
     "Sprott D — cyclically simple flow with a cross-coupling term x*z."),
    ("Sprott E",
     "dx = y*z; dy = x**2 - y; dz = 1 - 4*x",
     "Sprott E — features a squared nonlinearity in the y-equation."),
    ("Sprott F",
     "dx = y + z; dy = -x + 0.5*y; dz = x**2 - z",
     "Sprott F — minimal chaotic jerk system with a single quadratic term."),
    ("Sprott G",
     "dx = 0.4*x + z; dy = x*z - y; dz = -x + y",
     "Sprott G — has a linear x term in the x-equation and a bilinear x*z coupling."),
    ("Sprott H",
     "dx = -y + z**2; dy = x + 0.5*y; dz = x - z",
     "Sprott H — 2 linear equations plus one with a z^2 nonlinearity."),
    ("Sprott I",
     "dx = -0.2*y; dy = x + z; dz = x + y**2 - z",
     "Sprott I — small-coefficient chaotic flow."),
    ("Sprott J",
     "dx = 2*z; dy = -2*y + z; dz = -x + y + y**2",
     "Sprott J — jerky system with an integer-coefficient structure."),
    ("Sprott K",
     "dx = x*y - z; dy = x - y; dz = x + 0.3*z",
     "Sprott K — contains a single bilinear x*y term."),
    ("Sprott L",
     "dx = y + 3.9*z; dy = 0.9*x**2 - y; dz = 1 - x",
     "Sprott L — chaotic flow with a quadratic x^2 term in the y-equation."),
    ("Sprott M",
     "dx = -z; dy = -x**2 - y; dz = 1.7 + 1.7*x + y",
     "Sprott M — quadratic-nonlinearity variant with offset forcing."),
    ("Sprott N",
     "dx = -2*y; dy = x + z**2; dz = 1 + y - 2*z",
     "Sprott N — z^2 feedback into the y-equation."),
    ("Sprott O",
     "dx = y; dy = x - z; dz = x + x*z + 2.7*y",
     "Sprott O — flow with a bilinear x*z term in the z-equation."),
    ("Sprott P",
     "dx = 2.7*y + z; dy = -x + y**2; dz = x + y",
     "Sprott P — quadratic-y nonlinearity with small coefficients."),
    ("Sprott Q",
     "dx = -z; dy = x - y; dz = 3.1*x + y**2 + 0.5*z",
     "Sprott Q — quadratic-y feedback with large x coefficient."),
    ("Sprott R",
     "dx = 0.9 - y; dy = 0.4 + z; dz = x*y - z",
     "Sprott R — simple bilinear system with integer-free offsets."),
    ("Sprott S",
     "dx = -x - 4*y; dy = x + z**2; dz = 1 + x",
     "Sprott S — final entry in the 1994 A-S catalog; z^2 nonlinearity in y-equation."),
]

# Sprott-Linz A-J jerky flows (simplified algebraic chaos)
SPROTT_LINZ = [
    ("Sprott-Linz A",
     "dx = y; dy = z; dz = -2.017*z + y**2 - x",
     "Sprott-Linz A jerky flow: minimal 3rd-order ODE d^3x/dt^3 + A d^2x/dt^2 + dx/dt = f(x). Seeks algebraically simplest jerky chaos."),
    ("Sprott-Linz B",
     "dx = y; dy = z; dz = -A*z + y**2 - x",
     "Sprott-Linz B: polynomial jerk system, quadratic feedback."),
    ("Sprott-Linz C",
     "dx = y; dy = z; dz = -A*z + x**2 - y",
     "Sprott-Linz C: x^2 nonlinearity feedback jerk."),
    ("Sprott-Linz D",
     "dx = y; dy = z; dz = -A*z + Abs(y) - x",
     "Sprott-Linz D: absolute-value nonlinearity."),
    ("Sprott-Linz E",
     "dx = y; dy = z; dz = -A*z + y*z - x",
     "Sprott-Linz E: bilinear nonlinearity y*z."),
    ("Sprott-Linz F",
     "dx = y; dy = z; dz = -A*z + x*y - 1",
     "Sprott-Linz F: x*y bilinear coupling."),
    ("Sprott-Linz G",
     "dx = y; dy = z; dz = -A*z - y - x - x**3",
     "Sprott-Linz G: cubic restoring force."),
    ("Sprott-Linz H",
     "dx = y; dy = z; dz = -A*z + x - x**3 - y",
     "Sprott-Linz H: symmetric cubic."),
    ("Sprott-Linz I",
     "dx = y; dy = z; dz = -A*z + sign(x) - x - y",
     "Sprott-Linz I: signum nonlinearity."),
    ("Sprott-Linz J",
     "dx = y; dy = z; dz = -A*z + x*y*z - 0.5*x",
     "Sprott-Linz J: trilinear feedback."),
]

ELEGANT = [
    ("Sprott Labyrinth Chaos",
     "dx = sin(y); dy = sin(z); dz = sin(x)",
     "Thomas-Sprott labyrinth chaos — three trigonometric equations coupled cyclically producing labyrinth-like fractal wandering."),
    ("Sprott Minimum Chaotic Flow",
     "dx = y; dy = z; dz = -0.5*z + y**2 - x + Abs(x)",
     "Sprott's minimum-complexity chaotic flow — claimed algebraically simplest known dissipative chaotic 3D system with a quadratic term and absolute-value."),
    ("Sprott WINDMI",
     "dx = y; dy = z; dz = -a*z - y + b - exp(x)",
     "Sprott's WINDMI (WIND-Magnetosphere-Ionosphere) model — 3-variable system with exponential nonlinearity from magnetospheric physics."),
    ("Sprott Conservative SC",
     "dx = y; dy = -x + y*z; dz = -x**2",
     "Sprott conservative (volume-preserving) chaotic flow — rare example of non-dissipative continuous-time chaos."),
]


TABLE: list[dict] = []
for name, update, desc in SPROTT:
    TABLE.append(_entry(name, update, desc, _REFS))
for name, update, desc in SPROTT_LINZ:
    TABLE.append(_entry(name, update, desc, _REFS_LINZ))
for name, update, desc in ELEGANT:
    TABLE.append(_entry(name, update, desc, _REFS_ELEGANT))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
