"""Reaction-diffusion patterns (Family 2).

Sources:
  - A. M. Turing, "The chemical basis of morphogenesis" (1952).
  - P. Gray, S. K. Scott, "Chemical oscillations and instabilities" (1990).
  - J. E. Pearson, "Complex patterns in a simple system" Science (1993).
  - I. Prigogine, R. Lefever, "Symmetry breaking instabilities in dissipative systems" (1968).
  - FitzHugh-Nagumo, Oregonator, Lengyel-Epstein literature.
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "reaction_diffusion"
FAMILY = "rd"

_PARAMS = {
    "grid_size": {"default": 512, "range": [64, 4096]},
    "steps": {"default": 4000, "range": [100, 50000]},
    "dt": {"default": 1.0, "range": [0.1, 5.0]},
}
_PRESETS = [{"id": "default", "name": "Default regime", "params": {}}]


def _e(name: str, update: str, init: str, desc: str, refs: list[dict],
       aliases: list[str] | None = None) -> dict:
    return {
        "name": name,
        "aliases": aliases or [],
        "iteration_type": "reaction_diffusion",
        "update": update,
        "init": init,
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": refs,
        "description_en": desc,
        "source_url": refs[0].get("url", ""),
    }


_GS_REF = [
    {"author": "J. E. Pearson", "title": "Complex patterns in a simple system",
     "year": 1993, "url": "https://doi.org/10.1126/science.261.5118.189",
     "doi": "10.1126/science.261.5118.189"},
    {"author": "P. Gray, S. K. Scott",
     "title": "Chemical oscillations and instabilities: non-linear chemical kinetics",
     "year": 1990, "url": "https://doi.org/10.1093/oso/9780198556466.001.0001"},
]
_TURING_REF = [
    {"author": "A. M. Turing", "title": "The chemical basis of morphogenesis",
     "year": 1952, "url": "https://doi.org/10.1098/rstb.1952.0012",
     "doi": "10.1098/rstb.1952.0012"},
]
_BZ_REF = [
    {"author": "A. N. Zaikin, A. M. Zhabotinsky",
     "title": "Concentration wave propagation in two-dimensional liquid-phase self-oscillating systems",
     "year": 1970, "url": "https://doi.org/10.1038/225535b0",
     "doi": "10.1038/225535b0"},
]
_FHN_REF = [
    {"author": "R. FitzHugh", "title": "Impulses and physiological states in theoretical models of nerve membrane",
     "year": 1961, "url": "https://doi.org/10.1016/S0006-3495(61)86902-6",
     "doi": "10.1016/S0006-3495(61)86902-6"},
]
_OREGONATOR_REF = [
    {"author": "R. J. Field, R. M. Noyes",
     "title": "Oscillations in chemical systems IV: Limit cycle behavior in a model of a real chemical reaction",
     "year": 1974, "url": "https://doi.org/10.1063/1.1681288",
     "doi": "10.1063/1.1681288"},
]
_BRUS_REF = [
    {"author": "I. Prigogine, R. Lefever",
     "title": "Symmetry breaking instabilities in dissipative systems II",
     "year": 1968, "url": "https://doi.org/10.1063/1.1668896",
     "doi": "10.1063/1.1668896"},
]
_LE_REF = [
    {"author": "I. Lengyel, I. R. Epstein",
     "title": "A chemical approach to designing Turing patterns in reaction-diffusion systems",
     "year": 1992, "url": "https://doi.org/10.1073/pnas.89.9.3977",
     "doi": "10.1073/pnas.89.9.3977"},
]
_SCHNAK_REF = [
    {"author": "J. Schnakenberg",
     "title": "Simple chemical reaction systems with limit cycle behaviour",
     "year": 1979, "url": "https://doi.org/10.1016/0022-5193(79)90042-0",
     "doi": "10.1016/0022-5193(79)90042-0"},
]
_MG_REF = [
    {"author": "A. Gierer, H. Meinhardt",
     "title": "A theory of biological pattern formation",
     "year": 1972, "url": "https://doi.org/10.1007/BF00289234",
     "doi": "10.1007/BF00289234"},
]


def _gs(name: str, F: float, k: float, regime: str) -> dict:
    update = (
        f"du/dt = Du*lap(u) - u*v*v + {F}*(1 - u); "
        f"dv/dt = Dv*lap(v) + u*v*v - ({F} + {k})*v"
    )
    init = "u = 1 + noise; v = 0 + seed_square"
    desc = (
        f"Gray-Scott reaction-diffusion with F={F}, k={k}. "
        f"Regime: {regime}. "
        "Two coupled PDEs modelling autocatalytic chemistry u + 2v -> 3v; v -> P. "
        "Pearson (1993) mapped the (F,k) plane into a zoo of pattern regimes."
    )
    return _e(name, update, init, desc, _GS_REF,
              aliases=[f"Gray-Scott F={F} k={k}"])


TABLE: list[dict] = []

# Gray-Scott regimes from Pearson 1993 + U-Skate extensions
GS = [
    ("Gray-Scott Spots",      0.030, 0.062, "Stationary spot regime"),
    ("Gray-Scott Worms",      0.042, 0.059, "Worm-like filament regime"),
    ("Gray-Scott Mazes",      0.029, 0.057, "Maze-like stripes"),
    ("Gray-Scott U-Skate",    0.062, 0.061, "U-Skate World gliders (mobile solitons)"),
    ("Gray-Scott Coral",      0.054, 0.063, "Branching coral growth"),
    ("Gray-Scott Solitons",   0.014, 0.054, "Isolated travelling solitons"),
    ("Gray-Scott Stripes",    0.022, 0.051, "Labyrinthine stripes"),
    ("Gray-Scott Bubbles",    0.098, 0.057, "Foam-like bubble regime"),
    ("Gray-Scott Moving Spots", 0.014, 0.045, "Mobile spot regime"),
    ("Gray-Scott Self-Replicating Spots", 0.025, 0.060, "Mitosis-like self-replication"),
    ("Gray-Scott Chaos",      0.026, 0.051, "Spatiotemporal chaos"),
    ("Gray-Scott Pulsating Spots", 0.030, 0.055, "Breathing pulsating spots"),
    ("Gray-Scott Holes",      0.039, 0.058, "Hole-in-filled-state regime"),
    ("Gray-Scott Finger Prints", 0.040, 0.060, "Fingerprint-style labyrinth"),
    ("Gray-Scott Giraffe",    0.034, 0.063, "Giraffe-skin spotting"),
]
for name, F, k, regime in GS:
    TABLE.append(_gs(name, F, k, regime))

# Turing pattern parametric variants
TABLE.append(_e("Turing Spots (Isotropic)",
    "da/dt = D_a*lap(a) + a - a**3 - b; db/dt = D_b*lap(b) + 0.5*(a - b)",
    "a = small random noise; b = 0",
    "Isotropic Turing pattern — diffusion-driven instability on a homogeneous steady state produces stationary spots from noise. Canonical two-species linear-stability example.",
    _TURING_REF, aliases=["Turing pattern"]))
TABLE.append(_e("Turing Stripes (Anisotropic)",
    "da/dt = D_a*lap(a) + a*(1 - a*a) - b; db/dt = 0.25*D_a*lap(b) + 0.1*(a - b)",
    "a = random + bias_x; b = 0",
    "Anisotropic diffusion Turing regime producing parallel stripes instead of spots. D_a > D_b required for instability.",
    _TURING_REF, aliases=["Turing stripes"]))
TABLE.append(_e("Turing Labyrinth",
    "da/dt = 1.0*lap(a) + a - a**3 - b; db/dt = 10.0*lap(b) + a - b",
    "a = noise; b = 0",
    "Turing labyrinthine regime — larger inhibitor diffusion yields maze-like patterns with branching and merging.",
    _TURING_REF, aliases=["labyrinth"]))

# Belousov-Zhabotinsky variants
TABLE.append(_e("Belousov-Zhabotinsky (Continuous)",
    "du/dt = Du*lap(u) + u*(1 - u - (f*(u - q))/(u + q)*v); dv/dt = Dv*lap(v) + u - v",
    "u = 0.5 + noise; v = 0.5",
    "BZ reaction continuous PDE approximation (Tyson-Fife two-variable model). Produces target waves and rotating spirals.",
    _BZ_REF, aliases=["BZ reaction"]))
TABLE.append(_e("Belousov-Zhabotinsky Spirals",
    "du/dt = 0.8*lap(u) + u*(1 - u) - f*v*(u - q)/(u + q); dv/dt = 0.05*lap(v) + u - v",
    "u = target_pattern; v = slow_wave",
    "BZ rotating-spiral regime — dominant spiral-wave mode seen in shallow BZ dishes (Winfree 1972).",
    _BZ_REF, aliases=["BZ spirals"]))
TABLE.append(_e("Belousov-Zhabotinsky Target Waves",
    "du/dt = 1.0*lap(u) + u - u**3 - f*v*(u - q)/(u + q); dv/dt = 0.1*lap(v) + u - v",
    "u = point_perturbation; v = 0",
    "BZ target-wave regime — concentric circular pulses emanating from pacemaker sites.",
    _BZ_REF, aliases=["BZ target"]))

TABLE.append(_e("FitzHugh-Nagumo (Excitable Medium)",
    "dv/dt = Dv*lap(v) + v*(v - a)*(1 - v) - w; dw/dt = eps*(v - gamma*w)",
    "v = noise; w = 0",
    "FitzHugh-Nagumo model — 2-variable reduction of Hodgkin-Huxley neuron equations; produces excitable waves and spiral breakup. Standard excitable-medium model.",
    _FHN_REF, aliases=["FHN"]))
TABLE.append(_e("FitzHugh-Nagumo Spirals",
    "dv/dt = 0.5*lap(v) + v*(v - 0.1)*(1 - v) - w; dw/dt = 0.01*(v - 1.5*w)",
    "v = half_plane; w = 0",
    "FHN in spiral-wave regime — broken wavefront curls into a rotating spiral.",
    _FHN_REF))
TABLE.append(_e("FitzHugh-Nagumo Turbulence",
    "dv/dt = 1.0*lap(v) + v*(v - 0.1)*(1 - v) - w + I_noise; dw/dt = 0.015*(v - 1.0*w)",
    "v = random; w = 0",
    "FHN turbulent regime — spiral breakup produces spatiotemporal chaos resembling cardiac fibrillation.",
    _FHN_REF))

TABLE.append(_e("Oregonator (3-variable)",
    "du/dt = Du*lap(u) + (q*w - u*w + u*(1 - u))/eps; dv/dt = Dv*lap(v) + u - v; dw/dt = Dw*lap(w) + (-q*w - u*w + f*v)/eps2",
    "u = 0.1; v = 0.1; w = 0.1",
    "Oregonator model (Field-Noyes 1974) — 3-variable mechanistic model of BZ reaction with bromate, bromide, and activator species.",
    _OREGONATOR_REF, aliases=["Oregonator"]))

TABLE.append(_e("Brusselator",
    "du/dt = Du*lap(u) + A - (B + 1)*u + u*u*v; dv/dt = Dv*lap(v) + B*u - u*u*v",
    "u = A + noise; v = B/A + noise",
    "Brusselator (Prigogine-Lefever 1968) — autocatalytic model producing Turing patterns and temporal oscillations near A=1, B=3.",
    _BRUS_REF, aliases=["Brusselator"]))
TABLE.append(_e("Brusselator Hopf",
    "du/dt = 1.0*lap(u) + 1 - 4*u + u*u*v; dv/dt = 5.0*lap(v) + 3*u - u*u*v",
    "u = 1.0 + noise; v = 3.0",
    "Brusselator in Hopf regime — temporal limit-cycle oscillations with spatially uniform bulk oscillation.",
    _BRUS_REF))

TABLE.append(_e("Lengyel-Epstein CIMA",
    "du/dt = lap(u) + a - u - 4*u*v/(1 + u*u); dv/dt = sigma*(c*lap(v) + b*(u - u*v/(1 + u*u)))",
    "u = a/5; v = 1 + a*a/25",
    "Lengyel-Epstein model of the CIMA (chlorite-iodide-malonic-acid) reaction — first experimentally validated Turing pattern system (De Kepper et al. 1990).",
    _LE_REF, aliases=["CIMA"]))

TABLE.append(_e("Schnakenberg Model",
    "du/dt = Du*lap(u) + a - u + u*u*v; dv/dt = Dv*lap(v) + b - u*u*v",
    "u = a + b; v = b/(a+b)**2",
    "Schnakenberg reaction-diffusion (1979) — simplified 3-variable autocatalytic scheme producing Turing spots and stripes. Standard morphogenesis toy model.",
    _SCHNAK_REF, aliases=["Schnakenberg"]))

TABLE.append(_e("Meinhardt-Gierer Activator-Inhibitor",
    "da/dt = Da*lap(a) + rho_a*a*a/h - mu_a*a; dh/dt = Dh*lap(h) + rho_h*a*a - mu_h*h",
    "a = noise; h = 0.1",
    "Gierer-Meinhardt activator-inhibitor model (1972) — short-range activation + long-range inhibition producing peaks, stripes, and seashell patterns.",
    _MG_REF, aliases=["Meinhardt-Gierer"]))
TABLE.append(_e("Meinhardt Seashell",
    "da/dt = 0.01*lap(a) + 0.01*a*a/h - 0.1*a + noise; dh/dt = 0.2*lap(h) + 0.01*a*a - 0.1*h",
    "a = noise_line; h = 0.1",
    "Meinhardt seashell-pattern variant — 1D spatial substrate + time axis reproduces seashell pigmentation stripes, chevrons, zigzags.",
    _MG_REF))
TABLE.append(_e("Meinhardt Stripes",
    "da/dt = 0.02*lap(a) + rho*a*a/h - 0.04*a; dh/dt = 0.2*lap(h) + rho_h*a*a - 0.08*h; rho = 0.01 + noise",
    "a = random; h = 1",
    "Meinhardt stripe-pattern regime — fluctuating source density induces parallel stripes instead of spots."
    ,
    _MG_REF))

TABLE.append(_e("Barkley Model",
    "du/dt = lap(u) + (1/eps)*u*(1 - u)*(u - (v + b)/a); dv/dt = u - v",
    "u = noise; v = 0",
    "Barkley model (1991) — simplified excitable-medium PDE with fast-slow dynamics; produces spirals, scroll waves, and cardiac-like reentry.",
    [{"author": "D. Barkley", "title": "A model for fast computer simulation of waves in excitable media",
      "year": 1991, "url": "https://doi.org/10.1016/0167-2789(91)90194-E",
      "doi": "10.1016/0167-2789(91)90194-E"}]))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
