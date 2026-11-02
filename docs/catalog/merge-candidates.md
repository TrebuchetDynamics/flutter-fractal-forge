# Power-variant families that can merge behind one parameter

Status: `mandelbar` and `multibrot` merged (see below). The rest is inventory only.
Method: strip comments, diff each pair, and confirm the only differences are the
exponent, the derivative coefficient, and the smooth-colouring `log2(power)`.
Every claim below is reproducible with `diff` on the named files.

## The pattern already in the repo

Two shaders already do what this document proposes:

| Shader | Extra uniform | Catalog param |
| --- | --- | --- |
| `tricorn/parameter_plane/tricorn_gpu.frag` | `uPower` (slot 10) | `power`, default 2.0 |
| `multibrot/integer_powers/multibrot3_gpu.frag` | `uPower` | `power`, default 3.0 |

Both compute `cpowReal(z, power)` and scale the derivative by `power`, so one
shader covers every integer and fractional power. Their sibling files are the
same map with the exponent hardcoded.

## Candidates, highest payoff first

"Redundant" counts shader files whose only difference from the family's
parameterised form is the exponent.

| Family | Redundant shaders | Merge target | Fold convention | Payoff |
| --- | --- | --- | --- | --- |
| `mandelbar` | 5 (`cubic`, `power6..9`) | `tricorn_gpu.frag` (exists) | conjugate | 5 → 0 new files |
| `multibrot` | ~~11~~ **merged** | `multibrot3_gpu.frag` (exists) | none | 11 files deleted |
| `tricorn` plane | 3 (`cubic`, `power4`, `power5`) | `tricorn_gpu.frag` (exists) | conjugate | 3 → 0 new files |
| `tricorn` julia | 6 (`cubic`, `power4..8`) | new parameterised julia | conjugate | 6 → 1 |
| `celtic` plane | 5 (`cubic`, `power4..7`) | new `celtic_power_gpu.frag` | `abs(z.x)` | 5 → 1 |
| `celtic` julia | 4 (`cubic`, `power4..6`) | new parameterised julia | `abs(z.x)` | 4 → 1 |
| `buffalo` plane | 5 (`cubic`, `power4..7`) | new `buffalo_power_gpu.frag` | `abs(z.x)`, `abs(z.y)` | 5 → 1 |
| `buffalo` julia | 4 (`cubic`, `power4..6`) | new parameterised julia | `abs(z.x)`, `abs(z.y)` | 4 → 1 |

`multibrot_neg2` stays separate: it is a rational map (`z^-2 + c`), not a power
variant.

Naming hazard for the `multibrot` merge: the ids do not encode the power
unambiguously. `multibrot_15` is *d = 1.5* and `multibrot_25` is *d = 2.5*; the
display names are correct, the ids read like 15 and 25. Set the merged `power`
default from the shader, not from the id. `celtic_heart`, `celtic_mandelbar`, `perp_celtic`, `perp_buffalo`,
`buffalo2` and `perpendicular_gpu` are different maps, not power variants.

## Merged: `mandelbar` → `tricorn_gpu.frag`

Done. The five entries (`mandelbar_cubic`, `mandelbar_power6..9`) now point at
`tricorn_gpu.frag` and carry a `power` parameter (3, 6, 7, 8, 9). The five
shader files are deleted. Two fixes were needed in the shared shader first:

- the derivative now conjugates the incoming value
  (`der = p * zc^(p-1) * conj(der) + 1`), which is the anti-holomorphic chain
  rule. This changes bas-relief shading only (colorScheme >= 50).
- the smooth-colouring divisor is now `log2(max(power, 1.0001))`. At power 2
  this is a division by 1, so Tricorn is unchanged; at 6..9 it removes the
  banding the un-divided form produced.

`test/modules/mandelbar_merge_test.dart` compares the merged shader against a
CPU mirror of `z -> conj(z)^p + c` for all five powers and requires >97% pixel
agreement, so the parameter is proven to drive the map.

## Merged: `multibrot` → `multibrot3_gpu.frag`

Done. The eleven entries (`multibrot4..12`, `multibrot_15`, `multibrot_25`) now
point at the parameterised shader that the shared Multibrot catalog already used,
and each carries a `power` parameter (4–12, 1.5, 2.5). Eleven shader files are
deleted. No new shader was needed: the shared catalog already pointed about
thirty entries at that file.

