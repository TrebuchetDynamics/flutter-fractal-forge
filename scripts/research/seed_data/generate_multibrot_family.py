"""Multibrot family: z^d + c for high integer powers, fractional powers,
absolute-value (burning-ship style) variants, and tricorn z̄^d + c variants.

Canonical reference: https://en.wikipedia.org/wiki/Multibrot_set
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "multibrot_family"
FAMILY = "multibrot"

_PARAMS = {
    "iterations": {"default": 500, "range": [10, 5000]},
    "bailout": {"default": 4.0, "range": [2.0, 1024.0]},
    "power": {"default": 2.0, "range": [-20.0, 20.0]},
}
_WIKI = "https://en.wikipedia.org/wiki/Multibrot_set"
_PB = "http://paulbourke.net/fractals/multibrot/"

_REFS_MULTIBROT = [
    {"author": "Wikipedia", "title": "Multibrot set",
     "year": 2024, "url": _WIKI},
    {"author": "Paul Bourke",
     "title": "Multibrot fractals (fractal catalog)",
     "year": 2003, "url": _PB},
]
_REFS_TRICORN = [
    {"author": "W. D. Crowe, R. Hasson, P. J. Rippon, P. E. D. Strain-Clark",
     "title": "On the structure of the Mandelbar set",
     "year": 1989, "url": "https://doi.org/10.1088/0951-7715/2/4/001",
     "doi": "10.1088/0951-7715/2/4/001"},
    {"author": "Wikipedia", "title": "Tricorn (mathematics)",
     "year": 2024, "url": "https://en.wikipedia.org/wiki/Tricorn_(mathematics)"},
]
_REFS_BS = [
    {"author": "Michael Michelitsch, Otto E. Rössler",
     "title": "The 'Burning Ship' and its Quasi-Julia Sets",
     "year": 1992, "url": "https://en.wikipedia.org/wiki/Burning_Ship_fractal"},
]


def _entry(name: str, update: str, desc: str, refs: list[dict],
           aliases: list[str] | None = None, init: str = "z = 0") -> dict:
    return {
        "name": name,
        "aliases": aliases or [],
        "iteration_type": "escape_time",
        "update": update,
        "init": init,
        "params": _PARAMS,
        "presets": [{"id": "default", "name": "Default view", "params": {}}],
        "variants": [],
        "references": refs,
        "description_en": desc,
        "source_url": refs[0].get("url", ""),
        "formula_latex": "",
    }


TABLE: list[dict] = []

# Multibrot integer powers d = 13..20 (d=3..12 already in registry)
for d in range(13, 21):
    TABLE.append(_entry(
        name=f"Multibrot z^{d}",
        update=f"z = z**{d} + c",
        desc=f"Multibrot set for z_{{n+1}} = z_n^{{{d}}} + c. The d-fold Multibrot set has (d-1)-fold rotational symmetry; for large d it approaches the unit disk with (d-1) cusps along its boundary.",
        refs=_REFS_MULTIBROT,
        aliases=[f"Multibrot d={d}", f"z^{d}+c"],
    ))

# Fractional / non-integer powers not yet in registry (existing has 1.5, 2.5)
for d in [0.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5]:
    TABLE.append(_entry(
        name=f"Multibrot d={d}",
        update=f"z = z**{d} + c",
        desc=f"Multibrot set with fractional exponent d={d}. Non-integer powers break the (d-1)-fold symmetry and produce branch-cut discontinuities visible in the escape plot.",
        refs=_REFS_MULTIBROT,
        aliases=[f"Multibrot z^{d}"],
    ))

# Negative-power multibrots (inverse-type)
for d in [-3, -4, -5]:
    TABLE.append(_entry(
        name=f"Inverse Multibrot d={d}",
        update=f"z = z**({d}) + c",
        desc=f"Inverse Multibrot z_{{n+1}} = z_n^{{{d}}} + c — negative exponent produces inversive geometry with the iteration dominated by the z→∞ attractor near origin.",
        refs=_REFS_MULTIBROT,
        aliases=[f"Multibrot d={d}"],
    ))

# Tricorn variants: z̄^d + c for d=9..15 (existing covers d=2..8)
for d in range(9, 16):
    TABLE.append(_entry(
        name=f"Tricorn d={d}",
        update=f"z = conjugate(z)**{d} + c",
        desc=f"Tricorn (mandelbar) variant z_{{n+1}} = z̄_n^{{{d}}} + c — the anti-holomorphic conjugate iteration. For d=2 this is the classic Tricorn; higher d gives generalized mandelbar sets with (d+1)-fold symmetry.",
        refs=_REFS_TRICORN,
        aliases=[f"Mandelbar d={d}", f"Multicorn d={d}"],
    ))

# Burning Ship at higher powers: abs(Re)+i*abs(Im) applied before z^d+c
for d in range(7, 13):
    TABLE.append(_entry(
        name=f"Burning Ship d={d}",
        update=f"z = (Abs(re(z)) + I*Abs(im(z)))**{d} + c",
        desc=f"Burning-Ship-style Multibrot: abs() applied to real+imag parts before raising to power {d}. Produces a generalization of Michelitsch-Rössler's burning-ship fractal at the d-th multibrot power.",
        refs=_REFS_BS,
        aliases=[f"Burning Ship z^{d}"],
    ))

# Additional variants
ADDITIONAL = [
    ("Celtic Mandelbrot", "z = Abs(re(z)**2 - im(z)**2) + 2*I*re(z)*im(z) + c",
     "Celtic Mandelbrot — takes |Re(z^2)| instead of Re(z^2); produces a cross-like shape reminiscent of Celtic knotwork.",
     "http://www.fractalforums.com/new-theories-and-research/celtic-mandelbrot/"),
    ("Buffalo Mandelbrot", "z = Abs(re(z)**2 - im(z)**2) + 2*I*Abs(re(z)*im(z)) + c",
     "Buffalo fractal — applies |Re| and |Im| to Mandelbrot iteration; named after Paul Nylander's 'buffalo' visualization.",
     "http://www.fractalforums.com/new-theories-and-research/buffalo-fractal/"),
    ("Heart Mandelbrot", "z = re(z)**2 - Abs(im(z))**2 + 2*I*re(z)*Abs(im(z)) + c",
     "Heart fractal — absolute value on imaginary component only; produces a heart-shaped main cardioid with bilateral symmetry.",
     "http://paulbourke.net/fractals/"),
    ("Perpendicular Mandelbrot",
     "z = re(z)**2 - im(z)**2 - 2*I*Abs(re(z))*im(z) + c",
     "Perpendicular Mandelbrot — burning-ship variant with abs() on only one component, producing asymmetric structure.",
     "http://paulbourke.net/fractals/mandelbrot/"),
    ("Anti-Mandelbrot",
     "z = z**2 - c",
     "Anti-Mandelbrot set z_{n+1} = z^2 - c — mirrored sign on the additive constant; equivalent to Mandelbrot under c→-c reflection but rendered as a separate set.",
     _WIKI),
    ("Cubic Mandelbrot (c-additive)",
     "z = z**3 + c*z + 1",
     "Cubic Mandelbrot variant: z_{n+1} = z^3 + c*z + 1. Studied by Milnor (1992) as the canonical cubic polynomial family.",
     "https://en.wikipedia.org/wiki/Multibrot_set"),
    ("Quartic Mandelbrot (c-additive)",
     "z = z**4 + c*z + 1",
     "Quartic Mandelbrot with linear c term — generalizes Milnor's cubic family.",
     _WIKI),
    ("Mandelbrot Scaled",
     "z = 2*z*c + z**2",
     "Scaled Mandelbrot variant used in perturbation theory; reparameterization that accelerates deep-zoom computation.",
     "https://en.wikipedia.org/wiki/Mandelbrot_set"),
    ("Lambda Mandelbrot",
     "z = c*z*(1 - z)",
     "Lambda map z_{n+1} = c*z*(1-z) — quadratic polynomial family parameterized by c; related to logistic map on the complex plane.",
     "https://en.wikipedia.org/wiki/Complex_quadratic_polynomial"),
    ("Cauliflower (period-3 bulb)",
     "z = z**2 + c; z = z**2 + c; z = z**2 + c",
     "Period-3 iteration of Mandelbrot — applied three times per step; highlights the main period-3 bulb.",
     _WIKI),
    ("Magnet 1",
     "z = ((z**2 + c - 1)/(2*z + c - 2))**2",
     "Magnet-1 fractal — physical Ising-model-inspired rational map discovered by Shigehiro Ushiki.",
     "http://paulbourke.net/fractals/magnet/"),
    ("Magnet 2",
     "z = ((z**3 + 3*(c-1)*z + (c-1)*(c-2))/(3*z**2 + 3*(c-2)*z + (c-1)*(c-2) + 1))**2",
     "Magnet-2 fractal — second in the Magnet family of rational-map Mandelbrot variants.",
     "http://paulbourke.net/fractals/magnet/"),
    ("Phoenix d=2",
     "z = z**2 + c + p*zp; zp = z",
     "Phoenix fractal (Shigehiro Ushiki 1988) — two-term recurrence z_{n+1}=z_n^2+c+p*z_{n-1} introducing memory.",
     "https://en.wikipedia.org/wiki/Phoenix_(fractal)"),
    ("Phoenix d=3",
     "z = z**3 + c + p*zp; zp = z",
     "Cubic Phoenix fractal — power-3 extension of the Phoenix recurrence with memory term.",
     "https://en.wikipedia.org/wiki/Phoenix_(fractal)"),
    ("Phoenix d=4",
     "z = z**4 + c + p*zp; zp = z",
     "Quartic Phoenix fractal — power-4 Phoenix recurrence.",
     "https://en.wikipedia.org/wiki/Phoenix_(fractal)"),
    ("Mandelbrot Power (d=2.7)",
     "z = z**2.7 + c",
     "Fractional-power Mandelbrot at d=2.7.",
     _WIKI),
    ("Mandelbrot Power (d=1.25)",
     "z = z**1.25 + c",
     "Low fractional-power Mandelbrot.",
     _WIKI),
    ("Multibrot z^1.8",
     "z = z**1.8 + c",
     "Multibrot at d=1.8 — intermediate between disk and Mandelbrot shape.",
     _WIKI),
    ("Multibrot z^2.3",
     "z = z**2.3 + c",
     "Multibrot at d=2.3 — slight distortion of canonical Mandelbrot symmetry.",
     _WIKI),
    ("Tricorn z^1.5",
     "z = conjugate(z)**1.5 + c",
     "Fractional-power Tricorn/Mandelbar at d=1.5.",
     "https://en.wikipedia.org/wiki/Tricorn_(mathematics)"),
    ("Tricorn z^2.5",
     "z = conjugate(z)**2.5 + c",
     "Fractional-power Tricorn/Mandelbar at d=2.5.",
     "https://en.wikipedia.org/wiki/Tricorn_(mathematics)"),
    ("Burning Ship z^2.5",
     "z = (Abs(re(z)) + I*Abs(im(z)))**2.5 + c",
     "Fractional-power Burning Ship at d=2.5.",
     "https://en.wikipedia.org/wiki/Burning_Ship_fractal"),
    ("Burning Ship z^1.5",
     "z = (Abs(re(z)) + I*Abs(im(z)))**1.5 + c",
     "Low fractional-power Burning Ship at d=1.5.",
     "https://en.wikipedia.org/wiki/Burning_Ship_fractal"),
]

for name, update, desc, url in ADDITIONAL:
    refs = [{"author": "Wikipedia / Paul Bourke / Fractal Forums",
             "title": name, "year": 2024, "url": url}]
    TABLE.append(_entry(name, update, desc, refs))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
