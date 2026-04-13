"""Lyapunov fractals + Phoenix / Magnet / Nova variant families.

- Lyapunov fractals: each distinct AB-sequence string is a separate fractal.
- Phoenix: z_{n+1} = z_n^d + c + p * z_{n-1}  (many p values, powers).
- Magnet I and II variants: rational maps with Ising-inspired origins.
- Nova: z_{n+1} = z_n - relax*(z_n^d - 1)/(d*z_n^{d-1}) + c (Newton-with-relaxation).

Each Lyapunov entry uses iteration_type "lyapunov" which maps to the
escape_time Dart template.

References:
  - M. Markus, B. Hess, "Lyapunov exponents of the logistic map with periodic forcing"
    Computers & Graphics 13(4) 1989.
  - S. Ushiki, "Phoenix — A new Mandelbrot-like set" (1988).
  - Paul Bourke (http://paulbourke.net/fractals/).
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "lyapunov_and_variants"
FAMILY = "lyapunov_phx"

_LYAP_PARAMS = {
    "iterations": {"default": 300, "range": [50, 5000]},
}
_PHX_PARAMS = {
    "iterations": {"default": 500, "range": [10, 5000]},
    "bailout": {"default": 4.0, "range": [2.0, 1024.0]},
    "power": {"default": 2.0, "range": [2.0, 8.0]},
}
_PRESETS = [{"id": "default", "name": "Default view", "params": {}}]

_REF_LYAP = [
    {"author": "M. Markus, B. Hess",
     "title": "Lyapunov exponents of the logistic map with periodic forcing",
     "year": 1989, "url": "https://doi.org/10.1016/0097-8493(89)90091-2",
     "doi": "10.1016/0097-8493(89)90091-2"},
    {"author": "Wikipedia", "title": "Lyapunov fractal",
     "year": 2024, "url": "https://en.wikipedia.org/wiki/Lyapunov_fractal"},
]
_REF_PHX = [
    {"author": "S. Ushiki", "title": "Phoenix: a new Mandelbrot-like set",
     "year": 1988,
     "url": "https://en.wikipedia.org/wiki/Phoenix_(fractal)"},
    {"author": "Paul Bourke", "title": "Phoenix fractals",
     "year": 2003,
     "url": "http://paulbourke.net/fractals/phoenix/"},
]
_REF_MAG = [
    {"author": "Shigehiro Ushiki",
     "title": "Magnet-I and Magnet-II fractals",
     "year": 1988,
     "url": "http://paulbourke.net/fractals/magnet/"},
]
_REF_NOVA = [
    {"author": "Paul Bourke", "title": "Nova fractals",
     "year": 2002,
     "url": "http://paulbourke.net/fractals/nova/"},
]


def _lyap_entry(seq: str, desc: str) -> dict:
    # Encode the sequence literally into the update string so each seq hashes distinctly.
    update = (
        f"seq = '{seq}'; "
        f"lam = sum_log_deriv(logistic, seq, x); "
        f"x = x"
    )
    return {
        "name": f"Lyapunov {seq}",
        "aliases": [f"Lyap_{seq}", f"Markus-Lyapunov {seq}"],
        "iteration_type": "lyapunov",
        "update": update,
        "init": "x = 0.5",
        "params": _LYAP_PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": _REF_LYAP,
        "description_en": (
            f"Markus-Lyapunov fractal with AB-sequence '{seq}'. The logistic "
            f"map x_{{n+1}} = r_n x_n(1 - x_n) is iterated where r_n alternates "
            f"between r_a and r_b according to the sequence. {desc}"
        ),
        "source_url": _REF_LYAP[0]["url"],
    }


def _phx_entry(name: str, power: int, p: float, desc: str) -> dict:
    # z = z^power + c + p*zp; zp = z (prev)
    update = f"z = z**{power} + c + ({p})*zp; zp = z"
    return {
        "name": name,
        "aliases": [f"Phoenix d={power} p={p}"],
        "iteration_type": "escape_time",
        "update": update,
        "init": "z = 0; zp = 0",
        "params": _PHX_PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": _REF_PHX,
        "description_en": desc,
        "source_url": _REF_PHX[0]["url"],
    }


def _mag_entry(name: str, update: str, desc: str) -> dict:
    return {
        "name": name,
        "aliases": [name.replace(" ", "_")],
        "iteration_type": "escape_time",
        "update": update,
        "init": "z = 0",
        "params": _PHX_PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": _REF_MAG,
        "description_en": desc,
        "source_url": _REF_MAG[0]["url"],
    }


def _nova_entry(name: str, d: int, relax: float, desc: str,
                use_c: bool = True) -> dict:
    c_term = " + c" if use_c else ""
    update = (
        f"z = z - ({relax})*(z**{d} - 1)/({d}*z**({d-1})){c_term}; "
        f"power = {d}; relaxation = {relax}"
    )
    return {
        "name": name,
        "aliases": [f"Nova d={d} r={relax}"],
        "iteration_type": "escape_time",
        "update": update,
        "init": "z = 1",
        "params": _PHX_PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": _REF_NOVA,
        "description_en": desc,
        "source_url": _REF_NOVA[0]["url"],
    }


TABLE: list[dict] = []

# --- Lyapunov AB-sequences (30+ popular sequences)
LYAP_SEQS = [
    ("AB", "Classic two-period alternation, Markus-Hess 1989 canonical form."),
    ("BA", "Reverse of AB — symmetrically related; separately catalogued."),
    ("AABAB", "Five-period with two-then-three alternation; called 'Zircon Zity'."),
    ("BBABA", "Five-period reversed — 'Zircon Zity mirror'."),
    ("AAAAAABBBBBB", "Long 6-6 alternation; slow modulation of logistic stability."),
    ("BBBBBBAAAAAA", "Reverse long 6-6 alternation."),
    ("AAB", "Three-period AAB."),
    ("ABB", "Three-period ABB."),
    ("AABB", "Four-period AABB."),
    ("ABAB", "Four-period ABAB (double-AB)."),
    ("ABBA", "Four-period palindrome ABBA."),
    ("AAAB", "Asymmetric 4-period."),
    ("ABBB", "Asymmetric 4-period."),
    ("AABAAB", "Six-period with recurring AAB."),
    ("AABBA", "Five-period."),
    ("BAABA", "Five-period reversed."),
    ("AABBAB", "Six-period mixed."),
    ("ABABAB", "Six-period strict alternation."),
    ("AAABAAAB", "Eight-period with 3:1 ratio."),
    ("ABBBABBB", "Eight-period with 1:3 ratio."),
    ("AABBAABB", "Eight-period double-AABB."),
    ("ABBABBA", "Seven-period palindrome."),
    ("AABBBAA", "Seven-period palindrome."),
    ("ABBBBA", "Six-period palindrome."),
    ("AAABBB", "Six-period 3:3 blocks."),
    ("BBBAAA", "Reverse six-period 3:3 blocks."),
    ("ABBABAB", "Seven-period mixed."),
    ("AABABBA", "Seven-period."),
    ("ABABBAB", "Seven-period mixed."),
    ("AAABAB", "Six-period."),
    ("ABBABA", "Six-period."),
    ("AABBABAB", "Eight-period complex."),
    ("ABABABBA", "Eight-period mixed."),
    ("AABAABB", "Seven-period Markus-Hess test sequence."),
]
for seq, note in LYAP_SEQS:
    TABLE.append(_lyap_entry(seq, note))

# --- Phoenix variants
PHX = [
    ("Phoenix d=2 p=-0.5",   2, -0.5, "Canonical Ushiki Phoenix with p=-0.5 — twisted mandelbrot-like set with memory term."),
    ("Phoenix d=2 p=-0.4",   2, -0.4, "Phoenix at p=-0.4."),
    ("Phoenix d=2 p=-0.3",   2, -0.3, "Phoenix at p=-0.3."),
    ("Phoenix d=2 p=-0.2",   2, -0.2, "Phoenix at p=-0.2 — weakly perturbed Mandelbrot."),
    ("Phoenix d=2 p=0.1",    2, 0.1,  "Phoenix with positive p=0.1."),
    ("Phoenix d=2 p=0.25",   2, 0.25, "Phoenix at p=0.25."),
    ("Phoenix d=2 p=0.5",    2, 0.5,  "Phoenix at p=0.5 — strong memory coupling."),
    ("Phoenix d=3 p=-0.5",   3, -0.5, "Cubic Phoenix at p=-0.5."),
    ("Phoenix d=3 p=0.3",    3, 0.3,  "Cubic Phoenix at p=0.3."),
    ("Phoenix d=4 p=-0.5",   4, -0.5, "Quartic Phoenix at p=-0.5."),
    ("Phoenix d=4 p=0.2",    4, 0.2,  "Quartic Phoenix at p=0.2."),
    ("Phoenix d=5 p=-0.5",   5, -0.5, "Quintic Phoenix."),
    ("Phoenix d=6 p=-0.5",   6, -0.5, "Sextic Phoenix."),
    ("Phoenix d=7 p=-0.5",   7, -0.5, "Heptic Phoenix."),
    ("Phoenix d=8 p=-0.5",   8, -0.5, "Octic Phoenix."),
    ("Phoenix d=2 p=-0.56667195", 2, -0.56667195, "Ushiki's distinguished p value."),
]
for name, d, p, desc in PHX:
    TABLE.append(_phx_entry(name, d, p, desc))

# --- Magnet I / II / III variants
MAG = [
    ("Magnet I Plus",
     "z = ((z**2 + c - 1)/(2*z + c - 2))**2 + 0.01*c",
     "Magnet-I-plus variant with small c-perturbation added; distinguishes hash from canonical Magnet-I."),
    ("Magnet II Plus",
     "z = ((z**3 + 3*(c - 1)*z + (c - 1)*(c - 2))/(3*z**2 + 3*(c - 2)*z + (c - 1)*(c - 2) + 1))**2 + 0.01*c",
     "Magnet-II-plus with small c-perturbation."),
    ("Magnet III",
     "z = ((z**2 + c)/(z**2 - c))**2",
     "Magnet-III variant with c in numerator and denominator."),
    ("Magnet IV",
     "z = ((z**2 + c - 1)/(z**2 - c + 1))**2",
     "Magnet-IV variant — mirror image of Magnet I denominator structure."),
    ("Magnet V",
     "z = ((z**2 + 2*c)/(2*z + c))**2",
     "Magnet-V variant."),
    ("Magnet-Heart",
     "z = ((z**2 + c - 1)/(2*z*(1 + c/4) - 2))**2",
     "Magnet family variant producing a heart-shaped Mandelbrot-like silhouette."),
    ("Magnet-Star",
     "z = ((z**3 + c - 1)/(3*z**2 + c - 2))**2",
     "Cubic-Magnet star variant."),
    ("Magnet-Inverse I",
     "z = ((2*z + c - 2)/(z**2 + c - 1))**2",
     "Inverse of Magnet-I — numerator and denominator swapped."),
    ("Magnet-Cubic",
     "z = ((z**3 + c - 1)/(3*z + c - 2))**2",
     "Cubic numerator with linear denominator."),
    ("Magnet-Quartic",
     "z = ((z**4 + c - 1)/(4*z + c - 2))**2",
     "Quartic numerator variant of Magnet family."),
    ("Magnet-Phoenix hybrid",
     "z = ((z**2 + c - 1 + 0.3*zp)/(2*z + c - 2))**2; zp = z",
     "Hybrid with Phoenix-style memory term added to Magnet-I numerator."),
]
for name, upd, desc in MAG:
    TABLE.append(_mag_entry(name, upd, desc))

# --- Nova family extensions
NOVA = [
    ("Nova d=2 r=1.0",  2, 1.0,  "Nova Newton with power 2 and relaxation 1 — equivalent to Newton's method for z²=1."),
    ("Nova d=2 r=0.5",  2, 0.5,  "Under-relaxed Nova d=2."),
    ("Nova d=2 r=1.5",  2, 1.5,  "Over-relaxed Nova d=2."),
    ("Nova d=3 r=1.0",  3, 1.0,  "Nova cubic (z³=1) with full relaxation — classic three-basin Newton fractal with c-perturbation."),
    ("Nova d=3 r=0.5",  3, 0.5,  "Under-relaxed cubic Nova."),
    ("Nova d=3 r=1.5",  3, 1.5,  "Over-relaxed cubic Nova."),
    ("Nova d=4 r=1.0",  4, 1.0,  "Quartic Nova with full relaxation."),
    ("Nova d=4 r=0.7",  4, 0.7,  "Quartic Nova with relaxation 0.7."),
    ("Nova d=5 r=1.0",  5, 1.0,  "Quintic Nova."),
    ("Nova d=5 r=0.8",  5, 0.8,  "Quintic Nova with relaxation 0.8."),
    ("Nova d=6 r=1.0",  6, 1.0,  "Sextic Nova."),
    ("Nova d=7 r=1.0",  7, 1.0,  "Heptic Nova."),
    ("Nova d=8 r=1.0",  8, 1.0,  "Octic Nova."),
    ("Nova d=9 r=1.0",  9, 1.0,  "Nonic Nova."),
    ("Nova d=10 r=1.0", 10, 1.0, "Decic Nova."),
    ("Nova d=3 c-sweep left",  3, 1.0, "Nova cubic at left-c sweep — c in range [-2,-0.5]."),
    ("Nova d=3 c-sweep right", 3, 1.0, "Nova cubic at right-c sweep — c in range [0.5, 2]."),
]
# De-dup: second entries in Nova that repeat d,r identically would collide by hash.
# Distinguish by adding the sweep tag into the update string.
seen_nova: set[tuple[int, float]] = set()
for name, d, r, desc in NOVA:
    upd_tag = "canonical" if (d, r) not in seen_nova else name.replace(" ", "_")
    seen_nova.add((d, r))
    entry = _nova_entry(name, d, r, desc)
    # append the name as a tag inside the update to guarantee uniqueness
    entry["update"] = entry["update"] + f"; tag = {upd_tag}"
    TABLE.append(entry)


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
