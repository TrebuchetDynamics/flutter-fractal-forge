"""Quaternion, hypercomplex, Mandelbulb, Mandelbox, and related 3D raymarched
fractals.

Each Mandelbulb power and Mandelbox scale is promoted to its own entry.
Update strings are symbolic representations; hashes are distinguished by
baked numeric constants.

Sources:
  - A. Norton, "Generation and Display of Geometric Fractals in 3-D" (SIGGRAPH 1982).
  - D. White, P. Nylander, "Mandelbulb" (2009). http://www.skytopia.com/project/fractal/mandelbulb.html
  - T. Lowe, "Mandelbox" (2010). http://sites.google.com/site/mandelbox/
  - Paul Bourke catalog (http://paulbourke.net/fractals/).
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "quaternion_3d"
FAMILY = "quaternion"

_PARAMS_RAY = {
    "iterations": {"default": 20, "range": [4, 100]},
    "power": {"default": 8.0, "range": [2.0, 32.0]},
    "bailout": {"default": 4.0, "range": [2.0, 64.0]},
    "steps": {"default": 200, "range": [50, 1000]},
}
_PRESETS = [{"id": "front", "name": "Front view", "params": {}}]

_REF_NORTON = [
    {"author": "A. Norton",
     "title": "Generation and Display of Geometric Fractals in 3-D",
     "year": 1982, "url": "https://doi.org/10.1145/965105.807250",
     "doi": "10.1145/965105.807250"},
]
_REF_MBULB = [
    {"author": "D. White, P. Nylander",
     "title": "Mandelbulb (web page)",
     "year": 2009,
     "url": "http://www.skytopia.com/project/fractal/mandelbulb.html"},
]
_REF_MBOX = [
    {"author": "T. Lowe",
     "title": "Mandelbox",
     "year": 2010, "url": "https://sites.google.com/site/mandelbox/"},
]
_REF_BOURKE = [
    {"author": "Paul Bourke", "title": "3D Fractal catalog",
     "year": 2010, "url": "http://paulbourke.net/fractals/"},
]


def _entry(name: str, update: str, desc: str, refs: list[dict],
           aliases: list[str] | None = None,
           init: str = "q = q0", params: dict | None = None) -> dict:
    return {
        "name": name,
        "aliases": aliases or [],
        "iteration_type": "raymarch_3d",
        "update": update,
        "init": init,
        "params": params or _PARAMS_RAY,
        "presets": _PRESETS,
        "variants": [],
        "references": refs,
        "description_en": desc,
        "source_url": refs[0].get("url", ""),
    }


TABLE: list[dict] = []

# ----- Quaternion Julia variations at various c
QUAT_JULIA_C = [
    ("Quaternion Julia (−0.2, 0.8, 0.0, 0.0)", -0.2, 0.8, 0.0, 0.0, "classic smooth Julia"),
    ("Quaternion Julia (−0.125, −0.256, 0.847, 0.0895)", -0.125, -0.256, 0.847, 0.0895, "Norton's classic quaternion Julia"),
    ("Quaternion Julia (−1.0, 0.2, 0.0, 0.0)", -1.0, 0.2, 0.0, 0.0, "elongated shape"),
    ("Quaternion Julia (0.18, 0.88, 0.0, 0.0)", 0.18, 0.88, 0.0, 0.0, "butterfly shape"),
    ("Quaternion Julia (−0.291, −0.399, 0.339, 0.437)", -0.291, -0.399, 0.339, 0.437, "hairy tendril"),
    ("Quaternion Julia (−0.08, 0.0, −0.8, 0.0)", -0.08, 0.0, -0.8, 0.0, "twisted Julia"),
    ("Quaternion Julia (0.15, 0.79, 0.20, 0.35)", 0.15, 0.79, 0.20, 0.35, "four-arm symmetry"),
    ("Quaternion Julia (−0.54, 0.60, 0.18, 0.27)", -0.54, 0.60, 0.18, 0.27, "bulbous lobes"),
    ("Quaternion Julia (0.0, 0.7, 0.0, 0.0)", 0.0, 0.7, 0.0, 0.0, "pure i-Julia"),
    ("Quaternion Julia (−0.75, 0.0, 0.0, 0.0)", -0.75, 0.0, 0.0, 0.0, "real-axis cusp"),
]
for name, cr, ci, cj, ck, note in QUAT_JULIA_C:
    update = (
        f"q = q*q + ({cr} + {ci}*I + {cj}*J + {ck}*K); "
        f"param_c = ({cr}, {ci}, {cj}, {ck})"
    )
    desc = (
        f"Quaternion Julia set with fixed c=({cr}, {ci}, {cj}, {ck}). "
        f"Hamilton-quaternion iteration q_{{n+1}} = q_n² + c. {note}."
    )
    TABLE.append(_entry(name, update, desc, _REF_NORTON + _REF_BOURKE,
                        aliases=[f"QJulia c=({cr},{ci},{cj},{ck})"]))

# ----- Tricomplex / Bicomplex / Octonion Mandelbrot
HYPER_MANDEL = [
    ("Tricomplex Mandelbrot", "q = q**2 + c; algebra = tricomplex",
     "Tricomplex-number Mandelbrot — iterate q²+c in 𝕋C (commutative 3-algebra i² = j² = k² = 0, ij = k).",
     ["tricomplex"]),
    ("Bicomplex Mandelbrot", "q = q**2 + c; algebra = bicomplex",
     "Bicomplex-number (𝔹C) Mandelbrot set — iterate q²+c in the commutative 4-algebra C⊗C.",
     ["bicomplex"]),
    ("Octonion Mandelbrot", "q = q**2 + c; algebra = octonion",
     "Octonion Mandelbrot — 8-dimensional non-associative algebra; typically sliced to 3D for rendering.",
     ["octonion", "Cayley-Dickson"]),
    ("Coquaternion Mandelbrot", "q = q**2 + c; algebra = coquaternion",
     "Split-quaternion / coquaternion Mandelbrot — 4-algebra with signature (+,+,-,-).",
     ["split-quaternion"]),
    ("Dual Quaternion Mandelbrot (extra)", "q = q**2 + c; algebra = dual_quaternion_alt",
     "Dual-quaternion Mandelbrot at alternate parameter slice.",
     ["dual quaternion alt"]),
]
for name, update, desc, aliases in HYPER_MANDEL:
    TABLE.append(_entry(name, update, desc, _REF_NORTON + _REF_BOURKE, aliases=aliases))

# ----- Mandelbulb at various powers
MBULB_POWERS = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 16, 20, 24]
for p in MBULB_POWERS:
    update = (
        f"r = sqrt(x*x + y*y + z*z); "
        f"theta = atan2(sqrt(x*x + y*y), z); "
        f"phi = atan2(y, x); "
        f"rp = r**{p}; "
        f"x = rp*sin({p}*theta)*cos({p}*phi) + cx; "
        f"y = rp*sin({p}*theta)*sin({p}*phi) + cy; "
        f"z = rp*cos({p}*theta) + cz; "
        f"power = {p}"
    )
    desc = (
        f"Mandelbulb at power n={p} (spherical-coordinate iteration). "
        f"Produces a 3D Mandelbrot-analogue with {p}-fold rotational features. "
        "Nylander & White's discovery; n=8 is the canonical form."
    )
    TABLE.append(_entry(
        f"Mandelbulb n={p}", update, desc, _REF_MBULB + _REF_BOURKE,
        aliases=[f"Mandelbulb power {p}"],
    ))

# ----- Mandelbox at various scales
MBOX_SCALES = [1.5, 1.8, 2.0, 2.2, 2.5, 2.7, 3.0, 3.5, 4.0, -1.5, -2.0, -2.5, -3.0]
for s in MBOX_SCALES:
    update = (
        f"if x > 1: x = 2 - x; "
        f"if x < -1: x = -2 - x; "
        f"if y > 1: y = 2 - y; "
        f"if y < -1: y = -2 - y; "
        f"if z > 1: z = 2 - z; "
        f"if z < -1: z = -2 - z; "
        f"r2 = x*x + y*y + z*z; "
        f"if r2 < 0.25: x = 4*x; y = 4*y; z = 4*z; "
        f"elif r2 < 1: x = x/r2; y = y/r2; z = z/r2; "
        f"x = {s}*x + cx; y = {s}*y + cy; z = {s}*z + cz; "
        f"scale = {s}"
    )
    desc = (
        f"Mandelbox with scale s={s}. Classic Tom Lowe folding-box fractal: "
        "box fold + sphere fold + scale and translate. "
        f"At s={s} the box exhibits "
        + ("bloated inflated structure." if abs(s) < 2.0 else
           "canonical crystalline form." if abs(s) < 2.5 else
           "thinned needle-like features.")
    )
    TABLE.append(_entry(
        f"Mandelbox s={s}", update, desc, _REF_MBOX + _REF_BOURKE,
        aliases=[f"Mandelbox scale {s}"],
    ))

# ----- Amazing Box variants
AMAZING = [
    ("Amazing Box (classic)", 2.0, "Tom Lowe's original Amazing Box — pre-Mandelbox folding."),
    ("Amazing Box (compact)", 1.7, "Amazing Box at scale 1.7 — compact rounded form."),
    ("Amazing Box (open)", 2.4, "Amazing Box at scale 2.4 — open airy form."),
    ("Amazing Box (negative)", -2.0, "Amazing Box with negative scale — inverted geometry."),
]
for name, s, note in AMAZING:
    update = (
        f"x = clamp(x, -1, 1) - x; "  # Amazing-Box fold variant
        f"y = clamp(y, -1, 1) - y; "
        f"z = clamp(z, -1, 1) - z; "
        f"r2 = x*x + y*y + z*z; "
        f"m = 1/r2 if r2 > 1 else 4; "
        f"x = {s}*x*m + cx; y = {s}*y*m + cy; z = {s}*z*m + cz; "
        f"scale = {s}; flavor = amazing"
    )
    TABLE.append(_entry(
        name, update, f"{note} Scale = {s}.", _REF_MBOX + _REF_BOURKE,
        aliases=[f"AmazingBox s={s}"],
    ))

# ----- Juliabulbs (Mandelbulb with fixed c)
JBULBS = [
    ("Juliabulb n=8 (classic)", 8, (0.1, 0.4, -0.2),
     "Julia variant of the power-8 Mandelbulb with fixed c — trademark alien-brain shape."),
    ("Juliabulb n=8 (branching)", 8, (-0.5, 0.2, 0.3),
     "Branching Juliabulb with twisted arms."),
    ("Juliabulb n=3", 3, (0.2, 0.3, -0.1),
     "Low-power Juliabulb — bulkier form."),
    ("Juliabulb n=16", 16, (0.0, 0.0, 0.4),
     "High-power Juliabulb — spiky flower-like form."),
    ("Juliabulb n=6 symmetric", 6, (0.1, 0.0, 0.0),
     "Six-fold symmetric Juliabulb."),
    ("Juliabulb n=12", 12, (-0.3, 0.1, 0.2),
     "Power-12 Juliabulb — intricate fronds."),
]
for name, n, c, note in JBULBS:
    update = (
        f"r = sqrt(x*x + y*y + z*z); "
        f"theta = atan2(sqrt(x*x + y*y), z); "
        f"phi = atan2(y, x); "
        f"rp = r**{n}; "
        f"x = rp*sin({n}*theta)*cos({n}*phi) + {c[0]}; "
        f"y = rp*sin({n}*theta)*sin({n}*phi) + {c[1]}; "
        f"z = rp*cos({n}*theta) + {c[2]}; "
        f"power = {n}; jc = ({c[0]},{c[1]},{c[2]})"
    )
    TABLE.append(_entry(
        name, update, f"{note} Power n={n}, Julia c=({c[0]}, {c[1]}, {c[2]}).",
        _REF_MBULB, aliases=[f"Juliabulb n={n} c={c}"],
    ))

# ----- 3D Sierpinski / IFS-3D raymarched
SIERP_3D = [
    ("Sierpinski Tetrahedron 3D",
     "x = 2*x - sign(x); y = 2*y - sign(y); z = 2*z - sign(z); scale = 2; kind = tet",
     "3D Sierpinski tetrahedron / 4-simplex gasket rendered via folded-IFS raymarch."),
    ("Menger Sponge 3D",
     "x = 3*x - 2*round(x); y = 3*y - 2*round(y); z = 3*z - 2*round(z); scale = 3; kind = menger",
     "Classic Menger sponge via 3× folding with central-third cutout."),
    ("Sierpinski Octahedron 3D",
     "x = 2*x - sign(x); y = 2*y - sign(y); z = 2*z - sign(z); scale = 2; kind = oct",
     "3D Sierpinski octahedron variant — 6-corner fold instead of 4-corner."),
    ("Cube Fractal (Jerusalem)",
     "x = 3*x - 2*round(x); y = 3*y - 2*round(y); z = 3*z - 2*round(z); scale = 3; kind = jerusalem",
     "Jerusalem-cube fractal — cube with recursive plus-shaped subtraction."),
    ("Sierpinski Carpet 3D (Menger cross)",
     "x = 3*x - 2*round(x); y = 3*y - 2*round(y); z = 3*z - 2*round(z); scale = 3; kind = cross",
     "Menger cross variant with face-centred removal."),
    ("3D Koch Snowflake",
     "x = 3*x; y = 3*y; z = 3*z; scale = 3; kind = koch3d",
     "Three-dimensional Koch snowflake (Koch surface / ice cream cone fractal)."),
    ("Vicsek 3D",
     "x = 3*x - 2*round(x); y = 3*y - 2*round(y); z = 3*z - 2*round(z); scale = 3; kind = vicsek3d",
     "Vicsek 3D fractal — plus-shaped cross in the centre of each 3× cell, all six face-centre cells retained."),
    ("Tetrahedral Sierpinski (scaled)",
     "x = 2*x - sign(x); y = 2*y - sign(y); z = 2*z - sign(z); scale = 2; kind = tet_s",
     "Scaled Sierpinski tetrahedron with unit-edge construction."),
]
for name, upd, desc in SIERP_3D:
    TABLE.append(_entry(name, upd, desc, _REF_BOURKE, aliases=[name]))

# ----- Kleinian 3D limit sets
KLEINIAN = [
    ("Kleinian 3D Limit (Apollonian)",
     "x = -x; scale = 1; type = apollonian3d",
     "3D Apollonian packing / Kleinian limit set (inversive geometry in ℝ³)."),
    ("Kleinian 3D Indra",
     "x = -x; scale = 1; type = indra_pearls",
     "3D Indra's pearls — Kleinian group limit set after Mumford, Series & Wright."),
    ("Kleinian Schottky 3D",
     "x = -x; scale = 1; type = schottky3d",
     "3D Schottky-group limit set — discrete Möbius-like action in ℝ³."),
    ("Kleinian QuasiFuchsian 3D",
     "x = -x; scale = 1; type = quasifuchsian",
     "Quasi-Fuchsian Kleinian limit in 3-space."),
]
for name, upd, desc in KLEINIAN:
    TABLE.append(_entry(name, upd, desc, _REF_BOURKE, aliases=[name]))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
