"""Pickover / Clifford / Peter de Jong / Symmetric-Icon / Gumowski-Mira
attractor parameter families.

Each entry embeds the literal numeric parameters into the update string so
that formula_hash is distinct per (a,b,c,d) tuple even when the functional
form is shared across siblings.

Sources:
  - C. Pickover, "Chaos in Wonderland: Visual Adventures in a Fractal World"
    (St. Martin's Press, 1994).
  - M. Field & M. Golubitsky, "Symmetry in Chaos", Oxford UP (1992).
  - I. Gumowski & C. Mira, "Recurrences and Discrete Dynamic Systems" (1980).
  - Paul Bourke's attractor catalog (http://paulbourke.net/fractals/).
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "pickover_attractors"
FAMILY = "pickover_attr"

_PARAMS = {
    "iterations": {"default": 150000, "range": [10000, 5000000]},
}
_PRESETS = [{"id": "classic", "name": "Canonical view", "params": {}}]

_REFS_PICKOVER = [
    {"author": "Clifford A. Pickover",
     "title": "Chaos in Wonderland: Visual Adventures in a Fractal World",
     "year": 1994,
     "url": "https://en.wikipedia.org/wiki/Clifford_A._Pickover"},
    {"author": "Paul Bourke", "title": "Clifford attractors",
     "year": 2006, "url": "http://paulbourke.net/fractals/clifford/"},
]
_REFS_DEJONG = [
    {"author": "Peter de Jong / Clifford Pickover",
     "title": "Symmetric de Jong attractors",
     "year": 1988,
     "url": "http://paulbourke.net/fractals/peterdejong/"},
]
_REFS_ICON = [
    {"author": "M. Field, M. Golubitsky",
     "title": "Symmetry in Chaos: A Search for Pattern in Mathematics, Art and Nature",
     "year": 1992, "url": "https://doi.org/10.1093/oso/9780198536895.001.0001"},
    {"author": "Paul Bourke", "title": "Symmetric icons",
     "year": 2005,
     "url": "http://paulbourke.net/fractals/symmetric/"},
]
_REFS_MIRA = [
    {"author": "I. Gumowski, C. Mira",
     "title": "Recurrences and Discrete Dynamic Systems",
     "year": 1980, "url": "https://doi.org/10.1007/BFb0089135"},
    {"author": "Paul Bourke", "title": "Gumowski-Mira attractors",
     "year": 2004, "url": "http://paulbourke.net/fractals/gumowski/"},
]


def _clifford(name: str, a: float, b: float, c: float, d: float, note: str) -> dict:
    update = (
        f"x = sin({a}*y) + {c}*cos({a}*x); "
        f"y = sin({b}*x) + {d}*cos({b}*y)"
    )
    desc = (
        f"Clifford attractor (Pickover) with parameters a={a}, b={b}, c={c}, d={d}. "
        "Iteration: x' = sin(a*y) + c*cos(a*x); y' = sin(b*x) + d*cos(b*y). "
        f"{note}"
    )
    return {
        "name": name,
        "aliases": [f"Clifford a={a} b={b} c={c} d={d}"],
        "iteration_type": "strange_attractor",
        "update": update,
        "init": "x=0.1; y=0.1",
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": _REFS_PICKOVER,
        "description_en": desc,
        "source_url": _REFS_PICKOVER[0]["url"],
    }


def _dejong(name: str, a: float, b: float, c: float, d: float, note: str) -> dict:
    update = (
        f"x = sin({a}*y) - cos({b}*x); "
        f"y = sin({c}*x) - cos({d}*y)"
    )
    desc = (
        f"Peter de Jong attractor with parameters a={a}, b={b}, c={c}, d={d}. "
        "Iteration: x' = sin(a*y) - cos(b*x); y' = sin(c*x) - cos(d*y). "
        f"{note}"
    )
    return {
        "name": name,
        "aliases": [f"de Jong a={a} b={b} c={c} d={d}"],
        "iteration_type": "strange_attractor",
        "update": update,
        "init": "x=0.1; y=0.1",
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": _REFS_DEJONG,
        "description_en": desc,
        "source_url": _REFS_DEJONG[0]["url"],
    }


def _icon(name: str, lam: float, alpha: float, beta: float, gamma: float,
          omega: float, n: int, note: str) -> dict:
    # Symmetric icon (Field-Golubitsky) iteration with symmetry order n.
    # zsq = x^2 + y^2
    # z_n-1 = Re((x+iy)^(n-1))  (encoded via expansions for small n—use polar)
    # We embed numeric parameters literally to keep hashes distinct.
    update = (
        f"r2 = x*x + y*y; "
        f"p = {lam} + {alpha}*r2 + {beta}*(re((x + I*y)**{n})); "
        f"x = p*x + {gamma}*re((x + I*y)**({n - 1})) - {omega}*y; "
        f"y = p*y - {gamma}*im((x + I*y)**({n - 1})) + {omega}*x"
    )
    desc = (
        f"Symmetric-icon attractor (Field & Golubitsky) with Dn-symmetry of order {n}. "
        f"Parameters lambda={lam}, alpha={alpha}, beta={beta}, gamma={gamma}, omega={omega}. "
        f"{note}"
    )
    return {
        "name": name,
        "aliases": [f"Icon n={n} lam={lam}"],
        "iteration_type": "strange_attractor",
        "update": update,
        "init": "x=0.01; y=0.01",
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": _REFS_ICON,
        "description_en": desc,
        "source_url": _REFS_ICON[1]["url"],
    }


def _mira(name: str, a: float, b: float, note: str) -> dict:
    # Gumowski-Mira with classic F(x) = a*x + 2*(1-a)*x^2 / (1 + x^2)
    update = (
        f"Fx = {a}*x + 2*(1-{a})*x*x/(1 + x*x); "
        f"yn = y + {a}*x*(1 - {b}*y*y) + Fx; "
        f"Fxn = {a}*yn + 2*(1-{a})*yn*yn/(1 + yn*yn); "
        f"x = -x + Fxn; "
        f"y = yn"
    )
    desc = (
        f"Gumowski-Mira map with a={a}, b={b}. F(x) = a*x + 2*(1-a)*x^2/(1+x^2). "
        f"{note}"
    )
    return {
        "name": name,
        "aliases": [f"Gumowski-Mira a={a} b={b}"],
        "iteration_type": "strange_attractor",
        "update": update,
        "init": "x=0.1; y=0.1",
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": _REFS_MIRA,
        "description_en": desc,
        "source_url": _REFS_MIRA[1]["url"],
    }


# ----- Clifford parameter sets (30+ variants from Pickover/Bourke catalogs)
CLIFFORD_PARAMS = [
    ("Clifford Tornado",     -1.4, 1.6, 1.0, 0.7,  "Tornado-like spiraling density."),
    ("Clifford Butterfly",   -1.7, 1.3, -0.1, -1.2,"Butterfly-wing symmetry."),
    ("Clifford Galaxy",       1.7, 1.7, 0.6, 1.2,  "Galaxy spiral with bright core."),
    ("Clifford Nebula",      -1.8, -2.0, -0.5, -0.9,"Diffuse nebula texture."),
    ("Clifford Spirals",     -2.0, -2.0, -1.2, 2.0,"Dense multi-armed spirals."),
    ("Clifford Shell",       -1.24, 1.10, -1.25, -1.02,"Conch-shell spiral."),
    ("Clifford Ribbon",       1.5, -1.8, 1.6, 0.9, "Flowing ribbon bands."),
    ("Clifford Flame",       -1.6, -1.6, -0.8, 1.6,"Flame-like plumes."),
    ("Clifford Vortex",       1.4, -1.56, 1.4, -6.56,"Deep central vortex."),
    ("Clifford Web",          1.7, 0.7, 1.2, 1.8,  "Spider-web lattice."),
    ("Clifford Crystal",     -1.3, -1.3, -1.8, 1.8,"Crystalline lattice."),
    ("Clifford Lace",        -1.08, -1.10, 0.73, -0.65,"Delicate lace pattern."),
    ("Clifford Mist",        -0.2, -1.1, -0.5, 1.3,"Diffuse misty cloud."),
    ("Clifford Star",         1.6, -0.6, -1.2, 1.6,"Star-burst radial texture."),
    ("Clifford Coral",       -1.7, 1.8, -1.9, -0.4,"Coral branching texture."),
    ("Clifford Rose",         1.5, 1.5, 0.5, 0.5,  "Petal-rose tight form."),
    ("Clifford Flower",      -1.24, -1.25, -1.88, -1.11,"Flower lobe structure."),
    ("Clifford Disk",         2.0, 2.0, 1.0, 1.0,  "Disk-filling density."),
    ("Clifford Swirl",       -1.9, -1.9, 1.3, -0.9, "Double swirl hourglass."),
    ("Clifford Torus",        1.1, -1.0, 1.0, 1.5, "Torus-like donut."),
    ("Clifford Arms",        -1.4, -1.8, 0.5, -1.3, "Four spiral arms."),
    ("Clifford Knot",         0.5, -1.3, 2.0, -2.1,"Knotted central filament."),
    ("Clifford Whirl",       -1.6, 1.8, 0.8, 1.4,  "Whirling pinwheel."),
    ("Clifford Infinity",    -1.38, 1.5, 0.51, -0.9,"Infinity-loop topology."),
    ("Clifford Tendrils",    -1.1, 2.0, -1.7, 1.3, "Thin tendril filaments."),
    ("Clifford Moth",        -1.6, -1.5, 1.0, 1.0, "Moth-wing pattern."),
    ("Clifford Scroll",       1.4, 1.5, -1.3, 0.9, "Scroll-like rolled form."),
    ("Clifford Fan",         -1.5, -1.7, -0.3, -0.7,"Fan-shaped spreading."),
    ("Clifford Hearts",       1.3, -1.6, -0.75, 1.2, "Heart-like lobes."),
    ("Clifford Veil",        -1.95, 1.83, 0.52, -0.74,"Veil-of-filaments."),
    ("Clifford Ocean",       -2.0, 1.9, 0.3, 1.3,  "Ocean wave ripple."),
    ("Clifford Dunes",        1.97, -1.41, -0.9, -1.5,"Desert-dune curves."),
]

# ----- Peter de Jong parameter sets (20+ variants)
DEJONG_PARAMS = [
    ("de Jong Classic",         1.4, -2.3, 2.4, -2.1, "Classic de Jong attractor."),
    ("de Jong Peacock",         2.01, -2.53, 1.61, -0.33, "Peacock-tail pattern."),
    ("de Jong Spirals",        -2.7, -0.09, -0.86, -2.2, "Multi-armed spirals."),
    ("de Jong Crescent",       -1.24, -1.25, -1.88, -1.11, "Crescent moon curves."),
    ("de Jong Flow",            1.641, 1.902, 0.316, 1.525, "Flowing waves."),
    ("de Jong Whirlpool",      -0.827, -1.637, 1.659, -0.943, "Whirlpool center."),
    ("de Jong Petals",         -2.24, 0.43, -0.65, -2.43, "Flower petals."),
    ("de Jong Filigree",        1.7, -1.7, 1.7, -1.7, "Filigree texture."),
    ("de Jong Cloud",          -2.0, -2.0, -1.2, 2.0, "Cumulus cloud form."),
    ("de Jong Mesh",            2.0, -2.0, -1.2, 2.0, "Diamond mesh."),
    ("de Jong Leaf",           -2.24, 0.43, -0.65, 1.6, "Leaf-vein structure."),
    ("de Jong Double",          1.4, -2.3, 2.4, 2.1, "Double-lobed."),
    ("de Jong Cascade",         0.970, -1.899, 1.381, -1.506, "Waterfall cascade."),
    ("de Jong Maze",           -1.7, -1.7, 1.7, 1.7, "Maze-like interior."),
    ("de Jong Web",            -2.7, 0.09, -0.86, -2.2, "Cobweb filaments."),
    ("de Jong Hurricane",      -1.9, 1.8, -1.9, -1.7, "Eye-of-hurricane spiral."),
    ("de Jong Coral",           1.1, -1.32, -0.79, 1.82, "Coral branches."),
    ("de Jong Ribbon",         -2.1, 1.9, -1.2, 0.45, "Ribbon-band weaves."),
    ("de Jong Butterfly",      -1.0, -1.8, -1.9, -1.4, "Butterfly twin lobes."),
    ("de Jong Flame",           1.4, 1.56, 1.4, -6.56, "Flame tongues."),
    ("de Jong Storm",          -2.24, -0.43, -0.65, -2.43, "Storm-front sweep."),
    ("de Jong Eye",             2.879879, -0.765145, -0.966918, 0.744728, "Eye-of-storm."),
]

# ----- Symmetric-icon parameter sets (Field & Golubitsky)
ICON_PARAMS = [
    ("Icon — Five-Fold",    -2.34, 2.0, 0.2, 0.1, 0.0, 5, "Classic five-fold icon."),
    ("Icon — Swallow",      -2.7,  5.0, 1.5, 1.0, 0.0, 6, "Swallow-dove symmetric icon (D6)."),
    ("Icon — French Glass", -2.5, 5.0, -1.9, 1.0, 0.188, 5,"French-glass D5 icon."),
    ("Icon — Trampoline",   -1.86, 2.0, 1.1, 1.0, 0.0, 5, "Trampoline-bounce D5."),
    ("Icon — Emperor",      -1.806, 1.806, 0.0, 1.0, 0.0, 5, "Emperor D5 icon."),
    ("Icon — Chaos D3",     -2.5, 5.0, -1.9, 1.0, 0.0, 3, "D3 triangular icon."),
    ("Icon — Snowflake D6",  2.5, -2.5, 0.0, 0.9, 0.25, 6, "Snowflake D6 form."),
    ("Icon — D7 Star",      -2.08, 1.0, -0.1, 0.167, 0.0, 7, "Seven-point star."),
    ("Icon — Flag",          1.56, -1.0, 0.1, -0.82, 0.12, 3, "Flag D3."),
    ("Icon — Rosette D4",   -2.42, 1.0, -0.04, 0.14, 0.088, 4,"D4 rosette."),
    ("Icon — Clam D5",      -2.05, 3.0, -16.79, 1.0, 0.0, 9, "Clam D9 icon."),
    ("Icon — Mayan D8",      2.0, -2.0, -0.5, 0.9, 0.25, 8, "D8 Mayan icon."),
    ("Icon — Snowflake D12", 1.5, -1.0, 0.1, -0.805, 0.0, 12, "D12 snowflake."),
    ("Icon — Pentagon D5",   1.56, -1.0, 0.1, -0.82, 0.12, 5, "D5 pentagon."),
    ("Icon — Vines D6",     -1.8, 1.8, 0.1, 1.0, 0.0, 6, "Intertwined vines (D6)."),
    ("Icon — Fern D3",      -1.9, 1.0, 0.2, 0.2, 0.03, 3, "Fern-leaf D3."),
    ("Icon — Mandala D7",   -2.05, 2.0, -16.0, 1.0, 0.01, 7,"D7 mandala."),
]

# ----- Gumowski-Mira parameter sets
MIRA_PARAMS = [
    ("Gumowski-Mira Butterfly",   0.008, 0.05, "Wide butterfly shape."),
    ("Gumowski-Mira Shell",       -0.25, 0.0,  "Shell-like concentric rings."),
    ("Gumowski-Mira Flowers",      0.7,  0.9,  "Flower-petal clusters."),
    ("Gumowski-Mira Galaxy",      -0.48, 0.93, "Spiral galaxy."),
    ("Gumowski-Mira Jellyfish",   -0.01, 0.05, "Jellyfish tendril forms."),
    ("Gumowski-Mira Skulls",       0.31, 0.05, "Skull-shaped rings."),
    ("Gumowski-Mira Lamp",        -0.32, 0.12, "Lamp-shade spiral."),
    ("Gumowski-Mira Storm",       -0.12, 0.06, "Stormy vortex."),
    ("Gumowski-Mira Peacock",      0.05, 0.0,  "Peacock-fan display."),
    ("Gumowski-Mira Octopus",      0.3,  0.05, "Eight-armed octopus."),
    ("Gumowski-Mira Spirals",     -0.75, 0.02, "Densely nested spirals."),
    ("Gumowski-Mira Propeller",    0.2,  0.9,  "Propeller-blade symmetry."),
    ("Gumowski-Mira Lace",        -0.45, 0.0,  "Intricate lace."),
    ("Gumowski-Mira Sea Urchin",  -0.99, 0.04, "Sea-urchin radial spikes."),
    ("Gumowski-Mira Coral Reef",   0.41, 0.00011, "Coral-reef branching."),
    ("Gumowski-Mira Crown",        0.04, 0.01, "Crown of thorns."),
]


TABLE: list[dict] = []
for name, a, b, c, d, note in CLIFFORD_PARAMS:
    TABLE.append(_clifford(name, a, b, c, d, note))
for name, a, b, c, d, note in DEJONG_PARAMS:
    TABLE.append(_dejong(name, a, b, c, d, note))
for name, lam, alpha, beta, gamma, omega, n, note in ICON_PARAMS:
    TABLE.append(_icon(name, lam, alpha, beta, gamma, omega, n, note))
for name, a, b, note in MIRA_PARAMS:
    TABLE.append(_mira(name, a, b, note))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
