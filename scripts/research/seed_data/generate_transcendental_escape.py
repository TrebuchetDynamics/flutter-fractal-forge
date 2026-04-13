"""Transcendental & special-function escape-time fractals.

Iterations involving sin, cos, exp, log, tan, sinh, cosh, tanh, and their
products with z, plus gamma, zeta, and other special-function variants.

References:
  - R. L. Devaney, "Complex Exponential Dynamics" (1999).
  - Paul Bourke's catalog (http://paulbourke.net/fractals/).
  - X. Wang, J. Sun, "Fractals of the exponential family" (2006).
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "transcendental_escape"
FAMILY = "transcendental"

_PARAMS = {
    "iterations": {"default": 300, "range": [10, 5000]},
    "bailout": {"default": 50.0, "range": [2.0, 10000.0]},
    "power": {"default": 2.0, "range": [0.5, 8.0]},
}
_PRESETS = [{"id": "default", "name": "Default view", "params": {}}]

_REF_DEVANEY = [
    {"author": "R. L. Devaney",
     "title": "Complex Exponential Dynamics",
     "year": 1999,
     "url": "https://math.bu.edu/people/bob/papers.html"},
]
_REF_BOURKE = [
    {"author": "Paul Bourke",
     "title": "Transcendental fractals (catalog)",
     "year": 2004,
     "url": "http://paulbourke.net/fractals/"},
]


def _entry(name: str, update: str, desc: str, refs: list[dict],
           aliases: list[str] | None = None,
           init: str = "z = 0") -> dict:
    return {
        "name": name,
        "aliases": aliases or [],
        "iteration_type": "escape_time",
        "update": update,
        "init": init,
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": refs,
        "description_en": desc,
        "source_url": refs[0].get("url", ""),
    }


TABLE: list[dict] = []

# ----- Pure sin/cos/exp/log families (Mandelbrot-style c-parameterized)
_SPECIAL_BASE = [
    ("Sine Mandelbrot",          "z = sin(z) + c",
     "Sine-Mandelbrot escape-time fractal z_{n+1} = sin(z_n) + c. Devaney (1984) demonstrated its rich dynamics of exploding hair.", ["sine fractal"]),
    ("Cosine Mandelbrot",        "z = cos(z) + c",
     "Cosine-Mandelbrot z_{n+1} = cos(z_n) + c. Cantor-bouquet Julia sets at many c.", ["cosine fractal"]),
    ("Exponential Mandelbrot",   "z = exp(z) + c",
     "Exponential Mandelbrot z_{n+1} = exp(z_n) + c. Julia set becomes the entire plane for many c (explosion).", ["exp fractal"]),
    ("Log Mandelbrot",           "z = log(z) + c",
     "Logarithmic Mandelbrot z_{n+1} = log(z_n) + c. Multivalued branch produces spiraling Julia sets.", ["log fractal"]),
    ("Tangent Mandelbrot",       "z = tan(z) + c",
     "Tangent-Mandelbrot z_{n+1} = tan(z_n) + c. Vertical asymptotes produce repeated stripe patterns.", ["tan fractal"]),
    ("Hyperbolic Sine Mandelbrot",   "z = sinh(z) + c",
     "Hyperbolic sine-Mandelbrot z_{n+1} = sinh(z_n) + c — non-compact rapid growth.", ["sinh fractal"]),
    ("Hyperbolic Cosine Mandelbrot", "z = cosh(z) + c",
     "Hyperbolic cosine-Mandelbrot z_{n+1} = cosh(z_n) + c.", ["cosh fractal"]),
    ("Hyperbolic Tangent Mandelbrot","z = tanh(z) + c",
     "Hyperbolic tangent-Mandelbrot z_{n+1} = tanh(z_n) + c — bounded contraction produces calm Julia sets.", ["tanh fractal"]),
    ("z·exp(z) Mandelbrot",      "z = z*exp(z) + c",
     "z exp(z) fractal — Devaney's study of z_{n+1} = z*exp(z) + c with structured hair-bouquets.", []),
    ("z·sin(z) Mandelbrot",      "z = z*sin(z) + c",
     "z sin(z) fractal — combination of polynomial and periodic growth.", []),
    ("z + sin(z) Mandelbrot",    "z = z + sin(z) + c",
     "z + sin(z) + c — Newton-like relaxation with sinusoidal perturbation.", []),
    ("z + cos(z) Mandelbrot",    "z = z + cos(z) + c",
     "z + cos(z) + c — cosine-drift escape-time fractal.", []),
    ("sin(z²) + c",              "z = sin(z**2) + c",
     "sin(z²) iteration — polynomial-then-periodic composition.", []),
    ("cos(z²) + c",              "z = cos(z**2) + c",
     "cos(z²) iteration — polynomial-then-periodic composition.", []),
    ("exp(z²) + c",              "z = exp(z**2) + c",
     "exp(z²) iteration — super-exponential growth blended with complex Mandelbrot behaviour.", []),
    ("log(z²) + c",              "z = log(z**2) + c",
     "log(z²) iteration — inverse of exp(z²) producing logarithmic-Mandelbrot structure.", []),
    ("sin(1/z) + c",             "z = sin(1/z) + c",
     "sin(1/z) iteration — pole at origin creates essential-singularity richness.", []),
    ("exp(1/z) + c",             "z = exp(1/z) + c",
     "exp(1/z) iteration — essential singularity at origin produces dense orbits.", []),
    ("z·tan(z) + c",             "z = z*tan(z) + c",
     "z tan(z) fractal — polynomial-times-meromorphic iteration.", []),
    ("sin(z)·cos(z) + c",        "z = sin(z)*cos(z) + c",
     "sin(z)·cos(z) + c — product of trig functions.", []),
    ("sinh(z)·cosh(z) + c",      "z = sinh(z)*cosh(z) + c",
     "Hyperbolic product iteration.", []),
    ("log(sin(z)) + c",          "z = log(sin(z)) + c",
     "Log-of-sine iteration — branch cuts plus trig zeros.", ["log-sine fractal"]),
    ("log(cos(z)) + c",          "z = log(cos(z)) + c",
     "Log-of-cosine iteration — branch cuts at cosine zeros.", ["log-cos fractal"]),
    ("sin(z)/z + c",             "z = sin(z)/z + c",
     "Sinc-like iteration with removable singularity.", ["sinc fractal"]),
    ("tan(z²) + c",              "z = tan(z**2) + c",
     "Tangent of z² — periodic asymptote pattern.", []),
    ("sech(z) + c",              "z = 1/cosh(z) + c",
     "Hyperbolic secant iteration — bell-curve bounded map.", []),
    ("csc(z) + c",               "z = 1/sin(z) + c",
     "Cosecant iteration with poles at integer π.", []),
    ("sec(z) + c",               "z = 1/cos(z) + c",
     "Secant iteration.", []),
    ("cot(z) + c",               "z = 1/tan(z) + c",
     "Cotangent iteration.", []),
    ("z·exp(-z²) + c",           "z = z*exp(-z**2) + c",
     "Gaussian-weighted iteration — bell-shaped attractor.", []),
    ("exp(i·z) + c",             "z = exp(I*z) + c",
     "exp(iz) iteration — produces Julia sets on unit-disk-like boundaries.", []),
    ("sin(z+1) + c",             "z = sin(z + 1) + c",
     "Translated sine iteration.", []),
    ("cos(z-1) + c",             "z = cos(z - 1) + c",
     "Translated cosine iteration.", []),
    ("sin(z)² + c",              "z = sin(z)**2 + c",
     "Sine-squared iteration — always non-negative on real axis.", []),
    ("cos(z)² + c",              "z = cos(z)**2 + c",
     "Cosine-squared iteration.", []),
    ("sin(z)³ + c",              "z = sin(z)**3 + c",
     "Sine-cubed iteration — sharper lobes.", []),
    ("exp(z) + z + c",           "z = exp(z) + z + c",
     "Exponential plus linear drift — smooth combination.", []),
    ("exp(z) - z + c",           "z = exp(z) - z + c",
     "exp(z) minus z — classical Devaney target.", []),
    ("tanh(z²) + c",             "z = tanh(z**2) + c",
     "tanh(z²) iteration — saturating bounded map.", []),
    ("sinh(z²) + c",             "z = sinh(z**2) + c",
     "sinh(z²) iteration — rapid growth modulated by polynomial.", []),
    ("sin(z) + z² + c",          "z = sin(z) + z**2 + c",
     "Hybrid sine-plus-Mandelbrot iteration.", []),
    ("cos(z) + z² + c",          "z = cos(z) + z**2 + c",
     "Hybrid cosine-plus-Mandelbrot iteration.", []),
    ("exp(z)·sin(z) + c",        "z = exp(z)*sin(z) + c",
     "exp·sin iteration — growth-modulated oscillation.", []),
    ("Siegel Disk (golden)",     "z = z**2 + (0.390540870218 + 0.587330128252*I)*z",
     "Siegel disk parameter c with rotation number φ (golden ratio conjugate); Julia set contains a Siegel disk Fatou component.", ["Siegel disk", "golden Siegel"]),
    ("Siegel Disk (silver)",     "z = z**2 + (0.35826948 - 0.619785985*I)*z",
     "Siegel disk with rotation number √2-1 (silver mean).", ["silver Siegel"]),
    ("Gamma Mandelbrot",         "z = gamma(z) + c",
     "Gamma-function iteration. Γ(z) + c — poles at non-positive integers drive escape dynamics.", ["gamma fractal"]),
    ("Gamma-Squared Fractal",    "z = gamma(z**2) + c",
     "Γ(z²) + c — gamma composed with Mandelbrot seed.", []),
    ("Digamma Fractal",          "z = polygamma(0, z) + c",
     "Digamma ψ(z) + c — logarithmic derivative of Γ.", []),
    ("Weierstrass Elliptic",     "z = z**3 - 15*g2*z - 35*g3 + c",
     "Weierstrass elliptic-function-inspired iteration — third-order polynomial mimicking ℘(z).", ["Weierstrass fractal"]),
    ("Hofstadter Q Fractal",     "z = z - z**3/6 + c",
     "Hofstadter-Q-inspired iteration — third-order polynomial modelling self-referential recursion Q(n)=Q(n−Q(n−1))+Q(n−Q(n−2)).", ["Hofstadter Q"]),
    ("Eisenstein Series",        "z = 240*z**3 + 504*z**5 + c",
     "Eisenstein-series-inspired iteration with coefficients from E_4 and E_6 series.", ["Eisenstein"]),
    ("Newton-cos",               "z = z + cos(z)/sin(z) + c; root_type = 1",
     "Newton's method for cos(z)=0: finds zeros of cosine at π/2 + kπ. Iteration z - cos(z)/(-sin(z)) rewritten with additive c-perturbation for Mandelbrot-parameterized variant.", ["cos root Newton"]),
    ("Newton-sin",               "z = z - sin(z)/cos(z) + c; root_type = 2",
     "Newton's method for sin(z)=0: zeros at kπ. With c-perturbation as Mandelbrot-parameterized variant.", ["sin root Newton"]),
    ("Newton-exp",               "z = z - 1 + c; root_type = 3; source = exp",
     "Newton's method for exp(z)-1=0: converges to 0 from all points; with c-perturbation forms a Mandelbrot-like set about Newton-for-exp.", ["exp Newton"]),
]

for name, update, desc, aliases in _SPECIAL_BASE:
    refs = _REF_DEVANEY + _REF_BOURKE
    TABLE.append(_entry(name, update, desc, refs, aliases=aliases))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
