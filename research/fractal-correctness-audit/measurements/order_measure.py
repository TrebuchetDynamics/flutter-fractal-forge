#!/usr/bin/env python3
"""Measure the empirical order of convergence of shipped root-finding rules.

Each rule is transcribed from its GLSL shader (the shipped form), and where the
shipped coefficients differ from the published method, both forms are measured.
The test function is f(z) = z^3 - 1, the function every shipped root_finding
shader uses.

Order estimate: p_n = log(e_{n+1}) / log(e_n), where e_n is the distance to the
nearest cube root of unity. The median over the last convergent iterations is
reported. A rule with the advertised order must measure close to it; a rule
with wrong coefficients measures lower or diverges.

Outputs order_measure.json next to this file.
"""

import cmath
import json
import math
import os
import random
import statistics


def f(z):
    return z ** 3 - 1.0


def fp(z):
    return 3.0 * z * z


def fpp(z):
    return 6.0 * z


# ------------------------------------------------------------------ rules ----
def newton(z):
    return z - f(z) / fp(z)


def halley(z):
    return z - 2.0 * f(z) * fp(z) / (2.0 * fp(z) ** 2 - f(z) * fpp(z))


def chebyshev(z):
    return z - f(z) / fp(z) - f(z) ** 2 * fpp(z) / (2.0 * fp(z) ** 3)


def schroeder_first_kind(z):
    return z - f(z) * fp(z) / (fp(z) ** 2 - f(z) * fpp(z))


def schroeder_shipped(z):
    # schroeder_gpu.frag line 84-88: z - [f/f' + f^2 f''/(2 f'^3)]  == Chebyshev
    return chebyshev(z)


def jarratt_shipped(z):
    # jarratt_gpu.frag: corr = (3 f'(y) - f'(z)) / (2 (3 f'(y) - 2 f'(z)))
    y = z - (2.0 / 3.0) * f(z) / fp(z)
    corr = (3.0 * fp(y) - fp(z)) / (2.0 * (3.0 * fp(y) - 2.0 * fp(z)))
    return z - corr * f(z) / fp(z)


def jarratt_published(z):
    # Jarratt (1966) form: corr = (3 f'(y) + f'(z)) / (6 f'(y) - 2 f'(z))
    y = z - (2.0 / 3.0) * f(z) / fp(z)
    corr = (3.0 * fp(y) + fp(z)) / (6.0 * fp(y) - 2.0 * fp(z))
    return z - corr * f(z) / fp(z)


def ostrowski(z):
    y = z - f(z) / fp(z)
    return y - (f(y) / fp(z)) * (f(z) / (f(z) - 2.0 * f(y)))


def steffensen(z):
    fz = f(z)
    return z - fz * fz / (f(z + fz) - fz)


def super_halley(z):
    L = f(z) * fpp(z) / fp(z) ** 2
    return z - (f(z) / fp(z)) * ((2.0 - L) / (2.0 * (1.0 - L)))


def traub_ostrowski(alpha):
    def rule(z):
        y = z - f(z) / fp(z)
        return y - (f(y) / fp(z)) * ((f(z) + alpha * f(y)) / (f(z) + (alpha - 2.0) * f(y)))

    return rule


def neta16_shipped(z):
    # neta_order16_gpu.frag: Newton, then three Ostrowski-style corrections
    fz, fpz = f(z), fp(z)
    y1 = z - fz / fpz
    fy1 = f(y1)
    y2 = y1 - (fy1 / fpz) * (fz / (fz - 2.0 * fy1))
    fy2 = f(y2)
    y3 = y2 - (fy2 / fpz) * ((fy1 / (fy1 - 2.0 * fy2)) * (fz / (fz - 2.0 * fy1)))
    fy3 = f(y3)
    return y3 - (fy3 / fpz) * ((f(y3) / fy3) * (fy3 / (fy3 - 2.0 * f(y3))))


RULES = {
    "newton": (newton, 2),
    "halley": (halley, 3),
    "chebyshev": (chebyshev, 3),
    "super_halley": (super_halley, 3),
    "schroeder_first_kind": (schroeder_first_kind, 3),
    "schroeder_base_shipped (claims Schroeder)": (schroeder_shipped, 3),
    "jarratt_pre_repair (claimed 4)": (jarratt_shipped, 4),
    "jarratt_shipped_after_repair": (jarratt_published, 4),
    "ostrowski": (ostrowski, 4),
    "steffensen": (steffensen, 2),
    "traub_ostrowski a=0": (traub_ostrowski(0.0), 4),
    "traub_ostrowski a=1": (traub_ostrowski(1.0), 4),
    "neta16_shipped (claims 16)": (neta16_shipped, 16),
}

ROOTS = [cmath.exp(2j * math.pi * k / 3) for k in range(3)]


def measure(rule, z0, iters=24):
    z = z0
    errs = []
    for _ in range(iters):
        try:
            zn = rule(z)
        except (ZeroDivisionError, OverflowError):
            return None
        if not (math.isfinite(zn.real) and math.isfinite(zn.imag)):
            return None
        root = min(ROOTS, key=lambda r: abs(zn - r))
        e = abs(zn - root)
        errs.append(e)
        z = zn
        if e < 1e-15:
            break
    if len(errs) < 4 or errs[-1] > 1e-6:
        return None
    orders = []
    for a, b in zip(errs[-4:-1], errs[-3:]):
        if a > 1e-14 and b > 0.0 and a > 0.0:
            orders.append(math.log(b) / math.log(a))
    if not orders:
        return None
    return statistics.median(orders)


def main():
    random.seed(20261031)
    starts = [complex(random.uniform(-1.5, 1.5), random.uniform(-1.5, 1.5))
              for _ in range(300)]
    starts += [complex(-0.4, 0.9), complex(0.2, -0.7), complex(1.4, 0.3)]

    out = {}
    for name, (rule, claimed) in RULES.items():
        measured = [p for p in (measure(rule, s) for s in starts) if p is not None]
        out[name] = {
            "claimed_order": claimed,
            "converged": len(measured),
            "of_starts": len(starts),
            "median_measured_order": round(statistics.median(measured), 3) if measured else None,
            "p10": round(sorted(measured)[len(measured) // 10], 3) if measured else None,
            "p90": round(sorted(measured)[len(measured) * 9 // 10], 3) if measured else None,
        }

    # Map identity: does the shipped Schroeder agree with Halley or Chebyshev?
    same_as_cheb = same_as_halley = 0
    probe = [complex(random.uniform(-1.2, 1.2), random.uniform(-1.2, 1.2)) for _ in range(200)]
    for z in probe:
        a = schroeder_shipped(z)
        if abs(a - chebyshev(z)) < 1e-12:
            same_as_cheb += 1
        if abs(a - halley(z)) < 1e-12:
            same_as_halley += 1
    out["_map_identity"] = {
        "schroeder_shipped == chebyshev": f"{same_as_cheb}/{len(probe)}",
        "schroeder_shipped == halley": f"{same_as_halley}/{len(probe)}",
    }

    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "order_measure.json")
    with open(path, "w") as fh:
        json.dump(out, fh, indent=2, sort_keys=True)
        fh.write("\n")
    for name in RULES:
        r = out[name]
        print(f"{name:38s} claimed={r['claimed_order']:2d} measured={r['median_measured_order']} "
              f"converged={r['converged']}/{r['of_starts']}")
    print(out["_map_identity"])


if __name__ == "__main__":
    main()
