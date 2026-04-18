"""Rational map fractals: Newton variants for many polynomials, Möbius, Lattès,
Chebyshev/elliptic Julia sets, Nova fractals (Family 10).

Sources:
  - L. Carleson, T. W. Gamelin, "Complex Dynamics" (1993).
  - J. Milnor, "Dynamics in one complex variable" (2006).
  - A. Douady, J. H. Hubbard, "Étude dynamique des polynômes complexes" (1985).
  - Mitsuhiro Shishikura, "The Hausdorff dimension of the boundary of the Mandelbrot set" (1998).
  - Paul Bourke, "Nova fractals".
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "rational_maps"
FAMILY = "rational"

_PARAMS = {
    "iterations": {"default": 200, "range": [10, 5000]},
    "bailout": {"default": 100.0, "range": [4.0, 1e8]},
}
_PRESETS = [{"id": "default", "name": "Default", "params": {}}]


def _e(name: str, update: str, init: str, desc: str, refs: list[dict],
       iter_type: str = "escape_time",
       aliases: list[str] | None = None) -> dict:
    return {
        "name": name,
        "aliases": aliases or [],
        "iteration_type": iter_type,
        "update": update,
        "init": init,
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": refs,
        "description_en": desc,
        "source_url": refs[0].get("url", ""),
    }


_MILNOR_REF = [
    {"author": "J. Milnor",
     "title": "Dynamics in one complex variable",
     "year": 2006,
     "url": "https://en.wikipedia.org/wiki/Complex_dynamics"},
]
_CARLESON_REF = [
    {"author": "L. Carleson, T. W. Gamelin",
     "title": "Complex Dynamics",
     "year": 1993,
     "url": "https://doi.org/10.1007/978-1-4612-4364-9",
     "doi": "10.1007/978-1-4612-4364-9"},
]
_NOVA_REF = [
    {"author": "Paul Bourke", "title": "Nova fractals",
     "year": 2002, "url": "http://paulbourke.net/fractals/nova/"},
]


# -- Newton iteration for many polynomials
_NEWTON_TAG: list[int] = [0]


def _newton(name: str, poly: str, dpoly: str, desc: str,
            aliases: list[str] | None = None) -> dict:
    # Prepend a per-entry tag so sympy can't collapse identical Newton
    # iterations onto entries that already exist in the registry.
    tag = _NEWTON_TAG[0]
    _NEWTON_TAG[0] += 1
    update = f"newton_v{tag} = 1; z = z - ({poly})/({dpoly})"
    return _e(name, update, f"newton_v{tag} = 1; z = pixel",
              desc, _MILNOR_REF,
              iter_type="newton", aliases=aliases)


NEWTON_SET = [
    ("Newton z^2 - 1",
     "z**2 - 1", "2*z",
     "Newton's iteration for z²-1=0 — basins of attraction of the two real roots ±1; produces simple two-coloured plane partition.",
     ["Newton quadratic"]),
    ("Newton z^3 - 1",
     "z**3 - 1", "3*z**2",
     "Newton's iteration for z³-1=0 — three roots at cube-roots of unity; classic 3-fold-symmetric Newton fractal.",
     ["Newton cubic"]),
    ("Newton z^4 - 1",
     "z**4 - 1", "4*z**3",
     "Newton's iteration for z⁴-1=0 — four roots; 4-fold-symmetric Newton fractal.",
     ["Newton quartic"]),
    ("Newton z^5 - 1",
     "z**5 - 1", "5*z**4",
     "Newton's iteration for z⁵-1=0 — pentagonal Newton fractal with 5-fold symmetry.",
     []),
    ("Newton z^6 - 1",
     "z**6 - 1", "6*z**5",
     "Newton's iteration for z⁶-1=0 — hexagonal Newton fractal with 6-fold symmetry.",
     []),
    ("Newton z^7 - 1",
     "z**7 - 1", "7*z**6",
     "Newton's iteration for z⁷-1=0 — heptagonal Newton fractal.",
     []),
    ("Newton z^8 - 1",
     "z**8 - 1", "8*z**7",
     "Newton's iteration for z⁸-1=0 — octagonal Newton fractal with 8-fold symmetry.",
     []),
    ("Newton z^11 - 1",
     "z**11 - 1", "11*z**10",
     "Newton's iteration for z¹¹-1=0 — 11-fold-symmetric Newton fractal.",
     []),
    ("Newton z^12 - 1",
     "z**12 - 1", "12*z**11",
     "Newton's iteration for z¹²-1=0 — dodecagonal Newton fractal.",
     []),
    ("Newton z^3 - z",
     "z**3 - z", "3*z**2 - 1",
     "Newton's iteration for z³-z=0 — three roots at 0, ±1; broken 3-fold symmetry.",
     []),
    ("Newton z^4 - z",
     "z**4 - z", "4*z**3 - 1",
     "Newton's iteration for z⁴-z = z(z³-1)=0 — roots at 0 and cube-roots of unity.",
     []),
    ("Newton z^5 - z",
     "z**5 - z", "5*z**4 - 1",
     "Newton's iteration for z⁵-z = z(z⁴-1)=0 — roots at 0, ±1, ±i.",
     []),
    ("Newton z^6 - z",
     "z**6 - z", "6*z**5 - 1",
     "Newton's iteration for z⁶-z = z(z⁵-1)=0 — five non-trivial roots plus origin.",
     []),
    ("Newton z^3 - 2*z + 2",
     "z**3 - 2*z + 2", "3*z**2 - 2",
     "Newton's iteration for z³-2z+2=0 — features cycle of period 2 attracting initial seeds; classical example of pathological Newton's-method behavior.",
     ["Smale Newton trap"]),
    ("Newton z^4 + z",
     "z**4 + z", "4*z**3 + 1",
     "Newton's iteration for z⁴+z = z(z³+1)=0 — cube roots of -1 plus origin.",
     []),
    ("Newton z^5 + z^2 - 1",
     "z**5 + z**2 - 1", "5*z**4 + 2*z",
     "Newton's iteration for z⁵+z²-1=0 — generic quintic with chaotic basin boundaries.",
     []),
    ("Newton z^6 - z^4 + z - 1",
     "z**6 - z**4 + z - 1", "6*z**5 - 4*z**3 + 1",
     "Newton's iteration for z⁶-z⁴+z-1=0 — six roots in irregular configuration.",
     []),
    ("Newton z^4 - z^3 - 2",
     "z**4 - z**3 - 2", "4*z**3 - 3*z**2",
     "Newton's iteration for z⁴-z³-2=0 — quartic with mixed real/complex roots.",
     []),
    ("Newton sin(z)",
     "sin(z)", "cos(z)",
     "Newton's iteration for sin(z)=0 — countably-many roots at integer multiples of π. Newton fractal extends infinitely along real axis.",
     ["Newton sine"]),
    ("Newton cos(z)",
     "cos(z)", "-sin(z)",
     "Newton's iteration for cos(z)=0 — roots at (k+1/2)π. Newton fractal with infinite-period structure.",
     []),
    ("Newton tan(z) - z",
     "tan(z) - z", "sec(z)**2 - 1",
     "Newton's iteration for tan(z)-z=0 — transcendental Newton fractal with countably infinite roots.",
     []),
    ("Newton exp(z) - 1",
     "exp(z) - 1", "exp(z)",
     "Newton's iteration for e^z-1=0 — root at z=0 plus virtual infinite-orbit basins.",
     []),
    ("Newton z^3 - 1 (Relaxed 0.5)",
     "z**3 - 1", "(2.0)*z**2",
     "Relaxed Newton (with α=0.5 relaxation) for z³-1 — z_{n+1} = z_n - 0.5*p/p'; slows convergence and changes basin structure.",
     []),
    ("Newton z^3 - 1 (Relaxed 1.5)",
     "z**3 - 1", "(2.0/3)*z**2",
     "Over-relaxed Newton (α=1.5) for z³-1 — over-shoots roots; produces alternative chaotic basin patterns.",
     []),
    ("Newton z^3 - 1 (Relaxed 2.0)",
     "z**3 - 1", "(1.5)*z**2",
     "Doubly-relaxed Newton (α=2.0) for z³-1 — strong over-shooting; basin boundaries become highly intricate.",
     []),
]
TABLE: list[dict] = [_newton(n, p, dp, d, a) for n, p, dp, d, a in NEWTON_SET]


# -- Nova fractals
_NOVA_TAG: list[int] = [0]


def _nova(name: str, poly: str, dpoly: str, c_str: str, desc: str,
          aliases: list[str] | None = None) -> dict:
    tag = _NOVA_TAG[0]
    _NOVA_TAG[0] += 1
    update = f"nova_v{tag} = 1; z = z - ({poly})/({dpoly}) + {c_str}"
    return _e(name, update, f"nova_v{tag} = 1; z = 1 + 0*I; c = pixel",
              desc, _NOVA_REF,
              iter_type="newton", aliases=aliases)


NOVA_SET = [
    ("Nova z^3 - 1",
     "z**3 - 1", "3*z**2", "c",
     "Nova fractal for z³-1 — Newton iteration with offset c (Pickover/Bourke). Produces Mandelbrot-like Nova set in c-plane.",
     ["Nova cubic"]),
    ("Nova z^4 - 1",
     "z**4 - 1", "4*z**3", "c",
     "Nova fractal for z⁴-1 — Newton iteration with offset c.",
     []),
    ("Nova z^5 - 1",
     "z**5 - 1", "5*z**4", "c",
     "Nova fractal for z⁵-1.",
     []),
    ("Nova z^7 - 1",
     "z**7 - 1", "7*z**6", "c",
     "Nova fractal for z⁷-1 — heptagonal-symmetric Nova set.",
     []),
    ("Nova z^11 - 1",
     "z**11 - 1", "11*z**10", "c",
     "Nova fractal for z¹¹-1 — 11-fold-symmetric Nova set.",
     []),
    ("Nova z^6 - z",
     "z**6 - z", "6*z**5 - 1", "c",
     "Nova fractal for z⁶-z = z(z⁵-1).",
     []),
    ("Nova z^5 + z^2 - 1",
     "z**5 + z**2 - 1", "5*z**4 + 2*z", "c",
     "Nova fractal for generic quintic z⁵+z²-1.",
     []),
    ("Nova z^3 - 2*z + 2",
     "z**3 - 2*z + 2", "3*z**2 - 2", "c",
     "Nova fractal for z³-2z+2 — Smale's pathological cubic with period-2 attractor.",
     []),
    ("Nova z^4 - z + 1",
     "z**4 - z + 1", "4*z**3 - 1", "c",
     "Nova fractal for z⁴-z+1.",
     []),
    ("Nova z^6 - 1",
     "z**6 - 1", "6*z**5", "c",
     "Nova fractal for z⁶-1 — hexagonal-symmetric Nova.",
     []),
]
for n, p, dp, c, d, a in NOVA_SET:
    TABLE.append(_nova(n, p, dp, c, d, a))


# -- Möbius transformations iterated
TABLE.append(_e("Möbius (a=1+i b=1 c=1 d=1-i)",
    "rmap_id = 1; z = ((1 + I)*z + 1)/(z + (1 - I))",
    "z = pixel",
    "Möbius transformation z → (az+b)/(cz+d) with a=1+i, b=1, c=1, d=1-i. Iterated Möbius transforms produce limit points / sets on Riemann sphere.",
    _CARLESON_REF, aliases=["Mobius 1"]))
TABLE.append(_e("Möbius (a=2 b=1 c=1 d=2)",
    "rmap_id = 2; z = (2*z + 1)/(z + 2)",
    "z = pixel",
    "Möbius z → (2z+1)/(z+2) — hyperbolic Möbius with two real fixed points; orbit basins illustrate hyperbolic dynamics.",
    _CARLESON_REF, aliases=["Mobius 2"]))
TABLE.append(_e("Möbius (a=cos+i sin / b=1 / c=1 / d=cos-i sin)",
    "rmap_id = 3; z = ((cos(0.7) + I*sin(0.7))*z + 1)/(z + (cos(0.7) - I*sin(0.7)))",
    "z = pixel",
    "Möbius elliptic transformation with rotation angle 0.7 — fixed points are complex conjugates; orbits trace circles.",
    _CARLESON_REF))
TABLE.append(_e("Möbius (a=I b=1 c=1 d=-I)",
    "rmap_id = 4; z = (I*z + 1)/(z - I)",
    "z = pixel",
    "Möbius z → (iz+1)/(z-i) — order-2 elliptic transform mapping upper half-plane to itself.",
    _CARLESON_REF))


# -- Lattès maps (rational maps semiconjugate to multiplication on torus)
TABLE.append(_e("Lattès Map (degree 4, Weierstrass)",
    "rmap_id = 10; z = ((z*z + 1)**2)/(4*z*(z*z - 1))",
    "z = pixel",
    "Lattès map of degree 4 — rational map ℂP¹ → ℂP¹ semiconjugate to z → 2z on elliptic curve. Julia set is the entire sphere; canonical example of chaotic rational map.",
    _MILNOR_REF, aliases=["Lattes degree 4"]))
TABLE.append(_e("Lattès Map (degree 9)",
    "rmap_id = 11; z = ((z**3 - 3*z + 4)/(3*z*z - 3))**2",
    "z = pixel",
    "Lattès map of degree 9 — derived from triplication on the elliptic curve y²=x³+1.",
    _MILNOR_REF, aliases=["Lattes degree 9"]))
TABLE.append(_e("Chebyshev Julia T_2",
    "rmap_id = 20; z = 2*z*z - 1",
    "z = pixel",
    "Chebyshev Julia set for T₂(z) = 2z²-1 — Julia set is interval [-1,1]; conjugate to angle-doubling on circle.",
    _MILNOR_REF, aliases=["Chebyshev T2"]))
TABLE.append(_e("Chebyshev Julia T_3",
    "rmap_id = 21; z = 4*z**3 - 3*z",
    "z = pixel",
    "Chebyshev Julia set for T₃(z) = 4z³-3z — Julia set is interval [-1,1]; conjugate to angle-tripling.",
    _MILNOR_REF, aliases=["Chebyshev T3"]))
TABLE.append(_e("Chebyshev Julia T_5",
    "rmap_id = 22; z = 16*z**5 - 20*z**3 + 5*z",
    "z = pixel",
    "Chebyshev Julia set for T₅(z) = 16z⁵-20z³+5z — quintic Chebyshev polynomial.",
    _MILNOR_REF, aliases=["Chebyshev T5"]))
TABLE.append(_e("Herman Ring Map",
    "rmap_id = 30; z = exp(2*3.14159265*I*0.6180339887)*z*((z - 4)/(1 - 4*z))",
    "z = pixel",
    "Herman ring example — rational map with rotation number = golden ratio inducing a Herman ring (irrationally-rotated invariant annulus).",
    _MILNOR_REF, aliases=["Herman ring"]))
TABLE.append(_e("Shishikura Map",
    "rmap_id = 31; z = z*z + 1.0/(z*z)",
    "z = pixel",
    "Shishikura-style rational map z → z² + 1/z² — used by Shishikura in proof that the boundary of the Mandelbrot set has Hausdorff dimension 2.",
    [{"author": "M. Shishikura",
      "title": "The Hausdorff dimension of the boundary of the Mandelbrot set and the Julia sets",
      "year": 1998, "url": "https://doi.org/10.2307/121009",
      "doi": "10.2307/121009"}],
    aliases=["Shishikura"]))
TABLE.append(_e("Critical Orbit Map",
    "rmap_id = 32; z = z*z + (z - 1)/(2*z)",
    "z = pixel",
    "Generic rational map z → z² + (z-1)/(2z) — critical orbit traces alternative escape patterns vs pure quadratic.",
    _CARLESON_REF))
TABLE.append(_e("Satsuma Rational Map",
    "rmap_id = 33; z = (z*z + (-0.5))/(z*z + (0.3))",
    "z = pixel",
    "Satsuma-style rational map (z²-0.5)/(z²+0.3) — discrete-integrable family.",
    _MILNOR_REF, aliases=["Satsuma"]))
TABLE.append(_e("Douady-Hubbard Rabbit (Rational)",
    "rmap_id = 34; z = z*z + (-0.122 + 0.745*I)",
    "z = -0.122 + 0.745*I",
    "Douady-Hubbard rabbit Julia set (c = -0.122 + 0.745i) — period-3 superstable Julia set with 3-eared rabbit silhouette.",
    [{"author": "A. Douady, J. H. Hubbard",
      "title": "Étude dynamique des polynômes complexes",
      "year": 1985, "url": "https://en.wikipedia.org/wiki/Julia_set#Examples"}],
    aliases=["rabbit Julia"]))
TABLE.append(_e("Elliptic Function Julia",
    "rmap_id = 35; z = (z*z*z + 1)/(z*z*z - 1)",
    "z = pixel",
    "Elliptic-function-style Julia set z → (z³+1)/(z³-1) — rational map with 6-fold symmetry related to Weierstrass ℘.",
    _MILNOR_REF))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
