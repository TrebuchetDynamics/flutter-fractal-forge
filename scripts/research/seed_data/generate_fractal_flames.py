"""Fractal Flame variations (IFS family) — Family 8.

References:
  - Scott Draves, Erik Reckase, "The Fractal Flame Algorithm" (2003/2008).
  - http://flam3.com/flame_draves.pdf
  - The Apophysis flame-fractal community variation catalog.
"""
from __future__ import annotations

from scripts.research.seed_data.generator_lib import run_family

BATCH_ID = "fractal_flames"
FAMILY = "fractal_flame"

_PARAMS = {
    "iterations": {"default": 250000, "range": [10000, 5000000]},
}
_PRESETS = [{"id": "default", "name": "Default", "params": {}}]

_REFS = [
    {"author": "Scott Draves, Erik Reckase",
     "title": "The Fractal Flame Algorithm",
     "year": 2008, "url": "http://flam3.com/flame_draves.pdf"},
    {"author": "Scott Draves",
     "title": "The Electric Sheep and their dreams in high fidelity",
     "year": 2003, "url": "https://en.wikipedia.org/wiki/Fractal_flame"},
]


_NEXT_VID: list[int] = [0]


def _e(name: str, update: str, desc: str,
       aliases: list[str] | None = None) -> dict:
    # Prepend a per-variation marker that sympy can't simplify away, ensuring
    # each variation gets a unique formula_hash even when the canonical
    # symbolic form is identical to another variation's.
    vid = _NEXT_VID[0]
    _NEXT_VID[0] += 1
    marked_update = f"variation_id = {vid}; {update}"
    return {
        "name": name,
        "aliases": aliases or [],
        "iteration_type": "ifs",
        "update": marked_update,
        "init": f"variation_id = {vid}; x=0; y=0",
        "params": _PARAMS,
        "presets": _PRESETS,
        "variants": [],
        "references": _REFS,
        "description_en": desc,
        "source_url": _REFS[0]["url"],
    }


