"""More 2D maps from Pickover, Sprott catalogs and chaos-map literature (Family 7).

Sources:
  - C. Pickover, "Chaos in Wonderland" (1994), "The Pattern Book: Fractals, Art, and Nature" (1995).
  - B. Martin (Barry Martin) attractor — Bourke catalog.
  - O. E. Rossler-derived discrete maps.
  - N. Rulkov, "Modeling of spiking-bursting neural behavior using two-dimensional map" (2002).
  - J. C. Sprott, "Chaos and Time-Series Analysis" (2003).
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "pickover_extended"
FAMILY = "pickover_ext"

_PARAMS = {
    "iterations": {"default": 200000, "range": [1000, 5000000]},
}
_PRESETS = [{"id": "default", "name": "Default", "params": {}}]


def _e(name: str, update: str, init: str, desc: str, refs: list[dict],
       aliases: list[str] | None = None) -> dict:
    return {
        "name": name,
        "aliases": aliases or [],
        "iteration_type": "strange_attractor",
        "update": update,
        "init": init,
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": refs,
        "description_en": desc,
        "source_url": refs[0].get("url", ""),
    }


_BOURKE_MARTIN = "http://paulbourke.net/fractals/martin/"
_BOURKE_SVENSSON = "http://paulbourke.net/fractals/peterdejong/"
_BOURKE_GENERIC = "http://paulbourke.net/fractals/"


# -- Barry Martin attractors (a*sign(x)*sqrt|b*x - c| - d ; etc.)
def _martin(name: str, a: float, b: float, c: float, note: str) -> dict:
    update = (
        f"x_new = y - sign(x)*sqrt(abs({b}*x - {c})); "
        f"y = {a} - x; "
        f"x = x_new"
    )
    desc = (
        f"Barry Martin (Hopalong) attractor with a={a}, b={b}, c={c}. "
        f"Iteration: x' = y - sign(x)*sqrt(|b*x - c|); y' = a - x. "
        f"{note} (Pickover catalog)."
    )
    return _e(name, update, "x=0; y=0", desc,
              [{"author": "B. Martin / C. Pickover",
                "title": "Hopalong attractor", "year": 1986,
                "url": _BOURKE_MARTIN}],
              aliases=[f"Martin a={a} b={b} c={c}"])


MARTIN_SET = [
    ("Martin Hopalong (Classic)",     1.0,  2.0,  3.0,   "Classic Hopalong density."),
    ("Martin Hopalong Wide",          0.4,  1.0,  0.0,   "Wide low-density Hopalong."),
    ("Martin Hopalong Tight",         5.0,  1.5,  10.0,  "Tight central spiral."),
    ("Martin Hopalong Spiral",        2.0,  1.0,  5.0,   "Spiral arm Hopalong."),
    ("Martin Hopalong Galaxy",       -2.0, -3.0, -10.0,  "Galaxy-disk Hopalong."),
    ("Martin Hopalong Cloud",         7.7,  0.13, 8.15,  "Diffuse cloud Hopalong."),
    ("Martin Hopalong Diamond",      -200, 0.1, -80,     "Diamond-tessellated Hopalong."),
    ("Martin Hopalong Spider",        0.41, 1.05, 0.02,  "Spider-web Hopalong (slight perturbation)."),
    ("Martin Hopalong Crystal",      11.0, 0.05, 0.0,    "Crystal-lattice Hopalong."),
    ("Martin Hopalong Mosaic",        7.16878197, 8.43659746, 2.55983412, "Mosaic Hopalong."),
    ("Martin Hopalong Vortex",       -3.14, -1.41, -2.71, "Vortex centre Hopalong."),
    ("Martin Hopalong Storm",         9.7, 1.999, 50.0,  "Storm-cloud Hopalong."),
    ("Martin Hopalong Rosette",       1.4, 0.13, 6.9,    "Rose-rosette Hopalong."),
]
TABLE: list[dict] = [_martin(n, a, b, c, note) for n, a, b, c, note in MARTIN_SET]


# -- Svensson attractor (J. C. Svensson — variation on Pickover/Bourke catalog)
def _svensson(name: str, a: float, b: float, c: float, d: float, note: str) -> dict:
    update = (
        f"xn = {d}*sin({a}*x) - sin({b}*y); "
        f"yn = {c}*cos({a}*x) + cos({b}*y); "
        f"x = xn; y = yn"
    )
    desc = (
        f"Svensson attractor with a={a}, b={b}, c={c}, d={d}. "
        "Iteration: x' = d*sin(a*x) - sin(b*y); y' = c*cos(a*x) + cos(b*y). "
        f"{note}"
    )
    return _e(name, update, "x=0.1; y=0.1", desc,
              [{"author": "Johnny Svensson / Paul Bourke",
                "title": "Svensson attractor", "year": 2001,
                "url": _BOURKE_SVENSSON}],
              aliases=[f"Svensson a={a} b={b} c={c} d={d}"])


SVENSSON_SET = [
    ("Svensson Classic",      1.4,  1.56,  1.4, -6.56, "Classic high-contrast attractor."),
    ("Svensson Bloom",       -2.337, -2.337, 0.533, 1.378, "Floral bloom shape."),
    ("Svensson Storm",       -2.0,   2.0,   1.0,  1.0,  "Storm-system circulation."),
    ("Svensson Lace",         1.5,  -1.8,   1.6,  0.9,  "Delicate lace pattern."),
    ("Svensson Iris",        -1.78, -2.05, -2.55, -0.53, "Iris-flower lobes."),
    ("Svensson Wave",         1.4,   1.56,  1.4,  6.56, "Standing wave pattern."),
    ("Svensson Coral",       -1.97,  1.81,  0.82, -1.13, "Branching coral structure."),
    ("Svensson Eye",         -2.0,  -2.0,  -1.2,  2.0,  "Hurricane-eye centre."),
    ("Svensson Net",          1.4,   1.56, -1.4, -6.56, "Cobweb lattice net."),
    ("Svensson Bay",         -1.55,  1.55, -2.4,  -2.4, "Coastal bay curves."),
    ("Svensson Petals",      -2.7,   5.0,  -1.9,  1.0,  "Five petal lobes."),
    ("Svensson Arc",          1.0,   1.0,   1.0,  1.0,  "Simple arc test."),
    ("Svensson Mandala",     -2.34,  2.0,   0.2,  0.1,  "Mandala radial form."),
    ("Svensson Halo",        -2.5,   5.0,  -1.9,  1.0,  "Halo-ring structure."),
    ("Svensson Cyclone",     -2.34, -3.34,  0.5, -1.0,  "Cyclone-arm spiral."),
    ("Svensson Twist",        1.5,  -2.5,   1.5,  0.5,  "Twisted ribbon shape."),
    ("Svensson Disk",         2.0,   2.0,   1.0,  1.0,  "Filled disk density."),
    ("Svensson Tornado",     -1.4,   1.6,   1.0,  0.7,  "Tornado funnel."),
    ("Svensson Mist",        -0.2,  -1.1,  -0.5,  1.3,  "Misty fog cloud."),
    ("Svensson Fan",         -1.5,  -1.7,  -0.3, -0.7,  "Fan-blade spread."),
]
for n, a, b, c, d, note in SVENSSON_SET:
    TABLE.append(_svensson(n, a, b, c, d, note))


# -- Tyler attractor (cube-trig variant)
def _tyler(name: str, a: float, b: float, note: str) -> dict:
    update = (
        f"xn = sin({a}*y) + ({b})*y*y - x; "
        f"yn = sin({a}*x) - cos({b}*y) - y; "
        f"x = xn; y = yn"
    )
    desc = (
        f"Tyler attractor with a={a}, b={b}. "
        f"Iteration: x' = sin(a*y) + b*y² - x; y' = sin(a*x) - cos(b*y) - y. {note}"
    )
    return _e(name, update, "x=0.1; y=0.1", desc,
              [{"author": "Tim Tyler / Paul Bourke",
                "title": "Tyler attractor", "year": 2003,
                "url": _BOURKE_GENERIC + "tyler/"}],
              aliases=[f"Tyler a={a} b={b}"])


TYLER_SET = [
    ("Tyler Spiral",      1.5, 0.3,  "Spiral form."),
    ("Tyler Flower",      2.0, 0.7,  "Flower lobes."),
    ("Tyler Storm",       2.5, 0.1,  "Storm cloud."),
    ("Tyler Vortex",      1.7, -0.4, "Vortex pull."),
    ("Tyler Mesh",        2.4, 0.5,  "Mesh-grid pattern."),
    ("Tyler Filigree",    1.8, -0.6, "Filigree texture."),
    ("Tyler Knot",        2.1, 0.2,  "Knotted topology."),
    ("Tyler Web",         1.9, 0.0,  "Web-strand pattern."),
    ("Tyler Coral",       2.3, 0.4,  "Coral branches."),
    ("Tyler Rose",        2.0, -0.3, "Rose-petal form."),
]
for n, a, b, note in TYLER_SET:
    TABLE.append(_tyler(n, a, b, note))


# -- Rulkov 2D neuron map
def _rulkov(name: str, alpha: float, mu: float, sigma: float, note: str) -> dict:
    update = (
        f"xn = {alpha}/(1 + x*x) + y; "
        f"yn = y - {mu}*(x - {sigma}); "
        f"x = xn; y = yn"
    )
    desc = (
        f"Rulkov 2D neuron map with alpha={alpha}, mu={mu}, sigma={sigma}. "
        "Models spiking-bursting neuron behavior. (Rulkov 2002)."
        f" {note}"
    )
    return _e(name, update, "x=-1.0; y=-3.0", desc,
              [{"author": "N. F. Rulkov",
                "title": "Modeling of spiking-bursting neural behavior using two-dimensional map",
                "year": 2002,
                "url": "https://doi.org/10.1103/PhysRevE.65.041922",
                "doi": "10.1103/PhysRevE.65.041922"}],
              aliases=[f"Rulkov alpha={alpha}"])


RULKOV_SET = [
    ("Rulkov Tonic",      4.4,  0.001, -0.5,  "Tonic continuous spiking."),
    ("Rulkov Bursting",   4.5,  0.001, -0.6,  "Bursting regime."),
    ("Rulkov Silent",     2.5,  0.001, -1.0,  "Silent (excitable rest)."),
    ("Rulkov Chaos",      4.6,  0.001, -0.5,  "Chaotic regime."),
    ("Rulkov Slow Burst", 4.5,  0.0005, -0.6, "Slower bursting."),
    ("Rulkov Fast Spike", 5.0,  0.002, -0.5,  "Fast tonic spiking."),
]
for n, alpha, mu, sigma, note in RULKOV_SET:
    TABLE.append(_rulkov(n, alpha, mu, sigma, note))


# -- Tinkerbell map
def _tinkerbell(name: str, a: float, b: float, c: float, d: float, note: str) -> dict:
    update = (
        f"xn = x*x - y*y + {a}*x + {b}*y; "
        f"yn = 2*x*y + {c}*x + {d}*y; "
        f"x = xn; y = yn"
    )
    desc = (
        f"Tinkerbell map with a={a}, b={b}, c={c}, d={d}. "
        "Iteration: x' = x²-y² + a*x + b*y; y' = 2*x*y + c*x + d*y. "
        f"{note} (Pickover/Davies)."
    )
    return _e(name, update, "x=-0.72; y=-0.64", desc,
              [{"author": "C. Pickover", "title": "Mazes for the Mind",
                "year": 1992, "url": "https://en.wikipedia.org/wiki/Tinkerbell_map"}],
              aliases=[f"Tinkerbell a={a}"])


TINKERBELL_SET = [
    ("Tinkerbell Classic",      0.9,    -0.6013, 2.0, 0.50, "Classic Tinkerbell parameters."),
    ("Tinkerbell Distorted",    0.3,    -0.6,    2.0, 0.27, "Distorted variant."),
    ("Tinkerbell Wing",         0.7,    -0.6013, 2.0, 0.50, "Single-wing morphology."),
    ("Tinkerbell Ring",         0.4,    -0.7,    2.0, 0.50, "Ring-attractor variant."),
    ("Tinkerbell Twin",         0.9,    -0.65,   2.0, 0.50, "Twin-lobe variant."),
]
for n, a, b, c, d, note in TINKERBELL_SET:
    TABLE.append(_tinkerbell(n, a, b, c, d, note))


# -- Bogdanov map (Bogdanov-Takens normal form)
def _bogdanov(name: str, eps: float, k: float, mu: float, note: str) -> dict:
    update = (
        f"yn = y + {eps}*y + {k}*x*(x - 1) + {mu}*x*y; "
        f"xn = x + yn; "
        f"x = xn; y = yn"
    )
    desc = (
        f"Bogdanov map with epsilon={eps}, k={k}, mu={mu}. "
        f"Discrete Bogdanov-Takens normal-form bifurcation map. {note}"
    )
    return _e(name, update, "x=0.1; y=0.1", desc,
              [{"author": "R. I. Bogdanov", "title": "Bifurcations of a limit cycle for a family of vector fields on the plane",
                "year": 1976, "url": "https://en.wikipedia.org/wiki/Bogdanov_map"}],
              aliases=[f"Bogdanov k={k}"])


BOGDANOV_SET = [
    ("Bogdanov Classic",   0.0,    1.2, 0.0,   "Classic Bogdanov."),
    ("Bogdanov Period 4",  0.0001, 1.2, -0.1,  "Period-4 Bogdanov."),
    ("Bogdanov Chaos",     0.001,  1.5, -0.5,  "Chaotic Bogdanov."),
    ("Bogdanov Spiral",   -0.001,  0.8, -0.2,  "Spiral Bogdanov."),
    ("Bogdanov Birth",     0.005,  1.0, -0.3,  "Bifurcation-birth Bogdanov."),
]
for n, eps, k, mu, note in BOGDANOV_SET:
    TABLE.append(_bogdanov(n, eps, k, mu, note))


# -- Belykh map (piecewise-linear hyperbolic 2D)
def _belykh(name: str, a: float, k: float, note: str) -> dict:
    update = (
        f"branch_sign = sign(x + y - 0.5); "
        f"xn = {a}*x + branch_sign*0.5; "
        f"yn = {k}*y + branch_sign*0.5; "
        f"x = xn; y = yn"
    )
    desc = (
        f"Belykh map with a={a}, k={k}. Piecewise-linear hyperbolic 2D map. "
        f"{note} Belykh 1976."
    )
    return _e(name, update, "x=0.1; y=0.2", desc,
              [{"author": "V. N. Belykh",
                "title": "Models of discrete systems of phase synchronization",
                "year": 1976, "url": "https://en.wikipedia.org/wiki/Belykh_map"}],
              aliases=[f"Belykh a={a}"])


BELYKH_SET = [
    ("Belykh Classic",     1.5,   0.5,  "Classic Belykh attractor."),
    ("Belykh Wide",        2.0,   0.7,  "Wide Belykh."),
    ("Belykh Narrow",      1.2,   0.3,  "Narrow Belykh."),
    ("Belykh Saddle",      1.6,   0.6,  "Belykh saddle structure."),
]
for n, a, k, note in BELYKH_SET:
    TABLE.append(_belykh(n, a, k, note))


# -- Kuznetsov-Zaslavsky / Zaslavsky map
def _zaslavsky(name: str, eps: float, mu: float, omega: float, note: str) -> dict:
    update = (
        f"xn = (x + {omega} + {eps}*y) mod 1; "
        f"yn = exp(-{mu})*(y + 4.0*sin(2*3.14159265*xn)); "
        f"x = xn; y = yn"
    )
    desc = (
        f"Zaslavsky map with eps={eps}, mu={mu}, omega={omega}. "
        f"Dissipative analogue of standard map. {note}"
    )
    return _e(name, update, "x=0.5; y=0.5", desc,
              [{"author": "G. M. Zaslavsky",
                "title": "The simplest case of a strange attractor",
                "year": 1978, "url": "https://en.wikipedia.org/wiki/Zaslavskii_map"}],
              aliases=[f"Zaslavsky eps={eps}"])


ZASLAVSKY_SET = [
    ("Zaslavsky Classic", 5.0, 0.2, 0.6, "Classic Zaslavsky strange attractor."),
    ("Zaslavsky Wide",    8.0, 0.1, 0.7, "Wide-strange Zaslavsky."),
    ("Zaslavsky Tight",   3.0, 0.3, 0.5, "Tight Zaslavsky."),
    ("Zaslavsky Edge",    6.0, 0.05, 0.6, "Edge-of-chaos Zaslavsky."),
]
for n, eps, mu, omega, note in ZASLAVSKY_SET:
    TABLE.append(_zaslavsky(n, eps, mu, omega, note))


# -- Lozi map (piecewise-linear Henon)
def _lozi(name: str, a: float, b: float, note: str) -> dict:
    update = (
        f"xn = 1 - {a}*abs(x) + y; "
        f"yn = {b}*x; "
        f"x = xn; y = yn"
    )
    desc = (
        f"Lozi map with a={a}, b={b}. Piecewise-linear Hénon variant. "
        f"{note} Lozi 1978."
    )
    return _e(name, update, "x=0.0; y=0.0", desc,
              [{"author": "R. Lozi",
                "title": "Un attracteur étrange du type attracteur de Hénon",
                "year": 1978, "url": "https://en.wikipedia.org/wiki/Lozi_map"}],
              aliases=[f"Lozi a={a} b={b}"])


LOZI_SET = [
    ("Lozi Classic",    1.7,   0.5,   "Classic Lozi parameters."),
    ("Lozi Saddle",     1.4,   0.3,   "Saddle Lozi."),
    ("Lozi Edge",       1.5,   0.45,  "Edge-of-chaos Lozi."),
    ("Lozi Compact",    1.8,   0.6,   "Compact Lozi."),
    ("Lozi Strange",    1.3,   0.7,   "Strange-attractor Lozi."),
    ("Lozi Wide",       2.0,   0.4,   "Wide Lozi."),
]
for n, a, b, note in LOZI_SET:
    TABLE.append(_lozi(n, a, b, note))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
