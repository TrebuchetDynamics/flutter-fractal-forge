# Mousebrot 3D follow-up and complete catalog re-audit

## Concrete objective

1. Continue beyond the completed Tetrabrot and Arrowheadbrot work with another researched 3D identity.
2. Derive the new formula from exact published basis/algebra evidence rather than visual resemblance.
3. Reject aliases, powers, presets, camera views, and fixed parameters as separate identities.
4. Prove membership differs from existing principal slices with independent CPU checks.
5. Re-audit the exact catalog, shader integration, counts, ledger, rendered output, analyzer, and full test suite.

## Research artifact

Package: `research/3d-mousebrot-2026-07-29/`

This package performs focused evidence extraction from the checksum-locked comprehensive corpus at `research/3d-principal-tricomplex-slices-2026-07-29/` instead of repeating live retrieval:

- inherited queries: 27
- inherited sources: OpenAlex, arXiv, Crossref
- inherited saved records: 475
- inherited unique DOIs: 174
- inherited citation expansion: 3 seeds, 37 edges
- new live searches: 0
- accepted identity: classical quadratic Mousebrot

Vallières and Rochon name Mousebrot as Figure 3(c); that figure's caption identifies the basis `T(i₁,i₂,j₁)`. Brouillette and Rochon's general idempotent identity then yields, for `c=x i₁+y i₂+z j₁`, the ordinary complex parameters `z+(x-y)i` and `-z+(x+y)i`. Membership requires both component orbits to remain bounded.

Primary evidence:

- [Relationship between the Mandelbrot Algorithm and the Platonic Solids](https://arxiv.org/abs/2107.04016), DOI `10.3390/math10030482`.
- [Characterization of the Principal 3D Slices Related to the Multicomplex Mandelbrot Set](https://arxiv.org/abs/1809.02020), DOI `10.1007/s00006-019-0956-1`.
- [On a Bicomplex Distance Estimation for the Tetrabrot](https://doi.org/10.1142/S0218127405013873).

The follow-up also corrected a source-attribution typo in the preceding Arrowheadbrot report and audit summary: the 2022 Platonic-solids paper is by André Vallières and Dominic Rochon, not Brouillette and Rochon.

## Implementation artifacts

- Catalog ID/config: `mousebrot_3d` in `lib/core/modules/builders/raymarched_3d/catalog_impl.dart`
- Shader: `shaders/3d_and_hypercomplex/raymarched_volumes/mousebrot_3d_gpu.frag`
- Asset registration: `pubspec.yaml`
- CPU oracle: `lib/features/renderer/diagnostics/render_math_oracle.dart`
- Formula/runtime test: `test/modules/mousebrot_3d_test.dart`
- Exact catalog lock: `test/features/catalog/three_d_catalog_identity_test.dart`
- Promoted ledger: `research/worlds-largest-fractal-catalog/curated-entry-ledger.live-registry.json`

The module is fixed at quadratic degree two, hides the generic power control, and adds no presets or view-derived IDs.

## Identity and comparative-oracle evidence

The formulas are:

- Mousebrot: `z+(x-y)i`, `-z+(x+y)i`
- Arrowheadbrot: `(x-z)+yi`, `(x+z)+yi`
- Tetrabrot: `x+(y-z)i`, `x+(y+z)i`

The independent CPU oracle evaluates all three at each point:

1. `(0,0,0)` belongs to all three.
2. `(-3/4,-1/4,0)` belongs only to Mousebrot; its Mousebrot components are `-i/2` and `-i`.
3. `(-2,0,0)` is outside Mousebrot (`-2i` twice) but belongs to Arrowheadbrot and Tetrabrot at the real Mandelbrot endpoint `-2`.

All three checks pass. These witnessed membership differences and the source's separate equivalence-class basis prevent treating Mousebrot as a palette/camera alias.

## Catalog impact

- 3D identities: 27 → 28
- Ray-marched configs: 24 → 25
- Production fractals: 961 → 962
- Scientific visualizations: 1 (unchanged)
- Debug/test registry modules: 969 → 970
- Escape-time entries: 501 (unchanged)
- Custom modules: 9 (unchanged)
- Promoted ledger identities: 1,568 → 1,569, all stable IDs unique

The exact catalog test retains all 24 previously removed clone/direct-alias exclusions.

## GPU and oracle evidence

Baseline: `baseline_3d_thumbnail_report.json`

- selected/generated/render pass: 27/27/27
- failures/skips/warnings/Flutter errors: 0/0/0/0
- math oracles: 4 pass, 0 fail, 23 unsupported

Final strict report: `final_3d_thumbnail_report.json`

- selected/generated/render pass: 28/28/28
- failures/skips/quality warnings/Flutter errors: 0/0/0/0
- all-black/mostly-black/transparent/low-color/flat/blank: all 0
- math oracles: 5 pass, 0 fail, 23 unsupported

Mousebrot metrics:

- PNG bytes: 7,728
- unique RGB colors: 2,011
- luminance mean/stddev: 67.6394 / 33.2152
- dominant-color ratio: 0.1694
- transparent/black ratios: 0.0 / 0.0
- verdict: pass

The focused thumbnail was also inspected: the shape is visible, centered, and unclipped at the retained default zoom `2.0`.

## Verification receipts

- Red phase: module, shader/formula, oracle, compilation, and exact-ID tests all failed before implementation.
- Focused formula/count/ledger/catalog suite: 29 passed.
- Focused strict GPU audit: 1/1 pass.
- Full strict 3D GPU audit: 28/28 pass.
- `flutter analyze`: no issues.
- `flutter test`: 1,903 passed, 3 skipped.
- `bash -n scripts/run_fractal_render_audit.sh`: pass.
- Research/provenance/checksum/output audit: pass; all five declared outputs and all five parent checksums verified.
- Public count and ledger uniqueness audit: pass; 962 production fractals, 970 debug/test modules, 1,569 unique ledger IDs.
- `git diff --check`: pass.

## Prompt-to-artifact checklist

| Requirement / gate | Concrete evidence | Status |
|---|---|---|
| Research another 3D fractal | Mousebrot extraction package plus checksum-locked 27-query parent corpus | Complete |
| Avoid repeating completed research | No duplicate API retrieval; exact parent files and checksums recorded | Complete |
| Add a mathematically specified identity | Published `T(i₁,i₂,j₁)` basis and derived idempotent components | Complete |
| Avoid variants/preset spam | Quadratic degree fixed; power hidden; zero new presets/views as IDs | Complete |
| Continue removal audit | Exact 28-ID lock and all 24 removed-ID exclusions | Complete |
| Prove distinctness | Two membership witnesses distinguish Mousebrot from both existing principal slices | Complete |
| Verify shader integration | Source contract, registered asset, runtime-effect compilation | Complete |
| Verify rendered output | Focused inspection and strict 28-entry metrics report | Complete |
| Keep counts and ledger accurate | 962/970 locks and one unique new ledger entry | Complete |
| Verify repository regression state | Analyzer/full tests/script/diff receipts | Complete |

## Limitations and rejected scope

The ray marcher uses component escape-time estimates and the published idempotent Euclidean norm; it is not an exact signed-distance proof. The `-i/2` and `-i` bounded witnesses are finite-iteration checks, though paired with the exact real endpoint comparison and source/formula contracts. Turtlebrot is not added as a Mousebrot preset: the paper characterizes it as an intersection involving reflected Mousebrot-related slices, so it requires a separate formula and oracle audit. Twenty-three current 3D identities still lack formula-specific CPU oracles.
