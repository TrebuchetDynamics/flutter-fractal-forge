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

---

## Second pass — four more families

Same method, applied wider. New harness: `measurements/slice_de.py` →
`slice_de.json`. New regression file: `test/modules/family_degree_consistency_test.dart`.

| Family | Shaders | Check | Result |
| --- | --- | --- | --- |
| Escape-time power families (`burning_ship`, `tricorn`, `celtic`, `buffalo`, `perpendicular`, `mandelbar`, `multibrot`, plus Julia variants) | 47 | Map, derivative constant and smooth-colouring normalisation must name the same degree | **0 defects.** All 47 agree. Two ids look wrong and are not: `multibrot_15` / `multibrot_25` are `d = 1.5` / `d = 2.5`, and their display names say so |
| Degree plumbing across the whole shader tree | 65 shaders that carry both a `der = K *` constant and a `log2(K)` normalisation | Constants must agree | **0 disagreements** |
| 3D slice-brots (`tetrabrot`, `arrowheadbrot`, `mousebrot`, `turtlebrot`, `hourglassbrot`) | 5 | Characterise the slice combination `sqrt(Σdᵢ²/k)` against the union bound `min(dᵢ)` and the intersection bound `max(dᵢ)` over 16,335 samples each | **Not a defect.** The shipped form never exceeds `max(dᵢ)` (worst excess `≤ 0`), so sphere tracing cannot skip geometry. It exceeds the union bound by at most 0.71–1.02, which means the shape is the slice **intersection**, not a union. Recorded because the shaders do not state which combination they implement |
| Perpendicular and Celtic folds | 9 | Fold axis and order must match the names | **0 defects.** `perpendicular` folds `Re(z²)`; `perpendicular_burning_ship` folds `Re(z)` before squaring and leaves `Im` alone (distinct from Burning Ship) |
| Number-theory special functions (`dedekind_eta`, `jacobi_theta`, `eisenstein_series`) | 3 | q-expansion terms against the standard definitions | **0 defects** (see first pass) |

### What "0 defects" means here

It means the shipped code matches the named formula under a check that can fail:
a degree mismatch, a derivative constant that disagrees with the colouring, or a
slice combination that oversteps the surface. The root-finding pass proved the
method finds real defects (2 of 41). These families passed the same kind of
check, so the earlier finding is a family property, not a general one.

### Where the remaining risk is

The audit has now covered, with falsifiable checks, the families that have a
published definition: root finding (41), power families (47), 3D slice-brots (5),
special functions (3), plus a 65-shader degree sweep. That is roughly 160 of the
582 shaders.

The uncovered shaders are mostly the ones with **no published definition to
compare against**: `experimental_named` art formulas (~20 hand-tuned maps), the
cellular/stochastic family, and the strange-attractor renders (where the check
would be "does the orbit match the stated ODE", not a convergence order). Those
need a different oracle — a stated source per formula — before a pass/fail check
means anything. Reporting them as "unaudited" is more honest than calling them
wrong.

---

## Third pass — two open items closed with primary sources

The owner supplied a reference corpus of 128 upstream projects
(`opensource/repos/`, gitignored). Two items from the first pass are now closed.

### `neta_order16` — the 16th-order claim was false, and is now true by construction

The old iteration composed three invented correction steps and measured order
**5.86** while claiming 16. No "Neta" scheme exists in the 13,556 formula
definitions of `fract4d-formulas`, so the attribution could not be verified.

The entry now composes **two Ostrowski steps**. One Ostrowski step measures 4.06,
and applying a method of order `p` at the new point raises the order to `p^2`, so
the pair is order 16 by construction. A double-precision check sees about 13
because the second step lands on the rounding floor; the test asserts what the
arithmetic can show (pair estimate > 10, single step < 5) and the shader pins the
composition.

Display name changed to **Ostrowski Squared (Order 16)**. The id `neta_order16`
stays so presets and links keep working.

### `schroeder` — family is now internally consistent

The base entry computed `z - f/f' - f^2 f''/(2 f'^3)`, which is Chebyshev's method
(Schröder second kind) and was byte-identical to `chebyshev_fractal`. The degree
variants `z3..z6` use the first-kind step. The base now uses the first kind too:

```
step = f f' / (f'^2 - f f'') = z(z^3-1)/(z^3+2)
```

The identity is pinned in `test/modules/mix_family_test.dart` to `1e-9`. Chebyshev
stays a separate, distinct map.

### New family from the corpus

`mandelbrot_mix` (ten entries, one shader) implements the MandelbrotMix mapping
from `fract4d-formulas` (MIT, commit `2b3e04b`). The degenerate parameters
reproduce `z^2 + c` exactly, which is the falsifiable check required by the
corpus workflow. Provenance: `opensource/docs/mandelbrot-mix-source.md`.

**Ledger correction:** the second-pass report listed `neta_order16` and the base
`schroeder` as open. Both are closed here. The "0 defects" rows for the power and
slice families are unaffected.
