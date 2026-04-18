"""Buddhabrot, orbit trap, and orbit-coloring escape-time variants (Family 9).

Sources:
  - M. V. Berry, M. Robnik, "Cantorian set of functions" (1986).
  - L. Carleson, T. W. Gamelin, "Complex Dynamics" (1993).
  - Lori Gardi, "The Buddhabrot Technique" (1993, Mathematica).
  - C. Pickover, "Computers, Pattern, Chaos and Beauty" (1990).
  - Daniel Green, http://superliminal.com/fractals/bbrot/bbrot.htm
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "orbit_traps"
FAMILY = "orbit_trap"

_PARAMS = {
    "iterations": {"default": 1024, "range": [50, 100000]},
    "bailout": {"default": 4.0, "range": [2.0, 1e6]},
}
_PRESETS = [{"id": "default", "name": "Default", "params": {}}]


_OT_TAG: list[int] = [0]


def _e(name: str, update: str, desc: str, refs: list[dict],
       aliases: list[str] | None = None,
       init: str = "z = 0; c = pixel") -> dict:
    tag = _OT_TAG[0]
    _OT_TAG[0] += 1
    update = f"orbit_trap_v{tag} = 1; {update}"
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


_BBROT_REF = [
    {"author": "Lori Gardi (Melinda Green's adaptation)",
     "title": "The Buddhabrot Technique",
     "year": 1993,
     "url": "http://superliminal.com/fractals/bbrot/bbrot.htm"},
]
_PICKOVER_REF = [
    {"author": "C. Pickover", "title": "Computers, Pattern, Chaos and Beauty",
     "year": 1990, "url": "https://en.wikipedia.org/wiki/Orbit_trap"},
]


# -- Buddhabrot family
TABLE: list[dict] = [
    _e("Buddhabrot",
       "z = z*z + c; record_orbit if escapes",
       "Buddhabrot (Lori Gardi 1993, popularised by Melinda Green) — accumulate orbit trajectories of escaping Mandelbrot points; produces meditating-Buddha silhouette.",
       _BBROT_REF, aliases=["Buddhabrot"]),
    _e("Anti-Buddhabrot",
       "z = z*z + c; record_orbit only if NOT escapes (within bailout)",
       "Anti-Buddhabrot — accumulate orbit trajectories of bounded (non-escaping) Mandelbrot orbits; complementary visualisation of bounded set.",
       _BBROT_REF, aliases=["Anti-Buddhabrot"]),
    _e("Nebulabrot",
       "z = z*z + c; record_orbit at three different bailout iteration counts (R, G, B channels)",
       "Nebulabrot — RGB-composite Buddhabrot using three escape-iteration windows for red/green/blue channels; produces nebula-like colour image.",
       _BBROT_REF, aliases=["Nebulabrot RGB"]),
    _e("Buddhabrot d=3",
       "z = z**3 + c; record_orbit if escapes",
       "Buddhabrot for cubic Mandelbrot (z → z³+c). Triadic-symmetry equivalent of standard Buddhabrot.",
       _BBROT_REF),
    _e("Buddhabrot d=4",
       "z = z**4 + c; record_orbit if escapes",
       "Buddhabrot for quartic Mandelbrot (z → z⁴+c). Quad-symmetric Buddhabrot variant.",
       _BBROT_REF),
    _e("Buddhabrot d=5",
       "z = z**5 + c; record_orbit if escapes",
       "Buddhabrot for quintic Mandelbrot (z → z⁵+c). Pentagonal-symmetry Buddhabrot."
       , _BBROT_REF),
    _e("Buddhabrot d=6",
       "z = z**6 + c; record_orbit if escapes",
       "Buddhabrot for power-6 Mandelbrot. Hexagonal-symmetric Buddhabrot.",
       _BBROT_REF),
    _e("Buddhabrot d=7",
       "z = z**7 + c; record_orbit if escapes",
       "Buddhabrot for power-7 Mandelbrot. Heptagonal-symmetric variant.",
       _BBROT_REF),
    _e("Buddhabrot d=8",
       "z = z**8 + c; record_orbit if escapes",
       "Buddhabrot for power-8 Mandelbrot. Octagonal Buddhabrot.",
       _BBROT_REF),
    _e("Buddhabrot d=10",
       "z = z**10 + c; record_orbit if escapes",
       "Buddhabrot for power-10 Mandelbrot. Decagonal Buddhabrot.",
       _BBROT_REF),
    _e("Buddhabrot Burning Ship",
       "z = (abs(re(z)) + I*abs(im(z)))**2 + c; record_orbit if escapes",
       "Buddhabrot variant on Burning Ship fractal — accumulates escape-orbit trajectories of |z|²+c iteration.",
       _BBROT_REF, aliases=["Burning Buddhabrot"]),
    _e("Buddhabrot Tricorn",
       "z = conj(z)**2 + c; record_orbit if escapes",
       "Buddhabrot variant on tricorn (Mandelbar) fractal.",
       _BBROT_REF, aliases=["Tricorn Buddhabrot"]),
    _e("Buddhabrot Newton z^3-1",
       "z = z - (z**3 - 1)/(3*z**2); record_orbit until convergence",
       "Buddhabrot rendering of Newton iteration for z³-1 — accumulate Newton trajectories before convergence to roots.",
       _BBROT_REF),

    # ---- Orbit trap family (Pickover stalks + various trap shapes)
    _e("Orbit Trap Circle (Pickover Stalks)",
       "z = z*z + c; trap_min(|z| - 1.0)",
       "Pickover-stalk circle orbit trap — colour pixel by minimum distance of orbit to unit circle |z|=1; produces Pickover stalk patterns inside Mandelbrot.",
       _PICKOVER_REF, aliases=["Pickover stalks"]),
    _e("Orbit Trap Cross",
       "z = z*z + c; trap_min(min(|re(z)|, |im(z)|))",
       "Cross-shaped orbit trap — colour by orbit's nearest approach to the real or imaginary axis; produces axial cross patterns.",
       _PICKOVER_REF),
    _e("Orbit Trap Square",
       "z = z*z + c; trap_min(max(|re(z)|, |im(z)|) - 0.5)",
       "Square-frame orbit trap — colour by orbit's nearest approach to a square frame.",
       _PICKOVER_REF),
    _e("Orbit Trap Point (Origin)",
       "z = z*z + c; trap_min(|z - 0|)",
       "Single-point orbit trap at origin — colour by orbit's closest approach to z=0.",
       _PICKOVER_REF),
    _e("Orbit Trap Point (Custom)",
       "z = z*z + c; trap_min(|z - (0.5 + 0.5*I)|)",
       "Custom-point orbit trap — trap at z=0.5+0.5i; produces eye-like coloured spot.",
       _PICKOVER_REF),
    _e("Orbit Trap Line (Real Axis)",
       "z = z*z + c; trap_min(|im(z)|)",
       "Real-axis line orbit trap — colour by orbit's closest approach to the real axis.",
       _PICKOVER_REF),
    _e("Orbit Trap Line (Imaginary Axis)",
       "z = z*z + c; trap_min(|re(z)|)",
       "Imaginary-axis line orbit trap — colour by orbit's closest approach to the imaginary axis.",
       _PICKOVER_REF),
    _e("Orbit Trap Multi-Lines (Cross)",
       "z = z*z + c; trap_min(min(|im(z)|, |re(z)|, |im(z) - re(z)|, |im(z) + re(z)|))",
       "Multi-line cross orbit trap — colour by orbit's distance to four lines through origin (real, imaginary, two diagonals).",
       _PICKOVER_REF),
    _e("Orbit Trap Heart Curve",
       "z = z*z + c; trap_min(distance_to_heart_curve(z))",
       "Heart orbit trap — colour by orbit's distance to algebraic heart curve r = 1 - sin(theta).",
       _PICKOVER_REF, aliases=["Heart trap"]),
    _e("Orbit Trap Star (5-pointed)",
       "z = z*z + c; trap_min(distance_to_star_5(z))",
       "5-pointed star orbit trap — colour by orbit's distance to a 5-pointed star polygon.",
       _PICKOVER_REF),
    _e("Orbit Trap Spiral",
       "z = z*z + c; trap_min(distance_to_log_spiral(z, b=0.3))",
       "Logarithmic-spiral orbit trap — colour by orbit's distance to logarithmic spiral r = e^(b*theta).",
       _PICKOVER_REF),
    _e("Orbit Trap Text 'A'",
       "z = z*z + c; trap_min(distance_to_glyph_A(z))",
       "Text orbit trap (letter A) — colour by orbit's distance to vector outline of letter A.",
       _PICKOVER_REF, aliases=["text trap"]),
    _e("Orbit Trap Text 'M'",
       "z = z*z + c; trap_min(distance_to_glyph_M(z))",
       "Text orbit trap (letter M) — produces 'M'-shaped coloured contours inside Mandelbrot interior.",
       _PICKOVER_REF),
    _e("Orbit Trap Epicycloid",
       "z = z*z + c; trap_min(distance_to_epicycloid(z, R=1, r=0.3))",
       "Epicycloid orbit trap — orbit distance to epicycloid (rolling-circle curve) producing flower-like coloured contours.",
       _PICKOVER_REF),
    _e("Orbit Trap Rose Curve",
       "z = z*z + c; trap_min(distance_to_rose(z, k=4))",
       "Rose-curve orbit trap r = cos(k*theta) with k=4 — 4-petal rose colour contours.",
       _PICKOVER_REF),
    _e("Orbit Trap Limaçon",
       "z = z*z + c; trap_min(distance_to_limacon(z, a=0.5, b=1.0))",
       "Limaçon (Pascal) orbit trap r = a + b*cos(theta) — limaçon curve trap.",
       _PICKOVER_REF),
    _e("Orbit Trap Cardioid",
       "z = z*z + c; trap_min(distance_to_cardioid(z, a=1.0))",
       "Cardioid orbit trap r = 1 - cos(theta) — heart-shaped trap related to main Mandelbrot bulb.",
       _PICKOVER_REF),
    _e("Orbit Trap Lemniscate",
       "z = z*z + c; trap_min(distance_to_lemniscate(z, a=1.0))",
       "Bernoulli lemniscate orbit trap r²=cos(2*theta) — figure-8 trap producing twin-bulb contours.",
       _PICKOVER_REF),
    _e("Orbit Trap Astroid",
       "z = z*z + c; trap_min(distance_to_astroid(z, a=1.0))",
       "Astroid orbit trap — 4-cusped hypocycloid trap.",
       _PICKOVER_REF),
    _e("Orbit Trap Hypocycloid (3-cusp)",
       "z = z*z + c; trap_min(distance_to_hypocycloid(z, R=1, r=0.333))",
       "3-cusp hypocycloid (deltoid) orbit trap — 3-pointed cusped trap.",
       _PICKOVER_REF),
    _e("Orbit Trap Square Lattice",
       "z = z*z + c; trap_min(min(|re(z) - round(re(z))|, |im(z) - round(im(z))|))",
       "Square-lattice orbit trap — orbit distance to nearest integer-grid line; produces grid-tessellation pattern.",
       _PICKOVER_REF, aliases=["lattice trap"]),
    _e("Orbit Trap Hexagonal Lattice",
       "z = z*z + c; trap_min(distance_to_hex_lattice(z, scale=1.0))",
       "Hexagonal-lattice orbit trap — orbit distance to hexagonal honeycomb grid.",
       _PICKOVER_REF),
    _e("Orbit Trap Field Lines",
       "z = z*z + c; trap_min(distance_to_field_line(z, atan2(im(z), re(z))))",
       "Field-line orbit trap — colour by accumulated angular displacement; reveals external rays of Mandelbrot set.",
       [{"author": "C. T. McMullen", "title": "Complex Dynamics and Renormalization",
         "year": 1994, "url": "https://en.wikipedia.org/wiki/External_ray"}]),
    _e("Orbit Trap Composite Multi-Shape",
       "z = z*z + c; trap_min(min(|z| - 1.0, max(|re(z)|, |im(z)|) - 0.5, |z - 0.25|))",
       "Composite orbit trap (circle + square + point) — overlays multiple trap geometries for layered colour bands.",
       _PICKOVER_REF),
    _e("Orbit Trap Concentric Rings",
       "z = z*z + c; trap_min(abs((|z| - 0.5) mod 0.5))",
       "Concentric-ring orbit trap — orbit distance to nearest concentric ring (modulo 0.5 in radius).",
       _PICKOVER_REF),
    _e("Smooth Iteration Coloring (Continuous)",
       "z = z*z + c; smooth_iter = n + 1 - log(log(|z|))/log(2)",
       "Continuous (smooth) iteration count colouring — Niko Bayer's logarithmic-smoothing of escape iteration; eliminates banding artifacts.",
       [{"author": "F. Hege", "title": "Smooth iteration counts for fractals",
         "year": 1996, "url": "https://en.wikipedia.org/wiki/Mandelbrot_set#Smooth_coloring"}],
       aliases=["continuous coloring"]),
    _e("Triangle Inequality Average",
       "z = z*z + c; tia = average of (|z| - |z_prev*z_prev| ; |z| + |z_prev*z_prev|)",
       "Triangle-inequality average colouring (TIA) — Kerry Mitchell's 1999 colouring producing smooth interior banding.",
       [{"author": "K. Mitchell", "title": "The triangle inequality average colouring method",
         "year": 1999, "url": "https://www.fractalus.com/kerry/articles/tia/tia.html"}]),
    _e("Curvature Estimation Coloring",
       "z = z*z + c; curvature = atan2(im((z - z_prev)/(z_prev - z_prev2)), re((z - z_prev)/(z_prev - z_prev2)))",
       "Curvature-based colouring — colour by local curvature of orbit, exposing hidden geometry within bounded set.",
       _PICKOVER_REF),
]


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
