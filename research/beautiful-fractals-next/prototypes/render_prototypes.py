#!/usr/bin/env python3
"""Offline numpy prototypes for candidate fractals (research evidence only).

Each candidate is rendered at 512x512 (or 384 for the stack) with a shared
cosine-palette + sRGB discipline matching the Flutter shaders, then scored with
the metric definitions from lib/features/catalog/data/launch_visual_metrics.dart
so the shortlist is directly comparable to catalog thumbnails.

No network, no GPU, no Flutter dependency. Outputs:
  prototypes/<id>.png
  prototypes/metrics.json
"""

from __future__ import annotations

import json
import math
import os

import numpy as np
from PIL import Image

SIZE = 512
OUT = os.path.dirname(os.path.abspath(__file__))


# ---------------------------------------------------------------- palette ----
def iq_palette(t, a=(0.5, 0.5, 0.5), b=(0.5, 0.5, 0.5),
               c=(1.0, 1.0, 1.0), d=(0.00, 0.33, 0.67)):
    a, b, c, d = map(np.asarray, (a, b, c, d))
    t = np.asarray(t)[..., None]
    return a + b * np.cos(6.28318 * (c * t + d))


def to_srgb(lin):
    lin = np.clip(lin, 0.0, 1.0)
    hi = 1.055 * np.power(np.maximum(lin, 0.0031308), 1 / 2.4) - 0.055
    return np.where(lin < 0.0031308, lin * 12.92, hi)


RAMP_POS = np.array([0.00, 0.18, 0.38, 0.58, 0.78, 1.00])
RAMP_COL = np.array([
    [0.010, 0.014, 0.030],   # ink
    [0.055, 0.115, 0.300],   # deep blue
    [0.230, 0.170, 0.520],   # violet
    [0.750, 0.270, 0.480],   # magenta
    [0.980, 0.640, 0.260],   # gold
    [1.000, 0.960, 0.840],   # warm white
])


def ramp(t):
    """Cohesive ink -> blue -> violet -> magenta -> gold -> white ramp."""
    t = np.clip(np.asarray(t, dtype=np.float64), 0.0, 1.0)
    return np.stack([np.interp(t, RAMP_POS, RAMP_COL[:, c]) for c in range(3)], axis=-1)


def grid(lo=-1.0, hi=1.0, n=SIZE):
    y, x = np.mgrid[0:n, 0:n].astype(np.float64)
    x = (x + 0.5) / n * (hi - lo) + lo
    y = (y + 0.5) / n * (hi - lo) + lo
    return x, y


# ----------------------------------------------------------------- metrics ---
def _stats(v):
    v = np.asarray(v, dtype=np.float64).ravel()
    return float(v.mean()), float(v.std())


