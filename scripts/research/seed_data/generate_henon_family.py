"""Hénon-family discrete 2D maps.

References: Hénon 1976, Tinkerbell, Lozi 1978, Ikeda 1979, Chirikov standard map,
Gingerbreadman, Pickover/de Jong/Clifford attractors.
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "henon_family"
FAMILY = "henon_disc"

_PARAMS = {
    "iterations": {"default": 100000, "range": [1000, 1000000]},
}
_PRESETS = [{"id": "default", "name": "Default", "params": {}}]


def _e(name: str, update: str, desc: str, refs: list[dict],
       aliases: list[str] | None = None, init: str = "x=0.1; y=0.1") -> dict:
    return {
        "name": name,
        "aliases": aliases or [],
        "iteration_type": "strange_attractor",  # treat discrete 2D maps as attractors
        "update": update,
        "init": init,
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": refs,
        "description_en": desc,
        "source_url": refs[0].get("url", ""),
    }


TABLE: list[dict] = [
    _e("Hénon Map",
       "xn = 1 - 1.4*x**2 + y; yn = 0.3*x",
       "Hénon map (1976): xn = 1 - a*x^2 + y, yn = b*x. Canonical parameters a=1.4, b=0.3 give the classic strange attractor — the first discovered low-dimensional chaotic attractor.",
       [{"author": "M. Hénon", "title": "A two-dimensional mapping with a strange attractor",
         "year": 1976, "url": "https://doi.org/10.1007/BF01608556",
         "doi": "10.1007/BF01608556"}],
       aliases=["Henon attractor", "Henon map"]),
    _e("Tinkerbell Map",
       "xn = x**2 - y**2 + a*x + b*y; yn = 2*x*y + c*x + d*y",
       "Tinkerbell map — discrete 2D dynamical system with trademark whisker-like attractor. Parameters a=0.9, b=-0.6013, c=2, d=0.5.",
       [{"author": "Wikipedia", "title": "Tinkerbell map", "year": 2024,
         "url": "https://en.wikipedia.org/wiki/Tinkerbell_map"}]),
    _e("Lozi Map",
       "xn = 1 - 1.7*Abs(x) + y; yn = 0.5*x",
       "Lozi map (1978) — piecewise-linear analogue of the Hénon map: xn = 1 - a*|x| + y, yn = b*x. Chaotic at a=1.7, b=0.5.",
       [{"author": "R. Lozi", "title": "Un attracteur étrange du type attracteur de Hénon",
         "year": 1978, "url": "https://doi.org/10.1051/jphyscol:1978505"}]),
    _e("Gingerbreadman Map",
       "xn = 1 - y + Abs(x); yn = x",
       "Gingerbreadman map (Devaney 1992) — piecewise-linear 2D map producing a self-similar 'gingerbread man' attractor. Origin-centred orbits trace this iconic silhouette.",
       [{"author": "R. L. Devaney", "title": "A First Course in Chaotic Dynamical Systems",
         "year": 1992, "url": "https://en.wikipedia.org/wiki/Gingerbreadman_map"}],
       aliases=["Devaney's Gingerbreadman"]),
    _e("Bogdanov Map",
       "yn = y + epsilon*y + k*x*(x-1) + mu*x*y; xn = x + y + epsilon*y + k*x*(x-1) + mu*x*y",
       "Bogdanov map — normal form of the Bogdanov-Takens bifurcation; discrete analogue of the continuous-time Bogdanov-Takens normal form.",
       [{"author": "R. Bogdanov", "title": "Versal deformations of a singular point of a vector field",
         "year": 1975, "url": "https://en.wikipedia.org/wiki/Bogdanov_map"}]),
    _e("Clifford Attractor",
       "xn = sin(a*y) + c*cos(a*x); yn = sin(b*x) + d*cos(b*y)",
       "Pickover's Clifford attractor — 2D trigonometric strange attractor family parameterized by (a,b,c,d). Produces visually striking flow-line attractors.",
       [{"author": "Clifford A. Pickover", "title": "Chaos in Wonderland",
         "year": 1994, "url": "https://paulbourke.net/fractals/clifford/"}]),
    _e("Peter de Jong Attractor",
       "xn = sin(a*y) - cos(b*x); yn = sin(c*x) - cos(d*y)",
       "Peter de Jong attractor — 2D trigonometric attractor with characteristic silky flowing structure.",
       [{"author": "Peter de Jong", "title": "Strange attractors catalog",
         "year": 1990, "url": "https://paulbourke.net/fractals/peterdejong/"}]),
    _e("Svensson Attractor",
       "xn = d*sin(a*x) - sin(b*y); yn = c*cos(a*x) + cos(b*y)",
       "Johnny Svensson attractor — trigonometric 2D attractor with distinctive curl patterns.",
       [{"author": "Johnny Svensson via Paul Bourke",
         "title": "Svensson Attractor", "year": 2005,
         "url": "https://paulbourke.net/fractals/peterdejong/"}]),
    _e("Ikeda Map",
       "t = 0.4 - 6/(1 + x**2 + y**2); xn = 1 + 0.9*(x*cos(t) - y*sin(t)); yn = 0.9*(x*sin(t) + y*cos(t))",
       "Ikeda map (1979) — discrete map modeling laser intensity in a ring cavity; canonical example of 2D chaotic attractor with folded structure.",
       [{"author": "K. Ikeda", "title": "Multiple-valued stationary state and its instability",
         "year": 1979, "url": "https://doi.org/10.1016/0030-4018(79)90090-7",
         "doi": "10.1016/0030-4018(79)90090-7"}]),
    _e("Standard Map (Chirikov)",
       "pn = p + K*sin(x); xn = x + pn",
       "Chirikov standard map — area-preserving chaotic map from kicked-rotor physics. For K > 1 the phase space becomes globally chaotic.",
       [{"author": "B. V. Chirikov",
         "title": "A universal instability of many-dimensional oscillator systems",
         "year": 1979, "url": "https://doi.org/10.1016/0370-1573(79)90023-1",
         "doi": "10.1016/0370-1573(79)90023-1"}],
       aliases=["Chirikov-Taylor map", "kicked rotor"]),
    _e("Duffing Map",
       "xn = y; yn = -b*x + a*y - y**3",
       "Duffing map — discrete 2D analogue of the Duffing equation with cubic nonlinearity.",
       [{"author": "Wikipedia", "title": "Duffing map", "year": 2024,
         "url": "https://en.wikipedia.org/wiki/Duffing_map"}]),
    _e("Zaslavskii Map",
       "xn = (x + nu*(1 + mu*y) + eps*nu*mu*cos(2*pi*x)) mod 1; yn = exp(-r)*(y + eps*cos(2*pi*x))",
       "Zaslavskii map — dissipative map with rich chaotic attractors; generalizes the standard map.",
       [{"author": "G. M. Zaslavskii", "title": "The simplest case of a strange attractor",
         "year": 1978, "url": "https://en.wikipedia.org/wiki/Zaslavskii_map"}]),
    _e("Baker's Map",
       "xn = 2*x if x < 0.5 else 2*x - 1; yn = y/2 if x < 0.5 else y/2 + 0.5",
       "Baker's map — discrete 2D volume-preserving chaotic map; paradigm for ergodicity and mixing.",
       [{"author": "Wikipedia", "title": "Baker's map", "year": 2024,
         "url": "https://en.wikipedia.org/wiki/Baker%27s_map"}]),
    _e("Horseshoe Map",
       "xn = f_horseshoe(x, y)[0]; yn = f_horseshoe(x, y)[1]",
       "Smale's horseshoe map — foundational example in symbolic dynamics and chaos theory; demonstrates homoclinic chaos via stretching and folding.",
       [{"author": "S. Smale", "title": "Differentiable dynamical systems",
         "year": 1967, "url": "https://doi.org/10.1090/S0002-9904-1967-11798-1",
         "doi": "10.1090/S0002-9904-1967-11798-1"}],
       aliases=["Smale horseshoe"]),
    _e("Belykh Map",
       "xn = 2*x - sign(x)*(y + b); yn = a*y if x*y >= 0 else a*y + 1",
       "Belykh attractor — piecewise-linear map with a well-studied basin structure.",
       [{"author": "V. N. Belykh", "title": "Bifurcation of separatrices of a saddle point",
         "year": 1980, "url": "https://en.wikipedia.org/wiki/Belykh_map"}]),
    _e("Gumowski-Mira Map",
       "xn = y + alpha*y*(1 - sigma*y**2) + f_GM(x); yn = -x + f_GM(xn)",
       "Gumowski-Mira map — conservative 2D map producing intricate nested attractor structures; widely used in fractal art.",
       [{"author": "I. Gumowski, C. Mira",
         "title": "Recurrences and Discrete Dynamic Systems",
         "year": 1980, "url": "https://en.wikipedia.org/wiki/Gumowski-Mira_map"}],
       aliases=["Mira map", "Gumowski-Mira"]),
    _e("Sinai Map (arithmetic)",
       "xn = (x + y) mod 1; yn = (x + 2*y) mod 1",
       "Sinai's arithmetic map — Anosov diffeomorphism on the torus; paradigm of mixing chaotic dynamics.",
       [{"author": "Y. Sinai",
         "title": "Ergodic properties of the Lorentz gas",
         "year": 1963, "url": "https://en.wikipedia.org/wiki/Anosov_diffeomorphism"}]),
    _e("Quadratic Map 2D",
       "xn = a1 + a2*x + a3*x**2 + a4*x*y + a5*y + a6*y**2; yn = a7 + a8*x + a9*x**2 + a10*x*y + a11*y + a12*y**2",
       "Generic 2D quadratic map — Sprott's 2D polynomial attractor family with 12 coefficients; parameter search produces many chaotic basins.",
       [{"author": "J. C. Sprott",
         "title": "Automatic generation of strange attractors",
         "year": 1993, "url": "https://sprott.physics.wisc.edu/pubs/paper191.pdf"}]),
    _e("Cubic Map 2D",
       "xn = a + b*x - x**3 + c*y; yn = d + e*x + f*y**3",
       "2D cubic polynomial attractor — Sprott's cubic 2D attractor family.",
       [{"author": "J. C. Sprott", "title": "Strange Attractors: Creating Patterns in Chaos",
         "year": 1993, "url": "https://sprott.physics.wisc.edu/fractals.htm"}]),
    _e("Tangent Map",
       "xn = tan(x + y); yn = tan(x - y)",
       "Tangent map — 2D discrete map with trigonometric nonlinearity producing chaotic orbits.",
       [{"author": "Paul Bourke", "title": "Tangent discrete map",
         "year": 2002, "url": "https://paulbourke.net/fractals/chaoticmap/"}]),
]


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
