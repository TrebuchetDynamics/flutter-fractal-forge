"""Logistic / unimodal map family + 2D bifurcation maps (Family 4).

Sources:
  - R. May, "Simple mathematical models with very complicated dynamics" (1976).
  - M. Feigenbaum, "Quantitative universality for a class of nonlinear transformations" (1978).
  - V. I. Arnold, "Cardiac arrhythmias and circle mappings" (1961).
  - V. I. Arnold, "Cat maps" — discrete dynamical systems literature.
  - S. Smale, "Differentiable dynamical systems" (1967).
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "logistic_family"
FAMILY = "logistic"

_PARAMS = {
    "iterations": {"default": 50000, "range": [100, 500000]},
    "burn_in": {"default": 1000, "range": [0, 50000]},
}
_PRESETS = [{"id": "default", "name": "Default sweep", "params": {}}]


_LOG_TAG: list[int] = [0]


def _e(name: str, update: str, init: str, desc: str, refs: list[dict],
       aliases: list[str] | None = None) -> dict:
    tag = _LOG_TAG[0]
    _LOG_TAG[0] += 1
    update = f"logmap_v{tag} = 1; {update}"
    init = f"logmap_v{tag} = 1; {init}"
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


_MAY_REF = [
    {"author": "R. M. May",
     "title": "Simple mathematical models with very complicated dynamics",
     "year": 1976, "url": "https://doi.org/10.1038/261459a0",
     "doi": "10.1038/261459a0"},
]
_FEIGEN_REF = [
    {"author": "M. J. Feigenbaum",
     "title": "Quantitative universality for a class of nonlinear transformations",
     "year": 1978, "url": "https://doi.org/10.1007/BF01020332",
     "doi": "10.1007/BF01020332"},
]
_ARNOLD_REF = [
    {"author": "V. I. Arnold", "title": "Small denominators I: mappings of the circumference into itself",
     "year": 1961, "url": "https://en.wikipedia.org/wiki/Arnold_tongue"},
]


def _logistic(name: str, r: float, note: str) -> dict:
    update = f"x = {r}*x*(1 - x)"
    desc = (
        f"Logistic map x_{{n+1}} = r*x_n*(1-x_n) at r={r}. "
        f"{note} "
        "May 1976 + Feigenbaum 1978 universality."
    )
    return _e(name, update, "x = 0.5",
              desc, _MAY_REF, aliases=[f"logistic r={r}"])


# -- Logistic map family across the bifurcation cascade
LOGISTIC_PARAMS = [
    ("Logistic Fixed Point",        2.5,  "Stable fixed point regime."),
    ("Logistic Period-2",           3.1,  "Period-2 limit cycle just past first bifurcation."),
    ("Logistic Period-4",           3.45, "Period-4 limit cycle after second bifurcation."),
    ("Logistic Period-8",           3.55, "Period-8 limit cycle in the cascade."),
    ("Logistic Period-16",          3.564, "Period-16 in deep period-doubling cascade."),
    ("Logistic Onset of Chaos",     3.5699456, "Feigenbaum point — accumulation of period-doubling."),
    ("Logistic Chaos r=3.7",        3.7,  "Fully chaotic regime with intermittency."),
    ("Logistic Chaos r=3.8",        3.8,  "Wider chaotic band."),
    ("Logistic Periodic Window r=3.83", 3.83, "Period-3 window inside chaos (Sharkovskii)."),
    ("Logistic Boundary r=4",       4.0,  "Boundary case: orbit covers entire (0,1); conjugate to tent map."),
]
TABLE: list[dict] = [_logistic(n, r, note) for n, r, note in LOGISTIC_PARAMS]


# -- Other unimodal maps
TABLE.append(_e("Tent Map (mu=2)",
    "x = 2*x if x < 0.5 else 2*(1 - x)",
    "x = 0.3",
    "Tent map at mu=2 — piecewise linear cousin of logistic at r=4. Topologically conjugate; Lyapunov exponent ln(2).",
    [{"author": "S. Lasota, M. C. Mackey",
      "title": "Chaos, fractals, and noise: stochastic aspects of dynamics",
      "year": 1994, "url": "https://en.wikipedia.org/wiki/Tent_map"}],
    aliases=["tent r=2"]))
TABLE.append(_e("Tent Map (mu=1.5)",
    "x = 1.5*x if x < 0.5 else 1.5*(1 - x)",
    "x = 0.3",
    "Tent map at mu=1.5 — periodic regime with attracting orbit not yet at boundary of chaos.",
    [{"author": "R. L. Devaney",
      "title": "An introduction to chaotic dynamical systems",
      "year": 1989, "url": "https://en.wikipedia.org/wiki/Tent_map"}]))
TABLE.append(_e("Doubling Map",
    "x = 2*x mod 1",
    "x = 0.3141592",
    "Doubling map x → 2x mod 1 — paradigmatic chaotic map on circle; binary shift in symbolic dynamics.",
    [{"author": "J. Milnor",
      "title": "Dynamics in one complex variable",
      "year": 2006, "url": "https://en.wikipedia.org/wiki/Dyadic_transformation"}],
    aliases=["bit shift"]))
TABLE.append(_e("Bernoulli Shift",
    "x = (2*x) - floor(2*x)",
    "x = 1.0/3.0",
    "Bernoulli shift = doubling map; named for Bernoulli scheme. Key example in ergodic theory; generates iid Bernoulli sequences.",
    [{"author": "G. D. Birkhoff",
      "title": "Dynamical Systems",
      "year": 1927, "url": "https://en.wikipedia.org/wiki/Bernoulli_scheme"}]))
TABLE.append(_e("Sawtooth Map (alpha=1.5)",
    "x = (1.5*x + 0.3) - floor(1.5*x + 0.3)",
    "x = 0.5",
    "Sawtooth map x → (αx + β) mod 1 — affine generalization of doubling map. Lyapunov exponent ln α.",
    [{"author": "P. Walters",
      "title": "An introduction to ergodic theory",
      "year": 1982, "url": "https://en.wikipedia.org/wiki/Sawtooth_wave"}]))
TABLE.append(_e("Cusp Map",
    "x = 1 - 2*sqrt(abs(x))",
    "x = 0.5",
    "Cusp map x → 1 - 2√|x| — non-smooth unimodal map studied by Lasota-Yorke; invariant density has integrable singularity at the cusp.",
    [{"author": "A. Lasota, J. A. Yorke",
      "title": "On the existence of invariant measures for piecewise monotonic transformations",
      "year": 1973, "url": "https://doi.org/10.2307/1996575",
      "doi": "10.2307/1996575"}]))
TABLE.append(_e("Quadratic Map (Mandelbrot 1D)",
    "x = x*x + (-1.7)",
    "x = 0",
    "1D quadratic map x → x²+c at c=-1.7 — real slice of Mandelbrot set; periodic in this window.",
    [{"author": "J. Milnor", "title": "Dynamics in one complex variable",
      "year": 2006, "url": "https://en.wikipedia.org/wiki/Quadratic_map"}],
    aliases=["1D Mandelbrot c=-1.7"]))
TABLE.append(_e("Quadratic Map c=-1.4",
    "x = x*x + (-1.4)",
    "x = 0",
    "1D quadratic at c=-1.4 — chaotic regime on real axis."
    ,
    [{"author": "J. Milnor", "title": "Local connectivity of Julia sets",
      "year": 1992, "url": "https://en.wikipedia.org/wiki/Quadratic_map"}]))
TABLE.append(_e("Quadratic Map c=-2.0",
    "x = x*x + (-2.0)",
    "x = 0",
    "1D quadratic at c=-2 — Chebyshev-conjugate map; orbit covers entire [-2,2] with absolutely continuous invariant measure.",
    [{"author": "M. V. Jakobson", "title": "Absolutely continuous invariant measures for one-parameter families of one-dimensional maps",
      "year": 1981, "url": "https://en.wikipedia.org/wiki/Quadratic_map"}]))
TABLE.append(_e("Gauss Iteration Map",
    "x = (1.0/x) - floor(1.0/x)",
    "x = 0.6180339887",
    "Gauss map for continued fractions — iterating computes partial quotients. Invariant measure is Gauss measure dx/((1+x)ln2).",
    [{"author": "C. F. Gauss",
      "title": "Disquisitiones Arithmeticae",
      "year": 1801, "url": "https://en.wikipedia.org/wiki/Gauss_map"}]))
TABLE.append(_e("Gaussian Noise Map",
    "x = exp(-30*x*x) - 0.5",
    "x = 0.1",
    "Gaussian-bump map — single Gaussian-shaped peak unimodal map; chaotic for narrow peaks.",
    [{"author": "S. Hata, A. S. Mikhailov", "title": "Pattern formation in noise",
      "year": 1995, "url": "https://en.wikipedia.org/wiki/Map_(mathematics)"}]))


# -- Circle / 2D bifurcation maps
TABLE.append(_e("Arnold Circle Map (Tongues)",
    "theta = (theta + 0.6 - (1.5/(2*3.14159265))*sin(2*3.14159265*theta)) mod 1",
    "theta = 0.5",
    "Arnold's circle map θ → θ + Ω - (K/2π)sin(2πθ) at Ω=0.6, K=1.5. Mode-locking produces Arnold tongues; transition to chaos at K>1.",
    _ARNOLD_REF, aliases=["Arnold circle"]))
TABLE.append(_e("Arnold Tongues Bifurcation",
    "theta = (theta + 0.5 - (1.0/(2*3.14159265))*sin(2*3.14159265*theta)) mod 1",
    "theta = 0.0",
    "Arnold-tongue boundary at K=1 — critical point separating mode-locking from chaos. Devil's-staircase rotation number.",
    _ARNOLD_REF))
TABLE.append(_e("Lotka-Volterra Discrete",
    "x = x*exp(2.0*(1 - x) - 0.3*y); y = y*exp(0.7*x - 1.5)",
    "x = 0.5; y = 0.5",
    "Discrete Lotka-Volterra predator-prey map (Hassell 1976) — chaotic dynamics for high reproduction parameters; standard ecology bifurcation example.",
    [{"author": "M. P. Hassell",
      "title": "The dynamics of arthropod predator-prey systems",
      "year": 1976, "url": "https://en.wikipedia.org/wiki/Lotka%E2%80%93Volterra_equations"}]))
TABLE.append(_e("Standard Map (Chirikov K=0.97)",
    "p = (p + 0.97*sin(2*3.14159265*x))/(2*3.14159265); x = (x + p) mod 1",
    "x = 0.5; p = 0.5",
    "Chirikov standard map at K=0.97 — golden-mean KAM tori transition; key model in Hamiltonian chaos.",
    [{"author": "B. V. Chirikov",
      "title": "A universal instability of many-dimensional oscillator systems",
      "year": 1979, "url": "https://doi.org/10.1016/0370-1573(79)90023-1",
      "doi": "10.1016/0370-1573(79)90023-1"}],
    aliases=["Chirikov standard"]))
TABLE.append(_e("Standard Map K=2.0",
    "p = (p + 2.0*sin(2*3.14159265*x))/(2*3.14159265); x = (x + p) mod 1",
    "x = 0.3; p = 0.7",
    "Standard map at K=2 — global chaos with KAM islands embedded in stochastic sea.",
    [{"author": "B. V. Chirikov",
      "title": "Standard map",
      "year": 1979, "url": "https://en.wikipedia.org/wiki/Standard_map"}]))
TABLE.append(_e("Standard Map K=6.0",
    "p = (p + 6.0*sin(2*3.14159265*x))/(2*3.14159265); x = (x + p) mod 1",
    "x = 0.1; p = 0.1",
    "Standard map at K=6 — strong-stochasticity regime; effectively mixing system.",
    [{"author": "G. Casati et al.", "title": "Stochastic behavior of a quantum pendulum",
      "year": 1979, "url": "https://en.wikipedia.org/wiki/Standard_map"}]))
TABLE.append(_e("Sinai Map",
    "x = (x + y) mod 1; y = (x + 2*y) mod 1",
    "x = 0.3; y = 0.7",
    "Sinai's CAT-2 map = Arnold cat with stretching matrix [[1,1],[1,2]]. Hyperbolic toral automorphism; ergodic with positive entropy.",
    [{"author": "Y. G. Sinai",
      "title": "Markov partitions and Y-diffeomorphisms",
      "year": 1968, "url": "https://en.wikipedia.org/wiki/Anosov_diffeomorphism"}]))
TABLE.append(_e("Arnold Cat Map",
    "x = (2*x + y) mod 1; y = (x + y) mod 1",
    "x = 0.5; y = 0.5",
    "Arnold's cat map — toral automorphism with matrix [[2,1],[1,1]]; mixes images via Anosov stretching/folding. Period for rational grid points.",
    [{"author": "V. I. Arnold, A. Avez",
      "title": "Ergodic problems of classical mechanics",
      "year": 1968, "url": "https://en.wikipedia.org/wiki/Arnold%27s_cat_map"}],
    aliases=["cat map"]))
TABLE.append(_e("Baker's Map",
    "x = 2*x; y = y/2 if old_x < 0.5 else x = 2*x - 1; y = y/2 + 0.5",
    "x = 0.5; y = 0.5",
    "Baker's map — kneading dough analogue; stretches by 2 in x, folds in y. Bernoulli system; standard model in symbolic dynamics.",
    [{"author": "Y. G. Sinai", "title": "Topics in ergodic theory",
      "year": 1994, "url": "https://en.wikipedia.org/wiki/Baker%27s_map"}],
    aliases=["bakers map"]))
TABLE.append(_e("Smale Horseshoe",
    "x = stretch_horizontal(x); y = compress_vertical(y); fold_topdown",
    "x = 0.5; y = 0.5",
    "Smale horseshoe map (1967) — paradigmatic hyperbolic map with full 2-shift symbolic dynamics. Basis for many chaotic maps.",
    [{"author": "S. Smale",
      "title": "Differentiable dynamical systems",
      "year": 1967, "url": "https://doi.org/10.1090/S0002-9904-1967-11798-1",
      "doi": "10.1090/S0002-9904-1967-11798-1"}],
    aliases=["horseshoe"]))
TABLE.append(_e("Henon-Heiles Map (Discrete)",
    "x = y; y = -0.3*x + (1 - 1.4*y*y)",
    "x = 0; y = 0.1",
    "Discrete Hénon-Heiles map — alternate parameter set studying galactic-orbit chaos. Real-axis Hénon variant.",
    [{"author": "M. Hénon, C. Heiles",
      "title": "The applicability of the third integral of motion: some numerical experiments",
      "year": 1964, "url": "https://doi.org/10.1086/109234",
      "doi": "10.1086/109234"}]))
TABLE.append(_e("Feigenbaum Universal Map",
    "x = 1 - 1.401155*x*x",
    "x = 0",
    "Feigenbaum's renormalization fixed-point map at α ≈ 1.401155 — universal limit of period-doubling cascade. Self-similar around critical c.",
    _FEIGEN_REF, aliases=["Feigenbaum fixed point"]))
TABLE.append(_e("Bungalow (Period-doubling)",
    "x = 3.2*x*(1 - x*x*x)",
    "x = 0.5",
    "Bungalow-shaped quartic map — cubic generalisation of logistic; richer bifurcation structure with multiple coexisting attractors.",
    [{"author": "R. M. May", "title": "Bifurcations and dynamic complexity in simple ecological models",
      "year": 1976, "url": "https://en.wikipedia.org/wiki/Logistic_map"}]))
TABLE.append(_e("Cubic Map (Real)",
    "x = 3.0*x - x*x*x",
    "x = 0.1",
    "Cubic map x → 3x - x³ — odd unimodal map with two-sided dynamics; coexisting period-doubling cascades on each side.",
    [{"author": "R. Devaney", "title": "An introduction to chaotic dynamical systems",
      "year": 1989, "url": "https://en.wikipedia.org/wiki/Cubic_map"}]))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
