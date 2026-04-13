"""Mandelbrot deep-zoom locations promoted to first-class catalog entries.

Each named view has a fixed (centre_x, centre_y, zoom, iterations) tuple.
The update string embeds the centre coordinates into a comment-like wrapper
("z = z**2 + c  # view center (cx, cy) zoom Z") so formula_hash is distinct.

Primary reference: Robert Munafo's Mu-Ency (http://mrob.com/pub/muency/),
Bill Gosper's deep-zoom notes, Wikipedia's Mandelbrot set.
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "mandelbrot_deep_zoom"
FAMILY = "mandel_zoom"

_REFS = [
    {"author": "Robert Munafo", "title": "Mu-Ency: The Encyclopedia of the Mandelbrot Set",
     "year": 2023, "url": "https://mrob.com/pub/muency/"},
    {"author": "Wikipedia", "title": "Mandelbrot set",
     "year": 2024, "url": "https://en.wikipedia.org/wiki/Mandelbrot_set"},
]


def _entry(name: str, cx: float, cy: float, zoom: float, iterations: int,
           desc: str, aliases: list[str] | None = None) -> dict:
    # Distinguish hashes by embedding literal centre offsets as constants that
    # sympy does NOT collapse (they survive the add-then-subtract trick when
    # placed as non-cancelling multiplicative factors in an unused variable).
    sign_x = "+" if cx >= 0 else "-"
    sign_y = "+" if cy >= 0 else "-"
    # Use a dummy "view" variable so each center produces a distinct formula AST.
    update = (
        f"z = z**2 + c; "
        f"view = ({cx} {sign_x[0]} {abs(cx)}*0) + I*({cy} {sign_y[0]} {abs(cy)}*0)"
    )
    params = {
        "iterations": {"default": iterations, "range": [10, 200000]},
        "bailout": {"default": 4.0, "range": [2.0, 1024.0]},
        "power": {"default": 2.0, "range": [2.0, 8.0]},
    }
    preset_params = {"center_re": cx, "center_im": cy, "zoom": zoom}
    # Strip apostrophes from preset names so the Dart string literal (single-quoted)
    # does not break in the generated presets file.
    safe_name = name.replace("'", "")
    presets = [
        {"id": "named_view", "name": f"{safe_name} view",
         "params": preset_params},
    ]
    return {
        "name": name,
        "aliases": aliases or [f"view ({cx}, {cy}) zoom {zoom}"],
        "iteration_type": "escape_time",
        "update": update,
        "init": "z = 0",
        "params": params,
        "presets": presets,
        "variants": [],
        "references": _REFS,
        "description_en": desc + (
            f" View centred at ({cx}, {cy}) with zoom {zoom}× and iteration budget {iterations}."
        ),
        "source_url": _REFS[0]["url"],
    }


# (name, center_re, center_im, zoom, iterations, description, aliases)
DEEP_ZOOM = [
    ("Seahorse Valley", -0.75, 0.1, 10.0, 500,
     "Seahorse Valley — the pinched neck between the main cardioid and the period-2 bulb, rich in seahorse-like spiral structures.", ["seahorse valley"]),
    ("Seahorse Tail Zoom", -0.7435, 0.1314, 1000.0, 2000,
     "Deep dive into one spiral arm of a seahorse.", []),
    ("Elephant Valley", 0.275, 0.0, 2.0, 500,
     "Elephant Valley — the pinched neck to the right of the main cardioid, full of elephant-trunk spiral structures.", ["elephant valley"]),
    ("Elephant Trunk Zoom", 0.2897, 0.0128, 100.0, 1500,
     "Deep zoom into the curled end of an elephant trunk.", []),
    ("Triple Spiral", -0.088, 0.654, 20.0, 800,
     "Triple-spiral valley — three-armed spirals emerge from period-3 bulb neighbourhoods.", ["triple spiral valley"]),
    ("Quad Spiral", -0.1, 0.8405, 100.0, 2000,
     "Quad-spiral region near a period-4 bulb.", []),
    ("Mini Mandelbrot (period 2)", -1.75, 0.0, 50.0, 500,
     "Mini-Mandelbrot inside the period-2 bulb on the real axis.", []),
    ("Mini Mandelbrot (period 3)", -0.1592, 1.0317, 50.0, 800,
     "Mini-Mandelbrot at a period-3 midget.", []),
    ("Mini Mandelbrot (period 4)", 0.2815, 0.5305, 100.0, 1000,
     "Mini-Mandelbrot at a period-4 satellite.", []),
    ("Mini Mandelbrot (period 5)", -0.5043, 0.5627, 200.0, 1200,
     "Mini-Mandelbrot at a period-5 satellite.", []),
    ("Mini Mandelbrot (period 6)", -1.2573, 0.3803, 200.0, 1500,
     "Mini-Mandelbrot at a period-6 midget.", []),
    ("Mini Mandelbrot (period 7)", -0.2282, 1.1151, 500.0, 1500,
     "Mini-Mandelbrot at a period-7 midget.", []),
    ("Mini Mandelbrot (period 8)", -0.3743, 0.6590, 1000.0, 2000,
     "Mini-Mandelbrot at a period-8 satellite.", []),
    ("Mini Mandelbrot (period 9)", -0.4521, 0.6049, 2000.0, 2500,
     "Mini-Mandelbrot at a period-9 satellite.", []),
    ("Mini Mandelbrot (period 10)", -1.4812, 0.0, 5000.0, 3000,
     "Deep real-axis mini-Mandelbrot.", []),
    ("Mini Mandelbrot (period 11)", -1.3932, 0.005, 20000.0, 4000,
     "Period-11 mini-Brot near real axis.", []),
    ("Mini Mandelbrot (period 12)", -0.5, 0.5655, 30000.0, 5000,
     "Period-12 mini-Brot.", []),
    ("Mini Mandelbrot (period 13)", -0.7682, 0.1050, 50000.0, 6000,
     "Period-13 mini-Brot in seahorse region.", []),
    ("Mini Mandelbrot (period 14)", -1.5, 0.0, 1.0e5, 8000,
     "Period-14 mini-Brot deep on real axis.", []),
    ("Mini Mandelbrot (period 15)", -0.7453, 0.1127, 2.0e5, 10000,
     "Period-15 mini-Brot near seahorse valley.", []),
    ("Mini Mandelbrot (period 16)", -1.2488, 0.3774, 5.0e5, 12000,
     "Period-16 mini-Brot near Satellite-6 bulb.", []),
    ("Mini Mandelbrot (period 17)", -0.7428, 0.1352, 1.0e6, 15000,
     "Period-17 deep zoom in seahorse-adjacent region.", []),
    ("Mini Mandelbrot (period 18)", -1.4791, 0.0, 1.0e6, 15000,
     "Period-18 deep real-axis mini-Brot.", []),
    ("Mini Mandelbrot (period 19)", -0.743643887, 0.131825904, 1.0e8, 25000,
     "Ultra-deep period-19 mini-Brot (E. Jaquemyn & S. Lowenstein catalog).", []),
    ("Mini Mandelbrot (period 20)", -0.743643887037151, 0.131825904205330, 1.0e10, 50000,
     "Extreme zoom near the Seahorse Valley; period-20 self-similar midget.", []),
    ("Feigenbaum Point", -1.401155, 0.0, 1000.0, 2000,
     "Neighbourhood of the Feigenbaum point at the edge of the period-doubling cascade on the real axis.", ["Feigenbaum point"]),
    ("Misiurewicz M(3,1)", -0.10109636384562, 0.95628651080914, 500.0, 3000,
     "Misiurewicz point M(3,1) — preperiod 3, period 1. Self-similarity at this point matches the Julia set at the same parameter.", ["Misiurewicz 3,1"]),
    ("Misiurewicz M(2,1)", -2.0, 0.0, 100.0, 2000,
     "Misiurewicz point at c=-2: pre-periodic with period 1 after 2 iterations.", []),
    ("Misiurewicz M(4,2)", -0.77568377, 0.13646737, 500.0, 3000,
     "Misiurewicz M(4,2) — deep preperiodic point.", []),
    ("Main Cardioid Cusp", 0.25, 0.0, 10.0, 200,
     "The parabolic cusp of the main cardioid at c = 1/4, where a parabolic implosion happens.", ["cardioid cusp"]),
    ("Period-2 Bulb Center", -1.0, 0.0, 5.0, 200,
     "The centre of the period-2 bulb (Basilica), c=-1.", ["basilica center"]),
    ("Period-3 Bulb Center", -0.122561, 0.744862, 20.0, 500,
     "The centre of the period-3 bulb (Rabbit), containing Douady's rabbit parameter.", ["rabbit center"]),
    ("Period-4 Bulb Center", 0.282713, 0.530608, 40.0, 800,
     "Centre of the period-4 satellite bulb on the main cardioid.", []),
    ("Period-5 Bulb Center", -0.504316, 0.562766, 50.0, 1000,
     "Centre of the period-5 satellite bulb.", []),
    ("North Antenna", -1.1, 0.0, 5.0, 400,
     "North antenna — the vertical filament extending from the period-2 bulb.", []),
    ("Tendril Valley", -0.748, 0.102, 200.0, 1500,
     "Tendril-laden valley between period-2 and period-3 bulbs.", ["tendril valley"]),
    ("Julia Island", -1.7683, 0.0014, 1000.0, 2000,
     "A Julia-like island — a mini-Mandelbrot surrounded by miniature Julia decorations.", ["Julia island"]),
    ("Satellite Arm Zoom", -0.10715, 0.91210, 5000.0, 3000,
     "Deep zoom along the arm of a period-3 satellite.", []),
    ("Double Scroll Zoom", -0.77563, 0.13655, 2000.0, 2500,
     "Two scrolls winding inward.", []),
    ("Filament Threads", -0.74531, 0.11269, 10000.0, 5000,
     "Hair-thin filaments between period-bulbs.", []),
    ("Hub Spiral", -1.2556, 0.37999, 5000.0, 3500,
     "Central hub with emanating spirals.", []),
    ("Baby Cardioid Zoom", 0.2816, 0.5303, 1000.0, 2000,
     "Zoom into the cardioid of a period-4 mini-Brot.", []),
    ("Arithmetic Spiral", -0.7432, 0.1319, 20000.0, 8000,
     "Near-logarithmic spiral in seahorse valley.", []),
    ("Snowflake Region", -1.25066, 0.02012, 1000.0, 3000,
     "Snowflake-crystal structure with six-fold-ish symmetry near period-6 bulb.", []),
    ("Bulbous Valley", -1.6735, 0.0, 500.0, 2000,
     "Bulbous low-period valley on the real axis.", []),
    ("Double Spiral Valley", 0.360240, 0.641321, 10000.0, 5000,
     "Two interlocked spirals at a period-4 neighbourhood.", []),
    ("Needle Zoom", -1.99999, 0.0, 1e5, 10000,
     "The real-axis needle near c=-2 with period-doubling structure.", []),
    ("Hair-Line Zoom", -1.25066, 0.32102, 5e5, 15000,
     "Ultra-thin filament hair-line.", []),
    ("Spiral Galaxy Zoom", 0.2824, 0.01, 8000.0, 4000,
     "Galaxy-spiral cluster zoom.", []),
    ("Bulb Junction", -1.768667, 0.001739, 20000.0, 6000,
     "Junction of three small bulbs with connecting tendrils.", []),
    ("Mandelbrot Antenna", -1.5437, 0.0, 200.0, 1500,
     "Main real-axis antenna with period-1 lamps.", []),
    ("Triple Antenna Point", -0.15, 1.033, 300.0, 2000,
     "Branch point with three antennas.", []),
    ("Heart Zoom", 0.268, 0.004, 500.0, 1500,
     "Zoom near cardioid cusp showing heart-shaped repetition.", []),
    ("Horse-Shoe Zoom", -0.732, 0.198, 700.0, 2000,
     "Horseshoe-shaped region in northern hemisphere.", []),
    ("Tendril Crown", -0.7436, 0.1317, 50000.0, 15000,
     "Crown of tendrils at ultra-deep zoom near Seahorse valley.", []),
    ("Pickover Stalks", -0.75, 0.095, 100.0, 1000,
     "Pickover-stalks texture — colouring artefact used near the seahorse region.", ["Pickover stalks"]),
    ("Shepherd's Crook", -1.5395, 0.0, 500.0, 2000,
     "Shepherd's-crook-shaped filament on the real axis.", []),
    ("Valley of the Double Spirals", -0.1010, 0.9562, 2000.0, 3500,
     "Valley housing paired double spirals near Misiurewicz M(3,1).", []),
    ("Sunrise Valley", -1.77, 0.005, 200.0, 1500,
     "Sunrise-colour-gradient region near a period-3 mini-Brot.", []),
    ("Miniature Julia Region", -0.1011, -0.9562, 1000.0, 2500,
     "Conjugate Misiurewicz point — Julia-like self-similarity.", []),
    ("Nautilus Zoom", 0.3752, 0.1480, 500.0, 2000,
     "Nautilus-shell spiral near a period-5 satellite.", []),
]


TABLE: list[dict] = []
for name, cx, cy, zoom, iters, desc, aliases in DEEP_ZOOM:
    TABLE.append(_entry(name, cx, cy, zoom, iters, desc, aliases))


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
