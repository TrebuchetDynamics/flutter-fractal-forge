#!/usr/bin/env python3
"""Characterise the slice-combination distance estimate of the 3D slice-brot family.

`tetrabrot_3d`, `arrowheadbrot_3d`, `mousebrot_3d`, `turtlebrot_3d` and
`hourglassbrot_3d` each evaluate the complex Mandelbrot distance estimate on
several affine slices of the point and combine the results with an RMS average:

    d_shipped = sqrt( (d_0^2 + ... + d_k^2) / k )

The audit question is whether that is a valid sphere-tracing bound. For a union
of slices the exact bound is min(d_i); for their intersection it is max(d_i).
A bound is safe when it never exceeds the true distance.

We test both relations on a grid and report the worst violation, the worst
overshoot past the union bound, and whether the shipped combination ever exceeds
the max bound (which would make the marcher skip the surface).
"""

import json
import math
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "slice_de.json")


def cmul(a, b):
    return (a[0] * b[0] - a[1] * b[1], a[0] * b[1] + a[1] * b[0])


def mandelbrot_de(c, max_iter=32, bailout=4.0):
    """Same recurrence as complexMandelbrotDistance in the shipped shaders."""
    z = (0.0, 0.0)
    der = (0.0, 0.0)
    limit2 = max(bailout, 2.0) ** 2
    for _ in range(max_iter):
        der = (2.0 * cmul(z, der)[0] + 1.0, 2.0 * cmul(z, der)[1])
        z = (cmul(z, z)[0] + c[0], cmul(z, z)[1] + c[1])
        if z[0] * z[0] + z[1] * z[1] > limit2:
            r = max(math.hypot(*z), 1e-8)
            return max(0.0, 0.5 * r * math.log(r) / max(math.hypot(*der), 1e-8))
    return 0.0


SLICES = {
    "tetrabrot": lambda p: [(p[0], p[1] - p[2]), (p[0], p[1] + p[2])],
    "arrowheadbrot": lambda p: [(p[0] - p[2], p[1]), (p[0] + p[2], p[1])],
    "mousebrot": lambda p: [(p[2], p[0] - p[1]), (-p[2], p[0] + p[1])],
    "turtlebrot": lambda p: [
        (-p[2], p[0] - p[1]), (p[2], p[0] + p[1]),
        (p[2], p[0] - p[1]), (-p[2], p[0] + p[1]),
    ],
    "hourglassbrot": lambda p: [
        (p[1] - p[2], p[0]), (-p[1] + p[2], p[0]),
        (p[1] + p[2], p[0]), (-p[1] - p[2], p[0]),
    ],
}


def main():
    report = {}
    for name, slices in SLICES.items():
        worst_over_union = 0.0
        worst_over_max = -1e9
        nonzero = 0
        total = 0
        for i in range(-11, 12):
            for j in range(-11, 12):
                for k in range(-11, 12):
                    p = (i / 10.0, j / 10.0, k / 10.0)
                    ds = [mandelbrot_de(c) for c in slices(p)]
                    shipped = math.sqrt(sum(d * d for d in ds) / len(ds))
                    union = min(ds)
                    inter = max(ds)
                    total += 1
                    if union > 1e-9:
                        nonzero += 1
                        worst_over_union = max(worst_over_union, shipped - union)
                    worst_over_max = max(worst_over_max, shipped - inter)
        report[name] = {
            "slices": len(slices(p=(0.0, 0.0, 0.0))),
            "samples": total,
            "samples_outside_union": nonzero,
            "max_shipped_minus_union_bound": worst_over_union,
            "max_shipped_minus_intersection_bound": worst_over_max,
            "exceeds_intersection_bound": worst_over_max > 1e-12,
        }
    with open(OUT, "w") as fh:
        json.dump(report, fh, indent=2, sort_keys=True)
        fh.write("\n")
    for k, v in report.items():
        print(f"{k:16s} bounds_ok={not v['exceeds_intersection_bound']} "
              f"max(shipped-union)={v['max_shipped_minus_union_bound']:.4f}")


if __name__ == "__main__":
    main()
