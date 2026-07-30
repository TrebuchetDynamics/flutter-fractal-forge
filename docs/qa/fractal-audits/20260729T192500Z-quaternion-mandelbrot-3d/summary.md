# Quaternion Mandelbrot 3D follow-up and complete catalog re-audit

## Objective

Extend the audited 24-entry catalog with another researched, mathematically distinct 3D identity; reject presets and aliases; preserve all prior removals; and verify the complete resulting catalog with formula, shader, image-health, count, and repository evidence.

## Research

Package: `research/3d-quaternion-mandelbrot-2026-07-29/`

- Queries: 6
- OpenAlex: 81 records
- Crossref: 104 records
- arXiv: 120 records
- Library records: 305
- Unique DOIs: 174
- Decision: implement one memory-free quadratic quaternion parameter-space identity

The accepted recurrence is `q₀=0`, `qₙ₊₁=qₙ²+c`, rendered on the explicit hyperplane `c=(x,y,z,0)`. The research report distinguishes this parameter-space set from fixed-constant Quaternion Julia dynamics and from Mandelbulb polar powers. It also records that the rendered object is a 3D slice of a four-dimensional set and that the scalar derivative is a practical distance estimate, not an exact-distance theorem.

Principal evidence:

- [Gomatam and Doyle, quaternionic quadratic Mandelbrot maps](https://doi.org/10.1016/0960-0779(94)00163-K)
- [3D Rendering of the Quaternion Mandelbrot Set with Memory](https://doi.org/10.1142/S0218348X24500610) for 4D-to-3D slicing practice; memory variants were not copied or counted
- [Knill, Mandelbulb, Mandelbrot, Mandelring and Hopfbrot](https://arxiv.org/abs/2305.17848) for bounded critical-orbit formulation in the quaternion ring

No third-party shader code or copyrighted full text was copied.

## Implementation

- Added stable ID `quaternion_mandelbrot_3d` to `raymarched3DCatalog`.
- Added and registered `quaternion_mandelbrot_3d_gpu.frag` using the standard 3D camera/uniform contract.
- Locked `q₀=0`, sampled `c`, quaternion squaring, and derivative recurrence in source-contract tests.
- Hid the generic power control; no powers, memories, slices, or views became separate IDs.
- Added an independent CPU quaternion orbit oracle:
  - `c=0`: bounded
  - `c=-1`: bounded two-cycle
  - `c=2`: escapes
- Added one scoped live-ledger identity and updated current public counts.

## Identity audit

The exact expected set now contains 25 3D identities. The prior 24 removed clone/alias IDs remain absent. Quaternion Mandelbrot is not a Quaternion Julia preset:

- Mandelbrot: fixed `q₀=0`, sampled point is parameter `c`.
- Julia: sampled point is `q₀`, constant `c` is fixed.

The 3D hyperplane is a stable renderer contract for the quaternion parameter set, not a camera preset. Memory recurrences and higher powers remain out of scope.

## Catalog impact

- 3D identities: 24 → 25
- Ray-marched configs: 21 → 22
- Production fractals: 958 → 959
- Scientific visualizations: 1
- Debug/test registry modules: 966 → 967
- Escape-time entries: 501 (unchanged)
- Custom modules: 9 (unchanged)

## Render audit

Baseline: `baseline_3d_thumbnail_report.json`

- selected/generated/render pass: 24/24/24
- failures/skips/warnings/Flutter errors: 0/0/0/0
- math oracles: 1 pass, 0 fail, 23 skipped

Final strict audit: `final_3d_thumbnail_report.json`

- selected/generated/render pass: 25/25/25
- failures/skips/quality warnings/Flutter errors: 0/0/0/0
- all-black/mostly-black/transparent/low-color/flat/blank: all 0
- math oracles: 2 pass, 0 fail, 23 unsupported/skipped

Quaternion Mandelbrot metrics:

- PNG bytes: 6,821
- unique RGB colors: 1,827
- luminance mean/stddev: 73.9085 / 45.9802
- dominant-color ratio: 0.1629
- transparent/black ratio: 0.0 / 0.0
- verdict: pass

The focused thumbnail was tuned from an undersized first render to a centered, visible default and inspected directly.

## Verification

- Initial red tests failed for missing registry ID, shader, recurrence, and oracle.
- Source-contract tests: pass.
- Runtime-effect compilation: pass.
- Three known quaternion parameter points: pass.
- Focused strict GPU audit: 1/1 pass.
- Complete strict GPU audit: 25/25 pass.
- Exact 25-ID and removed-clone audit: pass.
- Catalog count, public-copy, and ledger tests: pass.
- `flutter analyze`: no issues.
- `flutter test`: 1872 passed, 3 skipped.
- `bash -n scripts/run_fractal_render_audit.sh`: pass.
- `git diff --check`: pass.

## Prompt-to-artifact checklist

| Requirement | Concrete evidence | Status |
|---|---|---|
| Research more 3D fractals | 6-query, 3-source ResearchForge package plus Ketch source discovery | Complete |
| Add a mathematically distinct identity | Quaternion parameter-space recurrence and explicit 3D hyperplane module/shader | Complete |
| Avoid aliases/presets | Parameter-vs-dynamical-space distinction; no power/memory/slice variants | Complete |
| Preserve prior removals | Exact 25-ID set and 24 removed-clone intersection assertion | Complete |
| Verify formula | Shader recurrence contract and independent three-point quaternion CPU oracle | Complete |
| Verify rendering | Focused and full strict GPU reports with objective metrics | Complete |
| Keep counts/ledger current | 959/967 count locks, public-copy test, unique ledger ID | Complete |
| Repository regression gate | Analyzer/full suite/script/diff checks | Complete |

## Remaining limitation

The scalar derivative recurrence supplies a conservative rendering estimate but is not an exact Euclidean-distance oracle for the quaternion parameter set. Twenty-three other 3D identities still have no formula-specific CPU oracle. This cycle raises audited 3D oracle coverage from 1/24 to 2/25 without inventing checks for unsupported formulas.
