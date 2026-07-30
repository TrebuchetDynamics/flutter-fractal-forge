# Arrowheadbrot 3D follow-up and complete catalog re-audit

## Concrete objective

1. Research another mathematically defensible 3D fractal without repeating the completed Tetrabrot work.
2. Add only a stable formula/rule identity—not a degree, palette, camera, or fixed-parameter clone.
3. Prove that the new identity is distinct from the existing 3D catalog with published equations and independent known points.
4. Re-run formula, shader compilation, exact catalog, count, ledger, GPU image-health, analyzer, and full regression gates against the resulting catalog.

## Research artifact

Package: `research/3d-principal-tricomplex-slices-2026-07-29/`

- Depth: comprehensive
- Queries: 27
- Sources: OpenAlex, arXiv, Crossref
- Saved records: 475
- Combined unique DOIs: 174
- Combined unique normalized titles: 219
- Citation expansion: 3 defining seeds, 37 total returned edges
- Accepted: classical quadratic Arrowheadbrot
- Deferred: Mousebrot, Turtlebrot, Hourglassbrot, Metabrot, Airbrot, Firebrot

Vallières and Rochon define Arrowheadbrot as the principal slice `T(1,i₁,j₁)`, `j₁=i₁i₂`. For `c=x+y i₁+z j₁`, idempotent decomposition yields ordinary complex parameters `(x-z)+yi` and `(x+z)+yi`; the point belongs exactly when both parameters belong to the quadratic Mandelbrot set.

Primary evidence:

- [Relationship between the Mandelbrot Algorithm and the Platonic Solids](https://arxiv.org/abs/2107.04016), DOI `10.3390/math10030482`, Proposition 3.
- [Characterization of the Principal 3D Slices Related to the Multicomplex Mandelbrot Set](https://arxiv.org/abs/1809.02020), DOI `10.1007/s00006-019-0956-1`.
- [On a Bicomplex Distance Estimation for the Tetrabrot](https://doi.org/10.1142/S0218127405013873).

## Implementation artifacts

- Catalog ID: `arrowheadbrot_3d`
- Catalog definition: `lib/core/modules/builders/raymarched_3d/catalog_impl.dart`
- Shader: `shaders/3d_and_hypercomplex/raymarched_volumes/arrowheadbrot_3d_gpu.frag`
- Asset registration: `pubspec.yaml`
- CPU oracle: `lib/features/renderer/diagnostics/render_math_oracle.dart`
- Formula/runtime test: `test/modules/arrowheadbrot_3d_test.dart`
- Exact identity lock: `test/features/catalog/three_d_catalog_identity_test.dart`
- Live ledger: `research/worlds-largest-fractal-catalog/curated-entry-ledger.live-registry.json`

The generic power control is hidden and the recurrence is fixed at quadratic degree two. No preset IDs or alternate views were added.

## Distinctness evidence

Arrowheadbrot uses real-axis component translations `(x±z)+yi`; Tetrabrot uses imaginary-axis translations `x+(y±z)i`. Independent CPU checks compare both formulas:

- `(0,0,0)` belongs to both.
- `(-7/8,0,9/8)` gives Arrowheadbrot components `-2` and `1/4`; it belongs to Arrowheadbrot and not Tetrabrot.
- `(0,0,0.3)` gives Arrowheadbrot components `-0.3` and `0.3`; it is outside Arrowheadbrot while the Tetrabrot components `±0.3i` remain bounded.

All three comparative checks pass. This directly rejects the possibility that the new ID is only a camera/palette alias of Tetrabrot.

## Catalog impact

- 3D identities: 26 → 27
- Ray-marched configs: 23 → 24
- Production fractals: 960 → 961
- Scientific visualizations: 1 (unchanged)
- Debug/test registry modules: 968 → 969
- Escape-time entries: 501 (unchanged)
- Custom modules: 9 (unchanged)
- Promoted ledger identities: 1,567 → 1,568, all stable IDs unique

All 24 previously removed fixed-parameter/direct-alias IDs remain excluded by the exact identity test.

## GPU and oracle evidence

Baseline: `baseline_3d_thumbnail_report.json`

- selected/generated/render pass: 26/26/26
- failures/skips/warnings/Flutter errors: 0/0/0/0
- math oracles: 3 pass, 0 fail, 23 unsupported

Final strict report: `final_3d_thumbnail_report.json`

- selected/generated/render pass: 27/27/27
- failures/skips/quality warnings/Flutter errors: 0/0/0/0
- all-black/mostly-black/transparent/low-color/flat/blank: all 0
- math oracles: 4 pass, 0 fail, 23 unsupported

Arrowheadbrot metrics after framing adjustment:

- PNG bytes: 8,180
- unique RGB colors: 1,947
- luminance mean/stddev: 79.4825 / 53.6618
- dominant-color ratio: 0.1670
- transparent/black ratios: 0.0 / 0.0
- verdict: pass

The initial thumbnail was undersized and the first zoom adjustment touched the frame edge. The final default zoom of `2.0` produces a visible, unclipped thumbnail and is the version included in the 27-entry strict report.

## Verification receipts

- Red phase: module, shader/formula, oracle, compilation, and exact-ID tests all failed before implementation.
- Focused formula/count/ledger/catalog suite: 29 passed.
- Focused strict GPU audit: 1/1 pass.
- Full strict 3D GPU audit: 27/27 pass.
- `flutter analyze`: no issues.
- `flutter test`: 1,884 passed, 3 skipped.
- `bash -n scripts/run_fractal_render_audit.sh`: pass.
- Research/provenance JSON and output coverage audit: pass; 27 queries and all declared outputs present.
- Public count and ledger uniqueness audit: pass; 961 production fractals, 969 debug/test modules, 1,568 unique ledger IDs.
- `git diff --check`: pass.

## Prompt-to-artifact checklist

| Requirement / gate | Concrete evidence | Status |
|---|---|---|
| Research more 3D fractals | 27-query comprehensive package, three sources, three citation seeds | Complete |
| Add a defensible new 3D identity | Published `T(1,i₁,j₁)` basis and two exact complex components | Complete |
| Avoid repeating completed work | Arrowheadbrot chosen after Tetrabrot; point comparisons prove different membership | Complete |
| Avoid variants/preset spam | Fixed quadratic recurrence; hidden power; no new presets/views as IDs | Complete |
| Continue the removal audit | Exact 27-ID set and all 24 removed-ID exclusions | Complete |
| Verify mathematics independently | Three CPU comparisons, including two formula-separating points | Complete |
| Verify shader integration | Asset declaration, source contracts, runtime-effect compilation | Complete |
| Verify actual rendered output | Focused image inspection and strict 27-entry JSON report | Complete |
| Keep counts and ledger accurate | 961/969 locks and one unique ledger identity | Complete |
| Verify repository regression state | Analyzer/full tests/script syntax/diff checks | Complete |

## Limitations

The shader combines ordinary complex escape-time estimates with the published idempotent Euclidean norm; it is a conservative rendering estimator, not a proof of exact signed distance. Twenty-three 3D identities still lack stable formula-specific CPU oracles. Firebrot and Airbrot are deferred because their quadratic slices are ordinary polyhedra, making their user-facing classification as fractals questionable despite dynamical provenance.