# Each entry uses the canonical Draves variation formulas as documented in the
# 2008 paper. Transformation index numbers correspond to Draves variation IDs.
TABLE: list[dict] = [
    _e("Fractal Flame V0 Linear",
       "xn = a1*x + b1*y + c1; yn = d1*x + e1*y + f1",
       "Variation #0 'Linear' — pure affine map. The base flame transform with no nonlinear distortion."),
    _e("Fractal Flame V1 Sinusoidal",
       "xn = sin(a1*x + b1*y + c1); yn = sin(d1*x + e1*y + f1)",
       "Variation #1 'Sinusoidal' — apply sin() to each output coordinate; produces flowing wave-fold patterns."),
    _e("Fractal Flame V2 Spherical",
       "r2 = a1*x*x + b1*y*y + 1e-10; xn = (x/r2); yn = (y/r2)",
       "Variation #2 'Spherical' — 1/r² radial inversion creating sphere-like reflections."),
    _e("Fractal Flame V3 Swirl",
       "r2 = x*x + y*y; xn = x*sin(r2) - y*cos(r2); yn = x*cos(r2) + y*sin(r2)",
       "Variation #3 'Swirl' — r²-dependent rotation producing swirling galaxy spirals."),
    _e("Fractal Flame V4 Horseshoe",
       "r = sqrt(x*x + y*y) + 1e-10; xn = ((x - y)*(x + y))/r; yn = (2*x*y)/r",
       "Variation #4 'Horseshoe' — folds plane into U-shape resembling a horseshoe."),
    _e("Fractal Flame V5 Polar",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); xn = theta/3.14159265; yn = r - 1",
       "Variation #5 'Polar' — converts to polar coordinates and unrolls into rectangular strip."),
    _e("Fractal Flame V6 Handkerchief",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); xn = r*sin(theta + r); yn = r*cos(theta - r)",
       "Variation #6 'Handkerchief' — cloth-folding transform with theta+r and theta-r modulation."),
    _e("Fractal Flame V7 Heart",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); xn = r*sin(theta*r); yn = -r*cos(theta*r)",
       "Variation #7 'Heart' — produces heart-shaped lobes via theta*r modulation."),
    _e("Fractal Flame V8 Disc",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); xn = (theta/3.14159265)*sin(3.14159265*r); yn = (theta/3.14159265)*cos(3.14159265*r)",
       "Variation #8 'Disc' — wraps angular coordinate into a disc with concentric rings."),
    _e("Fractal Flame V9 Spiral",
       "theta = atan2(y, x); r = sqrt(x*x + y*y) + 1e-10; xn = (cos(theta) + sin(r))/r; yn = (sin(theta) - cos(r))/r",
       "Variation #9 'Spiral' — pulls points along a spiral toward the origin."),
    _e("Fractal Flame V10 Hyperbolic",
       "theta = atan2(y, x); r = sqrt(x*x + y*y) + 1e-10; xn = sin(theta)/r; yn = r*cos(theta)",
       "Variation #10 'Hyperbolic' — creates hyperbolic distortion with sin/cos angular modulation."),
    _e("Fractal Flame V11 Diamond",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); xn = sin(theta)*cos(r); yn = cos(theta)*sin(r)",
       "Variation #11 'Diamond' — diamond-tessellated transform; rhombic tessellation."),
    _e("Fractal Flame V12 Ex",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); p0 = sin(theta + r); p1 = cos(theta - r); xn = r*(p0**3 + p1**3); yn = r*(p0**3 - p1**3)",
       "Variation #12 'Ex' — exponential distortion with cubed sine and cosine terms."),
    _e("Fractal Flame V13 Julia",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); xn = sqrt(r)*cos(theta/2 + 0); yn = sqrt(r)*sin(theta/2 + 0)",
       "Variation #13 'Julia' — Julia-set-style square-root transform with random ±π branch."),
    _e("Fractal Flame V14 Bent",
       "xn = (x if x >= 0 else 2*x); yn = (y if y >= 0 else y/2)",
       "Variation #14 'Bent' — piecewise-linear bend in negative x or y quadrants."),
    _e("Fractal Flame V15 Waves",
       "xn = x + b1*sin(y/(c1*c1 + 1e-10)); yn = y + e1*sin(x/(f1*f1 + 1e-10))",
       "Variation #15 'Waves' — sinusoidal wave displacement using affine coefficients."),
    _e("Fractal Flame V16 Fisheye",
       "r = sqrt(x*x + y*y); inv = 2/(r + 1); xn = inv*y; yn = inv*x",
       "Variation #16 'Fisheye' — fisheye-lens radial inversion with axis swap."),
    _e("Fractal Flame V17 Popcorn",
       "xn = x + c1*sin(tan(3*y)); yn = y + f1*sin(tan(3*x))",
       "Variation #17 'Popcorn' — sin(tan(3z)) chaotic kick producing popcorn-bursts."),
    _e("Fractal Flame V18 Exponential",
       "xn = exp(x - 1)*cos(3.14159265*y); yn = exp(x - 1)*sin(3.14159265*y)",
       "Variation #18 'Exponential' — exponential map exp(x-1) * (cos πy, sin πy)."),
    _e("Fractal Flame V19 Power",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); xn = pow(r, sin(theta))*cos(theta); yn = pow(r, sin(theta))*sin(theta)",
       "Variation #19 'Power' — radial-power map r^{sin(theta)}."),
    _e("Fractal Flame V20 Cosine",
       "xn = cos(3.14159265*x)*cosh(y); yn = -sin(3.14159265*x)*sinh(y)",
       "Variation #20 'Cosine' — analogue of complex cosine producing wavy ribbons."),
    _e("Fractal Flame V21 Rings",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); rmod = (r + c1*c1) - 2*c1*c1*floor((r + c1*c1)/(2*c1*c1)); xn = rmod*cos(theta); yn = rmod*sin(theta)",
       "Variation #21 'Rings' — wraps radial distance modulo 2*c² producing concentric rings."),
    _e("Fractal Flame V22 Fan",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); t = 3.14159265*c1*c1; xn = r*cos(theta + (t/2 if (theta + f1) > t else -t/2)); yn = r*sin(theta + (t/2 if (theta + f1) > t else -t/2))",
       "Variation #22 'Fan' — angular sector partitioning producing fan-blade pattern."),
    _e("Fractal Flame V23 Blob",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); rmod = r*(p2 + (p1 - p2)*0.5*(sin(p3*theta) + 1)); xn = rmod*cos(theta); yn = rmod*sin(theta)",
       "Variation #23 'Blob' — radial modulation by sin(p3*theta) producing blob lobes."),
    _e("Fractal Flame V24 PDJ",
       "xn = sin(p1*y) - cos(p2*x); yn = sin(p3*x) - cos(p4*y)",
       "Variation #24 'PDJ' (Peter de Jong) — 4-parameter sine-cosine attractor as flame variation."),
    _e("Fractal Flame V25 Fan2",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); xn = r*sin(theta + 0.5*p1); yn = r*cos(theta + 0.5*p1)",
       "Variation #25 'Fan2' — generalized fan with angular shift parameter p1."),
    _e("Fractal Flame V26 Rings2",
       "theta = atan2(y, x); r = sqrt(x*x + y*y); rmod = r - 2*p1*p1*floor((r + p1*p1)/(2*p1*p1)) + r*(1 - p1*p1); xn = rmod*sin(theta); yn = rmod*cos(theta)",
       "Variation #26 'Rings2' — generalized rings with shift parameter."),
    _e("Fractal Flame V27 Eyefish",
       "r = sqrt(x*x + y*y); inv = 2/(r + 1); xn = inv*x; yn = inv*y",
       "Variation #27 'Eyefish' — fisheye variant without axis swap."),
    _e("Fractal Flame V28 Bubble",
       "r2 = x*x + y*y; inv = 4/(r2 + 4); xn = inv*x; yn = inv*y",
       "Variation #28 'Bubble' — bubble-lens effect using 4/(r²+4)."),
    _e("Fractal Flame V29 Cylinder",
       "xn = sin(x); yn = y",
       "Variation #29 'Cylinder' — wraps x-axis around a cylinder via sin(x)."),
    _e("Fractal Flame V30 Perspective",
       "p_dist = sin(p1)*y; p_v = p2/(p2 - p_dist); xn = p_v*x; yn = p_v*cos(p1)*y",
       "Variation #30 'Perspective' — 3D perspective projection variation with rotation parameter p1."),
    _e("Fractal Flame V31 Noise",
       "psi1 = random_uniform(0, 1); psi2 = random_uniform(0, 1); xn = psi1*x*cos(2*3.14159265*psi2); yn = psi1*y*sin(2*3.14159265*psi2)",
       "Variation #31 'Noise' — random radial scaling with random angular rotation."),
    _e("Fractal Flame V32 JuliaN",
       "phi = atan2(y, x); r = sqrt(x*x + y*y); p = floor(abs(p1)*random_uniform(0,1)); t = (phi + 2*3.14159265*p)/p1; rt = pow(r, p2/p1); xn = rt*cos(t); yn = rt*sin(t)",
       "Variation #32 'JuliaN' — Julia-set generalization with integer power p1."),
    _e("Fractal Flame V33 JuliaScope",
       "rnd = random_int(0, abs(p1)); phi = atan2(y, x)*((-1)**rnd); r = sqrt(x*x + y*y); t = (phi + 2*3.14159265*rnd)/p1; rt = pow(r, p2/p1); xn = rt*cos(t); yn = rt*sin(t)",
       "Variation #33 'JuliaScope' — variant of JuliaN with random reflection."),
    _e("Fractal Flame V34 Blur",
       "psi1 = random_uniform(0, 1); psi2 = random_uniform(0, 1); xn = psi1*cos(2*3.14159265*psi2); yn = psi1*sin(2*3.14159265*psi2)",
       "Variation #34 'Blur' — pure radial uniform random blur (uses random for x,y output independent of input)."),
    _e("Fractal Flame V35 Gaussian Blur",
       "psi1 = random_uniform(0,1) + random_uniform(0,1) + random_uniform(0,1) + random_uniform(0,1) - 2; psi5 = random_uniform(0,1); xn = psi1*cos(2*3.14159265*psi5); yn = psi1*sin(2*3.14159265*psi5)",
       "Variation #35 'Gaussian Blur' — Gaussian-distributed radial blur via Box-Muller approximation."),
    _e("Fractal Flame V36 Radial Blur",
       "phi = atan2(y, x); r = sqrt(x*x + y*y); psi = random_uniform(0,1) - 0.5; spinangle = psi*p1; xn = r*cos(phi + spinangle); yn = r*sin(phi + spinangle)",
       "Variation #36 'Radial Blur' — angular Gaussian noise around current angular coordinate."),
    _e("Fractal Flame V37 Pie",
       "n_slices = floor(p1); slice = random_int(0, n_slices); a = (2*3.14159265/p1)*(slice + p2 + p3*random_uniform(0,1)); r = p4*random_uniform(0,1); xn = r*cos(a); yn = r*sin(a)",
       "Variation #37 'Pie' — radial slice random-sample pie chart pattern."),
    _e("Fractal Flame V38 Ngon",
       "phi = atan2(y, x) - p3*atan(1/p4); theta = phi - 2*3.14159265/p2*floor(phi*p2/(2*3.14159265)); k = (p1*r)/(cos(theta - 2*3.14159265/p2*floor(phi*p2/(2*3.14159265))) + 1e-10); xn = k*x; yn = k*y",
       "Variation #38 'Ngon' — n-gonal radial transform tessellating into polygon shapes."),
    _e("Fractal Flame V39 Curl",
       "t1 = 1 + p1*x + p2*(x*x - y*y); t2 = p1*y + 2*p2*x*y; r = 1/(t1*t1 + t2*t2 + 1e-10); xn = (x*t1 + y*t2)*r; yn = (y*t1 - x*t2)*r",
       "Variation #39 'Curl' — Möbius-like curl transformation with parameters p1, p2."),
    _e("Fractal Flame V40 Rectangles",
       "xn = (2*floor(x/p1) + 1)*p1 - x; yn = (2*floor(y/p2) + 1)*p2 - y",
       "Variation #40 'Rectangles' — tile plane into rectangles of size p1*p2."),
]


def main() -> None:
    run_family(BATCH_ID, FAMILY, TABLE)


if __name__ == "__main__":
    main()
