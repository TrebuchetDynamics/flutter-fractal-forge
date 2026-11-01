# Fractal correctness audit — root-finding family

Research pass and repair batch for the claim "many fractals are wrongly
implemented". Scope: the 41 shaders in `shaders/root_finding/`, where every
entry implements a named, published iteration on `f(z) = z³ − 1`. That makes
correctness measurable instead of a matter of taste: a named method has a
**known order of convergence**, and a wrong coefficient shows a lower order.

## Method

1. Transcribe the shipped recurrence from each shader.
2. Measure its empirical order `p_n = log(e_{n+1}) / log(e_n)` against the
   nearest root of unity, over 303 starts, and take the median.
3. Compare with the claimed order. A method that claims order 4 and measures 2
   has wrong coefficients; there is no interpretive room.
4. Separately check algebraic identities where the shader uses a closed-form
   simplification (Schröder/Halley degree formulas, Klein `j` at `τ = i`).

Measurement harness: `measurements/order_measure.py` →
`measurements/order_measure.json`. Identity harness:
`measurements/identity_check.py` → `measurements/identity_check.json`.

## Measured orders

| Rule | Claimed | Measured (median) |
| --- | --- | --- |
| Newton | 2 | 2.00 |
| Halley | 3 | 3.07 |
| Chebyshev | 3 | 2.86 |
| Super-Halley | 3 | 3.21 |
| Ostrowski | 4 | 4.06 |
| Traub–Ostrowski (`α = 0`) | 4 | 4.06 |
| Steffensen | 2 | 1.87 |
| Jarratt, **as shipped before this batch** | 4 | **2.00** |
| Jarratt, published weights | 4 | 4.06 |
| `neta_order16`, as shipped | 16 | **5.86** |

Order estimates at the floating-point floor scatter by about ±0.2 (see Halley
3.07 and Chebyshev 2.86, both genuinely order 3). The Jarratt and Neta gaps are
far outside that band.

## Defects found and repaired

### 1. `jarratt` used weights that are not Jarratt's method

The shipped correction was `(3f'(y) − f'(z)) / (2(3f'(y) − 2f'(z)))`, which
measures **second order** — the same as Newton. Jarratt's two-point method uses

```
y    = z − (2/3)·f(z)/f'(z)
z'   = z − [f/f'] · (3f'(y) + f'(z)) / (6f'(y) − 2f'(z))
```

Repaired to the published weights; the same harness now measures 4.06. The
shader header previously carried six mutually contradictory candidate formulas
(five commented guesses, one ending in "nah"), which is the trace of the
original uncertainty. It now states the method once.

Test witness: the regression test keeps both weight sets and asserts that the
removed set still measures below 2.5.

### 2. `schroeder_z5` and `schroeder_z6` implemented Halley, not the family's method

The degree family is inconsistent. Measured against the closed forms:

| Entry | Denominator in source | Method |
| --- | --- | --- |
| `schroeder_z3` | `z³ + 2` | Schröder first kind, `z(zⁿ−1)/(zⁿ+n−1)` |
| `schroeder_z4` | `z⁴ + 3` | Schröder first kind |
| `schroeder_z5` | `3z⁵ + 2` | **Halley**, `2z(zⁿ−1)/((n+1)zⁿ+(n−1))` |
| `schroeder_z6` | `7z⁶ + 5` | **Halley** |

Two of four degree variants rendered a different fractal from the other two
while claiming the same method. The Halley step differs from the first-kind step
by up to 37 in absolute value on the probe set, so this was a visibly different
map, not a rounding difference.

Repaired `z5` and `z6` to the first-kind closed form shared with `z3`/`z4`.
Identity check after the repair: closed form equals `f f'/(f'² − f f'')` to
`9e-14` for `n = 3..6`.

## Verified correct (no change)

