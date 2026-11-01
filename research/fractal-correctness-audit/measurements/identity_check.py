#!/usr/bin/env python3
"""Algebraic identity checks for the repaired shader formulas.

1. Schroeder degree family: the shipped step
       z_k - z_k (z_k^n - 1) / (z_k^n + n - 1)
   must equal the first-kind Schroeder step
       z - f f' / (f'^2 - f f'')      for f(z) = z^n - 1.
   The pre-repair z5/z6 files shipped the Halley step instead; its distance from
   the first-kind step is recorded so the size of the defect is auditable.

2. Klein j invariant: j(i) = 1728 exactly (DLMF 23.15, j = 1728 E4^3 / Delta).
   The truncated q-series used by the shader is evaluated at tau = i.

3. Jarratt correction weights: the shipped correction must equal
       (3 f'(y) + f'(z)) / (6 f'(y) - 2 f'(z)).
"""

import cmath
import json
import math
import os
import random

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "identity_check.json")


def f_n(z, n):
    return z ** n - 1.0


def fp_n(z, n):
    return n * z ** (n - 1)


def fpp_n(z, n):
    return n * (n - 1) * z ** (n - 2)


def schroeder_first_kind_step(z, n):
    fz, fpz, fppz = f_n(z, n), fp_n(z, n), fpp_n(z, n)
    return fz * fpz / (fpz ** 2 - fz * fppz)


def simple_denominator_step(z, n):
    """z(z^n-1)/(z^n + n-1): what schweder_z3..z6 now ship."""
    return z * (z ** n - 1.0) / (z ** n + (n - 1))


def halley_step(z, n):
    """What schroeder_z5 and schroeder_z6 shipped before the repair."""
    fz, fpz, fppz = f_n(z, n), fp_n(z, n), fpp_n(z, n)
    return 2.0 * fz * fpz / (2.0 * fpz ** 2 - fz * fppz)


def klein_j(tau, terms=24):
    q = cmath.exp(2j * math.pi * tau)

    def sigma3(n):
        return sum(d ** 3 for d in range(1, n + 1) if n % d == 0)

    e4 = 1.0 + 240.0 * sum(sigma3(n) * q ** n for n in range(1, terms + 1))
    delta = q
    for n in range(1, terms + 1):
        delta *= (1.0 - q ** n) ** 24
    # Delta = (E4^3 - E6^2)/1728, so j = 1728 E4^3/(E4^3-E6^2) = E4^3/Delta.
    return e4 ** 3 / delta


def jarratt_shipped_correction(z):
    y = z - (2.0 / 3.0) * (z ** 3 - 1.0) / (3.0 * z * z)
    fpy, fpz = 3.0 * y * y, 3.0 * z * z
    return (3.0 * fpy + fpz) / (6.0 * fpy - 2.0 * fpz)


def main():
    random.seed(7)
    probes = [complex(random.uniform(-1.4, 1.4), random.uniform(-1.4, 1.4))
              for _ in range(500)]

    first_kind = {}
    halley_gap = {}
    for n in (3, 4, 5, 6):
        first_kind[n] = max(abs(simple_denominator_step(z, n) - schroeder_first_kind_step(z, n))
                            for z in probes if abs(f_n(z, n)) > 1e-9)
        halley_gap[n] = max(abs(halley_step(z, n) - schroeder_first_kind_step(z, n))
                            for z in probes if abs(f_n(z, n)) > 1e-9)

    j_at_i = klein_j(1j)
    j_at_i_minus_1728 = klein_j(1j, terms=64) - 1728.0

    corr = max(abs(jarratt_shipped_correction(z) - (3.0 * (3.0 * (z - (2.0 / 3.0) * (z ** 3 - 1.0) / (3.0 * z * z)) ** 2) + 3.0 * z * z) / (6.0 * (3.0 * (z - (2.0 / 3.0) * (z ** 3 - 1.0) / (3.0 * z * z)) ** 2) - 2.0 * 3.0 * z * z))
               for z in probes)

    data = {
        "schroeder_degree_family": {
            "max_abs_diff_simple_vs_first_kind": {str(n): float(f"{v:.3e}") for n, v in first_kind.items()},
            "max_abs_diff_halley_vs_first_kind": {str(n): float(f"{v:.3e}") for n, v in halley_gap.items()},
        },
        "klein_j": {
            "j_at_tau_i_terms24": {"re": j_at_i.real, "im": j_at_i.imag},
            "abs_j_minus_1728_terms64": abs(j_at_i_minus_1728),
        },
        "jarratt": {
            "max_abs_diff_shipped_correction_vs_published": corr,
        },
    }
    with open(OUT, "w") as fh:
        json.dump(data, fh, indent=2, sort_keys=True)
        fh.write("\n")
    print(json.dumps(data, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
