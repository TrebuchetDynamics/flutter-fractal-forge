# Power-variant families that can merge behind one parameter

Status: `mandelbar` merged (see below). The rest is inventory only.
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
| `multibrot` | 11 (`4,5,6,7,8,9,10,11,12,15,25`) | new `multibrot_power_gpu.frag` | none | 11 → 1 |
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
2. `multibrot` → one new shader. Largest single payoff, no fold convention to
   settle, but the widest fixture ripple.
3. `tricorn` plane and julia → existing and new parameterised shaders.
4. `celtic`, then `buffalo`, plane before julia.
5. `perpendicular`: settle the fold convention first, then merge.