| Entry | Evidence |
| --- | --- |
| `newton`, `halley`, `chebyshev`, `super_halley` | measured order matches claim |
| `ostrowski`, `traub_ostrowski` | measured order ≈ 4.06 |
| `steffensen` | measured 1.87 ≈ 2 |
| `klein_j_invariant` | `j(τ) = E₄³/Δ` satisfies `j(i) = 1728` to `4.5e-12`; `Δ` already carries the `1/1728` of `E₄³ − E₆²`, so multiplying by 1728 again would break the identity |
| `dedekind_eta_field`, `jacobi_theta_field`, `eisenstein_series_field` | series in the shader matches the standard q-expansions term for term (η product, θ₂/θ₃/θ₄ with the `(n+½)²` and `(−1)ⁿ` weights, `E₄ = 1 + 240Σσ₃qⁿ`, `E₆ = 1 − 504Σσ₅qⁿ`) |

The Klein row is worth recording because it nearly became a defect in the other
direction: the audit's first hypothesis was "missing 1728 factor", the numeric
identity refuted it, and the shader was left unchanged.

## Open items (not changed)

| Item | Finding | Why it is open |
| --- | --- | --- |
| `neta_order16` | Four-step composition measures **5.86**, not 16 | Replacing it means either implementing Neta's actual 16th-order scheme or relabelling a catalog identity. Both are product decisions, and the paper was not obtained. Recorded here as a bounded follow-up instead of guessing coefficients |
| `schroeder` (base) vs `schroeder_z3…z6` | Base computes `z − f/f' − f²f''/(2f'³)`, which is Chebyshev's method (= Schröder second kind); the degree variants now compute first kind | Sources use the Schröder name for both kinds. Choosing the catalog's canonical Schröder is an owner naming decision; the degree family is at least internally consistent after this batch |
| `schroeder` vs `chebyshev_fractal` | Bit-identical maps (`200/200` probes agree to `1e-12`) | Duplicate identity across entries. Removing or renaming an entry is a product decision |

## Limits

- **Search depth `standard`, 7 query variants, 4 sources attempted, 28/50
  requests used, `stop_reason: completed`, 199 unique deduplicated records,
  `consecutive_low_yield = 0`.** The sweep is bounded, not saturated.
- **4 failures**: Semantic Scholar returned HTTP 429 on four queries. Its
  contribution to this sweep is zero.
- **No full text.** No PDFs were fetched and no acquisition gate was requested.
  Bibliographic anchors are used to identify methods, not to attribute claims
  read out of a paper. The two repaired formulas are established by *local
  numerical measurement* (order and identity), which does not depend on a
  citation.
- **Only `f(z) = z³ − 1`** was measured, the same function the shaders use.
  Behaviour on other polynomials (including multiple roots) is untested.
- **Software rasterization only.** The repaired shaders compile and draw in
  `flutter test`; no hardware GPU, device or browser qualification is claimed.
- Naming conventions for the Chebyshev–Halley–Schröder family vary between
  sources, which is why the naming questions above are left to the owner
  instead of resolved unilaterally.

## Evidence index

| Path | Contents |
| --- | --- |
| `measurements/order_measure.py` / `.json` | Claims vs measured convergence orders, including the pre-repair Jarratt weights |
| `measurements/identity_check.py` / `.json` | Schröder closed-form identity, Halley-vs-first-kind distance, Klein `j(i)` |
| `results-deduped.jsonl`, `manifest.json`, `failures.jsonl`, `search-stats.txt` | rforge sweep artifacts (199 records, caps, stop reason, failures) |
| `provenance.json` | Schema-v2 index, validated by `rforge provenance validate` |
| `test/modules/root_finding_formula_test.dart` | Formula pins: weights, orders, identities, shader compile and render |

## Verification run for the repair

`flutter test test/modules/root_finding_formula_test.dart` → 11 passing cases,
including the shader compile/render check for the three edited shaders. The full
offline gate for the repository is recorded in the task report, not here.