The merge found a real defect. `cpowReal` computed `atan(0, 0)`, which is
undefined, and every parameter-plane orbit starts at `z = 0`. On this software
rasterizer that returned NaN and poisoned the orbit, so **every** entry using the
shared shader rendered one flat colour. The old per-power shaders used unrolled
multiplies and were not affected. The shader now returns early at the exact
origin, the same guard `tricorn_gpu.frag` already had. After the fix the entries
render 100–198 distinct colours instead of 1.

`test/modules/multibrot_merge_test.dart` pins the result: each integer-power
entry must render more than twenty distinct colours at its own power, and must
differ from the same entry at the next power. The fractional entries must be
deterministic and distinct.

Open item: the `z^p + c` parameter plane should be `(p-1)`-fold symmetric, but a
rotation sweep on `multibrot4` matched a quarter turn better than a third turn.
The measurement and the algebra disagree, so no symmetry test was shipped. This
needs a separate look before any symmetry claim is made.

## Finding 1: `mandelbar` is already `tricorn`

`tricorn_gpu.frag` iterates `z = cpowReal(conj(z), power) + c`. That is the
definition of the Mandelbar family. `mandelbar_cubic` and `mandelbar_power6..9`
are that same map with `power` hardcoded to 3, 6, 7, 8 and 9. Repointing those
five catalog entries at `tricorn_gpu.frag` with `power` set deletes five shader
files and adds no new mathematics.

One caveat, see Finding 3.

## Finding 2: the perpendicular sub-family is inconsistent

The "perpendicular burning ship" entries do not fold the same axis:

| Shader | Fold |
| --- | --- |
| `perpendicular_burning_ship_gpu.frag` (p=2) | `abs(z.x)` |
| `perpendicular_bs_cubic_gpu.frag` (p=3) | `abs(z.x)` |
| `perpendicular_bs_power4_gpu.frag` (p=4) | `abs(z.y)` |
| `perpendicular_bs_power5_gpu.frag` (p=5) | `abs(z.y)` |

The same split exists in the celtic pair: `perp_celtic_gpu.frag` folds `x`,
`perp_celtic_cubic_gpu.frag` folds `y`.

These are mirror-image maps, not power variants. They cannot be merged until one
convention is chosen, and whichever entry does not match that convention is a
defect rather than a variant. This is the one candidate that must not be merged
blindly.

## Finding 3: the two Mandelbar derivatives disagree

The set is the same; the normal-map shading is not.

- `mandelbar_power*.frag`: `der = p * conj(z)^(p-1) * conj(der) + 1`
- `tricorn_gpu.frag`: `der = p * conj(z)^(p-1) * der + 1`

For an anti-holomorphic map the chain rule conjugates the incoming derivative,
so the Mandelbar form is the correct one. Merging Mandelbar into `tricorn_gpu`
therefore changes Tricorn's bas-relief shading unless the derivative is fixed
first. Fixing it is a one-line change, but it is a visible change to an existing
entry, so it needs its own decision.

## Falsifiable check for every merge

Rotational symmetry, not a golden image:

1. Render the parameter plane at integer power `p` with a fixed framing.
2. Rotate the image by `2*pi/(p-1)` about the centre and compare. The set is
   `(p-1)`-fold symmetric, so the match must be near-exact.
3. Rotate by a different angle and confirm the images differ.

That proves the parameter drives the map rather than the palette. A golden
comparison against the retired shader at its original power is a useful second
check, but it must be captured before the file is deleted.

## Ripple to expect per merge

Every merged family touches more than its shader:

- catalog builder that declares the entry (`shaderAsset` plus the new `power` param)
- `pubspec.yaml` shader list
- `test/fixtures/animation_capability_inventory.json`
- `docs/planning/visual-audit-inventory.json` shader paths
- `lib/features/renderer/cpu/formulas/cpu_formulas.dart` for families with a CPU mirror
- `test/shaders/power_shader_regression_test.dart` and
  `test/shaders/smooth_coloring_family_coverage_test.dart`
- `docs/qa/**` historical manifests are records of past runs and must not be edited

## Recommended order

1. ~~`mandelbar` → `tricorn_gpu.frag`~~ done.
2. ~~`multibrot` → one new shader~~ done.
3. `tricorn` plane and julia → existing and new parameterised shaders.
4. `celtic`, then `buffalo`, plane before julia.
5. `perpendicular`: settle the fold convention first, then merge.
