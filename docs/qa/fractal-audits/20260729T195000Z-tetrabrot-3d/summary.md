# Tetrabrot 3D follow-up and complete catalog re-audit

## Objective

Continue the 3D expansion with another mathematically explicit identity, preserve the catalog's alias/parameter discipline, and re-audit the full resulting 3D set with formula, shader, oracle, image-health, count, and repository evidence.

## Research

Package: `research/3d-tetrabrot-2026-07-29/`

- Queries: 6
- OpenAlex: 30 records
- Crossref: 104 records
- arXiv: 120 records
- Library records: 254
- Unique DOIs: 110
- Accepted identity: classical quadratic Tetrabrot

The literature explicitly defines the Tetrabrot as the principal slice `T²(1,i₁,i₂)` of the tricomplex Mandelbrot set. For `c=x+y i₁+z i₂`, idempotent decomposition yields complex parameters `x+(y-z)i` and `x+(y+z)i`. Membership requires both parameters to lie in the ordinary complex Mandelbrot set, and the component distance construction combines their estimates by root-mean-square.

Primary evidence:

- [Tricomplex Distance Estimation for Filled-in Julia Sets and Multibrot Sets](https://arxiv.org/abs/1811.09697)
- [On a Bicomplex Distance Estimation for the Tetrabrot](https://doi.org/10.1142/S0218127405013873)
- [Relationship between the Mandelbrot Algorithm and the Platonic Solids](https://doi.org/10.3390/math10030482)

No third-party shader code or full-text artifact is stored in the repository.

## Implementation

- Added stable ID `tetrabrot_3d` to `raymarched3DCatalog`.
- Added and registered `tetrabrot_3d_gpu.frag` using the standard 3D uniform/camera contract.
- Implemented the two published complex components and root-mean-square distance construction.
- Fixed the identity at quadratic degree two and hid the generic power control.
- Added an independent component-membership oracle:
  - `(0,0,0)`: contained
  - `(-1,0,0)`: contained
  - `(2,0,0)`: outside
- Added one unique live-ledger entry and updated public count surfaces.

## Identity audit

The expected catalog now contains exactly 26 3D identities. All 24 previously removed clone/alias IDs remain absent. Tetrabrot is distinct from:

- planar Mandelbrot: one complex parameter versus a coupled 3D tricomplex slice;
- Quaternion Mandelbrot 3D: commutative idempotent components versus quaternion multiplication;
- degree or camera presets: the module exposes neither as new identities.

Seven other named principal tricomplex slices and higher powers remain separate research candidates. They were not bundled as variants or counted speculatively.

## Catalog impact

- 3D identities: 25 → 26
- Ray-marched configs: 22 → 23
- Production fractals: 959 → 960
- Scientific visualizations: 1
- Debug/test registry modules: 967 → 968
- Escape-time entries: 501 (unchanged)
- Custom modules: 9 (unchanged)

## GPU and oracle evidence

Baseline: `baseline_3d_thumbnail_report.json`

- selected/generated/render pass: 25/25/25
- failures/skips/warnings/Flutter errors: 0/0/0/0
- math oracles: 2 pass, 0 fail, 23 skipped

Final strict audit: `final_3d_thumbnail_report.json`

- selected/generated/render pass: 26/26/26
- failures/skips/quality warnings/Flutter errors: 0/0/0/0
- all-black/mostly-black/transparent/low-color/flat/blank: all 0
- math oracles: 3 pass, 0 fail, 23 unsupported/skipped

Tetrabrot metrics:

- PNG bytes: 6,520
- unique RGB colors: 1,612
- luminance mean/stddev: 75.1778 / 51.8144
- dominant-color ratio: 0.1709
- transparent/black ratio: 0.0 / 0.0
- verdict: pass

The first focused preview was undersized; default zoom was tuned to a visible, unclipped framing and confirmed again in the full audit.

## Verification

- Initial red tests failed for the absent ID, shader, component formulas, and oracle.
- Source-contract tests: pass.
- Runtime-effect compilation: pass.
- Three independent component-membership points: pass.
- Focused strict GPU audit: 1/1 pass.
- Full strict 3D GPU audit: 26/26 pass.
- Exact 26-ID and removed-clone audit: pass.
- Catalog count, public-copy, and ledger tests: pass.
- `flutter analyze`: no issues.
- `flutter test`: 1880 passed, 3 skipped.
- `bash -n scripts/run_fractal_render_audit.sh`: pass.
- `git diff --check`: pass.

## Prompt-to-artifact checklist

| Requirement | Concrete evidence | Status |
|---|---|---|
| Research more 3D fractals | 6-query, 3-source package and inspected open equation source | Complete |
| Add a valid identity | Classical `T²(1,i₁,i₂)` module and shader | Complete |
| Avoid aliases/preset spam | Fixed quadratic degree; other slices/powers excluded | Complete |
| Preserve audit removals | Exact 26-ID set plus 24 removed-clone exclusions | Complete |
| Verify mathematics | Published component equations plus independent three-point membership oracle | Complete |
| Verify shader/render | Source contract, runtime compilation, focused/full strict GPU reports | Complete |
| Keep counts/ledger current | 960/968 locks, public-copy test, one unique ledger ID | Complete |
| Repository regression gate | Analyzer/full suite/script/diff receipts | Complete |

## Remaining limitation

The shader combines standard complex escape-time distance estimates according to the published idempotent expression; this remains a rendering estimator rather than an exact signed-distance proof. Twenty-three 3D identities still lack formula-specific CPU oracles. Coverage improves from 2/25 to 3/26 with zero oracle failures.