def metrics(rgb):
    img = (np.clip(rgb, 0, 1) * 255).astype(np.uint8)
    lum = 0.2126 * img[..., 0] + 0.7152 * img[..., 1] + 0.0722 * img[..., 2]
    h, w = img.shape[:2]
    mean_l, std_l = _stats(lum)
    dark = float((lum <= 16.0).mean())

    q = (img >> 4).astype(np.int32)
    key = (q[..., 0] << 8) | (q[..., 1] << 4) | q[..., 2]
    _, counts = np.unique(key, return_counts=True)
    dominant = float(counts.max() / key.size)

    center = lum[h // 4:(h * 3) // 4, w // 4:(w * 3) // 4]
    inset = max(1, min(h, w) // 8)
    edges = np.concatenate([lum[:inset, :].ravel(), lum[-inset:, :].ravel(),
                            lum[:, :inset].ravel(), lum[:, -inset:].ravel()])
    center_score = min(1.0, float(np.std(center)) / 64.0)
    edge_score = min(1.0, float(np.std(edges)) / 64.0)

    if mean_l < 18.0 and dark > 0.90:
        verdict = "near-black"
    elif center_score < 0.08 and edge_score < 0.08:
        verdict = "needs-framing"
    elif dominant > 0.92 or std_l < 3.0:
        verdict = "needs-palette"
    else:
        verdict = "pass"

    return {"centerDetailScore": round(center_score, 3),
            "edgeDetailScore": round(edge_score, 3),
            "luminanceStdDev": round(std_l, 2),
            "meanLuminance": round(mean_l, 2),
            "darkPixelRatio": round(dark, 3),
            "dominantColorRatio": round(dominant, 3),
            "nonTransparentRatio": 1.0,
            "verdict": verdict}


# -------------------------------------------------------------- candidates ---
def kaliset(iters=17, scale=1.0, rot=0.05, c=(0.6, 0.4)):
    """Inversion-fold ("Kali") Julia set: p <- |p|/|p|^2 - c with per-step rotation.

    ``c`` is the fixed Julia parameter; the accompanying Mandelbrot-analogue
    uses c = pixel. Orbit accumulation gives the filigree lattice.
    """
    x, y = grid(-1.0, 1.0)
    px, py = x * scale, y * scale
    cx, cy = np.full_like(px, c[0]), np.full_like(py, c[1])
    ca, sa = math.cos(rot), math.sin(rot)
    trap = np.full_like(px, 1e9)
    acc = np.zeros_like(px)

    for _ in range(iters):
        d = np.maximum(px * px + py * py, 1e-6)
        px, py = np.abs(px) / d - cx, np.abs(py) / d - cy
        px, py = ca * px - sa * py, sa * px + ca * py
        trap = np.minimum(trap, np.abs(px) + np.abs(py))
        acc += np.exp(-5.0 * trap)

    t = np.log1p(acc)
    t /= t.max() + 1e-9
    ridge = 1.0 / (1.0 + 60.0 * trap)
    shade = 0.55 * t ** 1.4 + 0.45 * ridge * (0.35 + 0.65 * t)
    return to_srgb(ramp(shade) * (0.35 + 0.85 * shade[..., None]))


def chladni(modes=13, warp=0.22):
    """Nodal-line ("cymatic") field with a recursive warp stage.

    Extra modes add finer nodal lines; the coarse field displaces the fine one,
    which nests the plate figures instead of repeating one symmetric plate.
    """
    x, y = grid(-1, 1)
    coarse = np.zeros_like(x)
    for k in range(5):
        n, m = k + 1, 2 * k + 3
        coarse += (np.cos(n * math.pi * x) * np.cos(m * math.pi * y)
                   - np.cos(m * math.pi * x) * np.cos(n * math.pi * y)) / (k + 1)

    xw = x + warp * np.tanh(coarse * 0.8)
    yw = y + warp * np.tanh(coarse * 0.8)
    fine = np.zeros_like(x)
    for k in range(modes):
        n, m = k + 1, 3 * k + 5
        fine += (np.cos(n * math.pi * xw) * np.cos(m * math.pi * yw)
                 - np.cos(m * math.pi * xw) * np.cos(n * math.pi * yw)) / (k + 1) ** 0.85

    node = np.exp(-np.abs(fine) * 30.0)
    band = np.exp(-np.abs(fine) * 2.6) - node
    t = 0.28 + 0.22 * np.tanh(coarse * 0.6) + 0.30 * node
    return to_srgb(ramp(t) * (0.16 + 0.55 * band[..., None] + 0.95 * node[..., None]))


def _hash2(ix, iy):
    n = ix * 374761393 + iy * 668265263
    n = (n ^ (n >> 13)) * 1274126177
    return ((n ^ (n >> 16)) & 0xFFFFFF) / float(0xFFFFFF)


def _value_noise(x, y):
    ix, iy = np.floor(x).astype(np.int64), np.floor(y).astype(np.int64)
    fx, fy = x - ix, y - iy
    ux = fx * fx * (3 - 2 * fx)
    uy = fy * fy * (3 - 2 * fy)
    a, b = _hash2(ix, iy), _hash2(ix + 1, iy)
    c, d = _hash2(ix, iy + 1), _hash2(ix + 1, iy + 1)
    return (a + (b - a) * ux) * (1 - uy) + (c + (d - c) * ux) * uy


def fbm(x, y, octaves=5, lac=2.03, gain=0.55, ridged=False):
    total = np.zeros_like(x)
    amp, freq, norm = 1.0, 1.0, 0.0
    for o in range(octaves):
        n = _value_noise(x * freq + o * 17.13, y * freq - o * 9.71)
        total += amp * ((1 - np.abs(2 * n - 1)) if ridged else n)
        norm += amp
        amp *= gain
        freq *= lac
    return total / norm


def warp_nebula(strength=2.6, octaves=5):
    """Recursive domain warping over ridged fBm (Quilez-style nebula)."""
    x, y = grid(-1.7, 1.7)
    q = fbm(x, y, octaves)
    r = fbm(x + strength * q + 3.1, y + strength * q - 2.4, octaves, ridged=True)
    f = fbm(x + strength * r * 1.3, y + strength * r * 1.1 - 5.0, octaves, ridged=True)

    v = np.clip(0.55 * f + 0.45 * r, 0, 1)
    density = np.clip((v - 0.42) * 3.2, 0, 1) ** 1.7
    shade = np.clip(0.06 + 0.80 * density ** 0.9, 0, 1)
    return to_srgb(ramp(shade) * (0.12 + 0.95 * density[..., None]))


def hopf_fibration(zsteps=72, zoom=1.35):
    """Volumetric projection of the Hopf fibration S^3 -> S^2.

    Each screen ray samples R^3, inverse-stereographically lifts to S^3, applies
    the Hopf map, and accumulates two base-sphere coordinates: latitude selects
    the invariant torus, longitude selects the point along the fiber. The
    longitude banding is what draws the linked nested rings.
    """
    n = SIZE
    y, x = np.mgrid[0:n, 0:n].astype(np.float64)
    x = (x + 0.5) / n * 2 - 1
    y = (y + 0.5) / n * 2 - 1
    acc_lat = np.zeros((n, n))
    acc_ring = np.zeros((n, n))
    acc_w = np.zeros((n, n))

    for z in np.linspace(-1.8, 1.8, zsteps):
        px, py, pz = x * zoom, y * zoom, np.full_like(x, z)
        r2 = px * px + py * py + pz * pz
        inv = 1.0 / (r2 + 1.0)
        w = (r2 - 1.0) * inv
        X, Y, Z = 2 * px * inv, 2 * py * inv, 2 * pz * inv

        h1 = 2.0 * (X * Z + Y * w)
        h2 = 2.0 * (Y * Z - X * w)
        h3 = X * X + Y * Y - Z * Z - w * w
        lat = np.arccos(np.clip(h3, -1, 1))          # 0..pi torus family
        lon = np.arctan2(h2, h1)                     # fiber phase

        weight = 1.0 / (0.35 + r2)
        acc_w += weight
        acc_lat += weight * lat
        # banding in fiber phase draws the linked circles
        acc_ring += weight * (0.5 + 0.5 * np.cos(9.0 * lon))

    lat_m = acc_lat / (acc_w + 1e-9)
    ring = acc_ring / (acc_w + 1e-9)

    shade = np.clip(0.15 + 0.85 * ring ** 2.2, 0, 1)
    hue = np.clip(lat_m / math.pi, 0, 1)
    col = ramp(0.12 + 0.70 * hue + 0.22 * shade)
    return to_srgb(col * (0.18 + 1.35 * shade[..., None]))


def imordial_square(r, v):
    """Bristorian (imordial) square: e_a^2=-1, e_a e_b = sgn(b-a) e_b.

    Derived from the published rule: the e_b coefficient of v*v is
    x_b * (sum_{a<b} x_a - sum_{a>b} x_a).
    """
    r2 = r * r - np.sum(v * v, axis=0)
    v2 = 2.0 * r * v
    prefix = 0.0
    total = np.sum(v, axis=0)
    out = np.empty_like(v)
    for b in range(v.shape[0]):
        suffix = total - prefix - v[b]
        out[b] = v[b] * (prefix - suffix)
        prefix = prefix + v[b]
    return r2, v2 + out


def _imordial_inside(n=256, iters=40, lo=-1.7, hi=1.7, z0=0.0):
    x, y = grid(lo, hi, n)
    r = np.zeros_like(x)
    v = np.zeros((3,) + x.shape)
    v[0], v[1], v[2] = x, y, np.full_like(x, z0)
    alive = np.ones_like(x, dtype=bool)
    for _ in range(iters):
        r, v = imordial_square(r, v)
        v[0] += x
        v[1] += y
        v[2] += z0
        norm2 = r * r + np.sum(v * v, axis=0)
        alive &= norm2 < 256.0
        if not alive.any():
            break
    return alive


def brimordial_stack(slices=56, n=320, iters=36, lo=-1.55, hi=1.55):
    """Translucent slice stack of the Bristorian z^2 + c set (4D -> 3D view)."""
    img = np.zeros((n, n, 3))
    zs = np.linspace(-0.9, 0.9, slices)
    kernel = np.ones((3, 3))
    for k, z0 in enumerate(zs):
        alive = _imordial_inside(n, iters, lo, hi, z0)
        # boundary of the slice: inside pixels adjacent to outside
        er = alive.copy()
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                er &= np.roll(np.roll(alive, dy, 0), dx, 1)
        edge = alive & ~er
        shade = 1.0 - abs(z0) / 1.0
        col = iq_palette(np.array([0.10 + 0.55 * (z0 + 0.9) / 1.8]))[0]
        img += edge[..., None] * col * (0.70 + 0.30 * shade)
        img += alive[..., None] * col * 0.015
    p99 = np.percentile(img, 99.7) + 1e-9
    img = np.clip(img / p99, 0, 1)
    # cheap 2-pass box blur for a soft volumetric bloom
    glow = img.copy()
    for _ in range(2):
        glow = 0.25 * (np.roll(glow, 1, 0) + np.roll(glow, -1, 0)
                       + np.roll(glow, 1, 1) + np.roll(glow, -1, 1))
    img = np.clip(img * 0.85 + glow * 0.45, 0, 1) ** 0.95
    return to_srgb(img)


def mandelbrot_baseline(iters=220, lo=-2.15, hi=0.85):
    x, y = grid(lo, hi)
    zx, zy = np.zeros_like(x), np.zeros_like(y)
    acc = np.zeros_like(x)
    alive = np.ones_like(x, dtype=bool)
    for i in range(iters):
        n = zx * zx + zy * zy
        esc = alive & (n > 256.0)
        if esc.any():
            acc[esc] = i + 1 - np.log2(0.5 * np.log2(np.maximum(n[esc], 4.0)))
            alive &= ~esc
        with np.errstate(over="ignore", invalid="ignore"):
            zx, zy = zx * zx - zy * zy + x, 2 * zx * zy + y
        zx = np.where(alive, zx, 0.0)
        zy = np.where(alive, zy, 0.0)
        if not alive.any():
            break
    acc[alive] = iters
    t = np.clip(acc / iters, 0, 1) ** 0.40
    rgb = ramp(0.10 + 0.85 * t)
    rgb = np.where(alive[..., None], np.array([0.01, 0.01, 0.02]), rgb)
    return to_srgb(rgb)


CANDIDATES = {
    "kaliset_inversion": kaliset,
    "chladni_nodal_fractal": chladni,
    "domain_warp_nebula": warp_nebula,
    "brimordial_slice_stack": brimordial_stack,
    "baseline_mandelbrot": mandelbrot_baseline,
}


def main():
    os.makedirs(OUT, exist_ok=True)
    results = {}
    for name, fn in CANDIDATES.items():
        rgb = np.clip(fn(), 0, 1)
        Image.fromarray((rgb * 255).astype(np.uint8)).save(os.path.join(OUT, f"{name}.png"))
        results[name] = metrics(rgb)
        print(f"{name:26s} {results[name]}")
    with open(os.path.join(OUT, "metrics.json"), "w") as fh:
        json.dump(results, fh, indent=2, sort_keys=True)
        fh.write("\n")


if __name__ == "__main__":
    main()
