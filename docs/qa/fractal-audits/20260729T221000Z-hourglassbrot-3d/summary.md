# Hourglassbrot 3D follow-up and complete catalog re-audit

## Concrete objective

1. Continue the researched 3D expansion beyond Turtlebrot without repeating completed retrieval.
2. Add only an exact, source-backed identity—not a preset, view, power, or alias.
3. Prove Hourglassbrot is a strict reflected intersection and differs from existing principal slices.
4. Re-audit exact catalog identity, prior removals, shader integration, counts, ledger, rendered output, analyzer, and full tests.

## Research artifact

Package: `research/3d-hourglassbrot-2026-07-29/`

It reuses five checksum-verified artifacts from the comprehensive 27-query principal-slice corpus rather than repeating API retrieval:

- sources: OpenAlex, arXiv, Crossref
- saved records: 475
- unique DOIs: 174
- citation expansion: 3 seeds, 37 edges
- new searches: 0

Vallières and Rochon's Proposition 8 identifies Hourglassbrot as `T(i₁,j₁,j₂)`, where `j₁=i₁i₂` and `j₂=i₁i₃`, and proves it is the intersection of an Arrowheadbrot-related copy with its reflection across the third-coordinate plane. Substitution into Proposition 3 yields four complex Mandelbrot parameters:

- `( y-z)+xi`
- `(-y+z)+xi`
- `( y+z)+xi`
- `(-y-z)+xi`

All four must remain bounded.

Primary evidence:

- [Relationship between the Mandelbrot Algorithm and the Platonic Solids](https://arxiv.org/abs/2107.04016), DOI `10.3390/math10030482`, Propositions 3 and 8.
- [Characterization of the Principal 3D Slices Related to the Multicomplex Mandelbrot Set](https://arxiv.org/abs/1809.02020), DOI `10.1007/s00006-019-0956-1`.

## Implementation artifacts

- Catalog ID/config: `hourglassbrot_3d` in `lib/core/modules/builders/raymarched_3d/catalog_impl.dart`
- Shader: `shaders/3d_and_hypercomplex/raymarched_volumes/hourglassbrot_3d_gpu.frag`
- Asset registration: `pubspec.yaml`
- CPU oracle: `lib/features/renderer/diagnostics/render_math_oracle.dart`
- Formula/runtime test: `test/modules/hourglassbrot_3d_test.dart`
- Exact catalog lock: `test/features/catalog/three_d_catalog_identity_test.dart`
- Promoted ledger: `research/worlds-largest-fractal-catalog/curated-entry-ledger.live-registry.json`

The module is fixed at quadratic degree two, hides generic power, adds no presets, and combines the four component estimates as `sqrt(sum(d²)/4)`.

## Identity and comparative-oracle evidence

The CPU oracle evaluates Hourglassbrot, its correctly remapped Arrowheadbrot parent copy, Turtlebrot, Mousebrot, Arrowheadbrot, and Tetrabrot:

1. `(0,0,0)` belongs to all compared sets.
2. `(-1/2,-1/4,-1/4)` belongs to the parent Arrowheadbrot copy but not Hourglassbrot, proving the reflected intersection is strict.
3. `(1/2,-1/4,0)` belongs to Hourglassbrot but is outside Turtlebrot, Mousebrot, Arrowheadbrot, and Tetrabrot in catalog coordinates.

All checks pass using CPU complex iteration independent of shader pixels.

## Catalog impact

- 3D identities: 29 → 30
- Ray-marched configs: 26 → 27
- Production fractals: 963 → 964
- Scientific visualizations: 1 (unchanged)
- Debug/test registry modules: 971 → 972
- Escape-time entries: 501 (unchanged)
- Custom modules: 9 (unchanged)
- Promoted ledger identities: 1,570 → 1,571, all stable IDs unique

All 24 previously removed clone/direct-alias IDs remain excluded by the exact catalog test.

## GPU and oracle evidence

Baseline: `baseline_3d_thumbnail_report.json`

- selected/generated/render pass: 29/29/29
- failures/skips/warnings/Flutter errors: 0/0/0/0
- math oracles: 6 pass, 0 fail, 23 unsupported

Final strict report: `final_3d_thumbnail_report.json`

- selected/generated/render pass: 30/30/30
- failures/skips/quality warnings/Flutter errors: 0/0/0/0
- all-black/mostly-black/transparent/low-color/flat/blank: all 0
- math oracles: 7 pass, 0 fail, 23 unsupported

Hourglassbrot metrics after framing adjustment:

- PNG bytes: 8,864
- unique RGB colors: 2,331
- luminance mean/stddev: 81.0026 / 54.2000
- dominant-color ratio: 0.1766
- transparent/black ratios: 0.0 / 0.0
- verdict: pass

The first focused image was centered but undersized. Default zoom was increased from `2.0` to `3.0`; the final inspected and full-audit thumbnail is visible, centered, and unclipped.

## Verification receipts

- Red phase: module, shader/formula, oracle, compilation, and exact-ID tests failed before implementation.
- Focused formula/count/ledger/catalog suite: 29 passed.
- Focused strict GPU audits: pass before and after framing adjustment.
- Full strict 3D GPU audit: 30/30 pass.
- `flutter analyze`: no issues.
- `flutter test`: 1,917 passed, 3 skipped.
- `bash -n scripts/run_fractal_render_audit.sh`: pass.
- Research/provenance/checksum/output audit: pass; all five outputs and five parent checksums verified.
- Public count and ledger uniqueness audit: pass; 964 production fractals, 972 debug/test modules, 1,571 unique ledger IDs.
- `git diff --check`: pass.

## Prompt-to-artifact checklist

| Requirement / gate | Concrete evidence | Status |
|---|---|---|
| Research another 3D fractal | Hourglassbrot extraction and checksum-locked 27-query corpus | Complete |
| Avoid repeating completed work | Zero repeated live searches; five verified source artifacts | Complete |
| Add a mathematically specified identity | Proposition 8 basis/intersection and four complex components | Complete |
| Avoid aliases/preset spam | Strict-parent witness, fixed degree, hidden power, no presets/views | Complete |
| Continue removal audit | Exact 30-ID lock and all 24 removed-ID exclusions | Complete |
| Verify mathematics independently | Three CPU cases across Hourglassbrot, parent, and four prior slices | Complete |
| Verify shader integration | Four formula contracts, asset registration, runtime compilation | Complete |
| Verify actual rendered output | Two focused inspections and strict 30-entry report | Complete |
| Keep counts and ledger accurate | 964/972 locks and one unique new ledger entry | Complete |
| Verify repository regression state | Analyzer/full tests/script/diff receipts | Complete |

## Limitations and rejected scope

The four-component root-mean-square is a conservative rendering estimator, not an exact signed-distance theorem. Rational known-point checks are finite-iteration regressions rather than a general membership procedure. Metabrot remains excluded as a different basis/rule; Airbrot and Firebrot remain excluded pending a product decision because their quadratic slices are ordinary polyhedra. Twenty-three current 3D identities still lack formula-specific CPU oracles.
