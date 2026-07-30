# Turtlebrot 3D follow-up and complete catalog re-audit

## Concrete objective

1. Continue beyond the completed Tetrabrot, Arrowheadbrot, and Mousebrot work with another researched 3D identity.
2. Derive the exact rule from published tricomplex algebra and reject aliases/presets.
3. Prove that the rule is a strict reflected intersection rather than a Mousebrot camera variant.
4. Re-audit exact catalog membership, prior removals, shaders, counts, ledger, rendered output, analyzer, and full tests.

## Research artifact

Package: `research/3d-turtlebrot-2026-07-29/`

It reuses, without repeated API retrieval, eight checksum-locked inputs from:

- the comprehensive 27-query principal-slice corpus (OpenAlex/arXiv/Crossref, 475 records, 174 unique DOIs, three citation seeds, 37 edges);
- the focused Mousebrot component derivation.

Vallières and Rochon's Proposition 7 identifies Turtlebrot as `T(i₁,i₂,j₂)`, `j₂=i₁i₃`, and proves that it is the intersection of a Mousebrot-related slice with its reflection across the third-coordinate plane. Recursive idempotent decomposition yields four ordinary complex parameters:

- `-z+(x-y)i`
- ` z+(x+y)i`
- ` z+(x-y)i`
- `-z+(x+y)i`

All four component orbits must remain bounded.

Primary evidence:

- [Relationship between the Mandelbrot Algorithm and the Platonic Solids](https://arxiv.org/abs/2107.04016), DOI `10.3390/math10030482`, Proposition 7.
- [Characterization of the Principal 3D Slices Related to the Multicomplex Mandelbrot Set](https://arxiv.org/abs/1809.02020), DOI `10.1007/s00006-019-0956-1`.

## Implementation artifacts

- Catalog ID/config: `turtlebrot_3d` in `lib/core/modules/builders/raymarched_3d/catalog_impl.dart`
- Shader: `shaders/3d_and_hypercomplex/raymarched_volumes/turtlebrot_3d_gpu.frag`
- Asset registration: `pubspec.yaml`
- CPU oracle: `lib/features/renderer/diagnostics/render_math_oracle.dart`
- Formula/runtime test: `test/modules/turtlebrot_3d_test.dart`
- Exact catalog lock: `test/features/catalog/three_d_catalog_identity_test.dart`
- Promoted ledger: `research/worlds-largest-fractal-catalog/curated-entry-ledger.live-registry.json`

The module is fixed at quadratic degree two, hides generic power, adds no presets, and combines four component distance estimates using the two-level idempotent norm `sqrt(sum(d²)/4)`.

## Identity and comparative-oracle evidence

The CPU oracle evaluates Turtlebrot, Mousebrot, Arrowheadbrot, and Tetrabrot formulas together:

1. `(0,0,0)` belongs to all four.
2. `(1/8,-3/4,-1/8)` belongs to Mousebrot but not Turtlebrot because one reflected component escapes. This proves strict containment rather than identity.
3. `(-3/4,-1/4,0)` belongs to Turtlebrot/Mousebrot but not Arrowheadbrot/Tetrabrot, separating it from the other existing principal slices.

All checks pass independently of shader pixels.

## Catalog impact

- 3D identities: 28 → 29
- Ray-marched configs: 25 → 26
- Production fractals: 962 → 963
- Scientific visualizations: 1 (unchanged)
- Debug/test registry modules: 970 → 971
- Escape-time entries: 501 (unchanged)
- Custom modules: 9 (unchanged)
- Promoted ledger identities: 1,569 → 1,570, all stable IDs unique

All 24 previously removed fixed-parameter/direct-alias IDs remain excluded by the exact catalog test.

## GPU and oracle evidence

Baseline: `baseline_3d_thumbnail_report.json`

- selected/generated/render pass: 28/28/28
- failures/skips/warnings/Flutter errors: 0/0/0/0
- math oracles: 5 pass, 0 fail, 23 unsupported

Final strict report: `final_3d_thumbnail_report.json`

- selected/generated/render pass: 29/29/29
- failures/skips/quality warnings/Flutter errors: 0/0/0/0
- all-black/mostly-black/transparent/low-color/flat/blank: all 0
- math oracles: 6 pass, 0 fail, 23 unsupported

Turtlebrot metrics after framing adjustment:

- PNG bytes: 8,766
- unique RGB colors: 2,118
- luminance mean/stddev: 77.1375 / 48.7394
- dominant-color ratio: 0.1620
- transparent/black ratios: 0.0 / 0.0
- verdict: pass

The initial focused render was centered but undersized. Default zoom was adjusted from `2.0` to `2.4`; the final inspected and full-audit image is visible, centered, and unclipped.

## Verification receipts

- Red phase: module, shader/formula, oracle, compilation, and exact-ID tests failed before implementation.
- Focused formula/count/ledger/catalog suite: 29 passed.
- Focused strict GPU audits: pass before and after framing adjustment.
- Full strict 3D GPU audit: 29/29 pass.
- `flutter analyze`: no issues.
- `flutter test`: 1,907 passed, 3 skipped.
- `bash -n scripts/run_fractal_render_audit.sh`: pass.
- Research/provenance/checksum/output audit: pass; all five outputs and eight parent checksums verified.
- Public count and ledger uniqueness audit: pass; 963 production fractals, 971 debug/test modules, 1,570 unique ledger IDs.
- `git diff --check`: pass.

## Prompt-to-artifact checklist

| Requirement / gate | Concrete evidence | Status |
|---|---|---|
| Research another 3D fractal | Turtlebrot extraction package and checksum-locked comprehensive corpus | Complete |
| Avoid repeating completed work | No duplicate API retrieval; eight exact parent checksums | Complete |
| Add a mathematically specified identity | Proposition 7 basis/intersection plus four derived complex components | Complete |
| Avoid aliases/preset spam | Strict-subset witness, fixed degree, hidden power, no presets/views | Complete |
| Continue removal audit | Exact 29-ID lock and all 24 removed-ID exclusions | Complete |
| Verify mathematics independently | Three comparative CPU cases across four principal slices | Complete |
| Verify shader integration | Four source contracts, registered asset, runtime compilation | Complete |
| Verify actual rendered output | Two focused inspections and strict 29-entry report | Complete |
| Keep counts and ledger accurate | 963/971 locks and one unique new ledger entry | Complete |
| Verify repository regression state | Analyzer/full tests/script/diff receipts | Complete |

## Limitations and rejected scope

The four-component root-mean-square is a conservative rendering estimator, not an exact signed-distance theorem. Rational known-point checks are finite-iteration regressions rather than a general membership procedure. Hourglassbrot is not treated as a preset: although it has an analogous intersection theorem, it uses a different basis and Arrowheadbrot-related parents and requires a separate derivation. Twenty-three current 3D identities still lack formula-specific CPU oracles.
