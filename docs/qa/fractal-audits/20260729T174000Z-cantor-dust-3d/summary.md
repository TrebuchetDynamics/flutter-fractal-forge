# Cantor Dust 3D follow-up and complete catalog re-audit

## Objective

Continue the completed 3D catalog work without repeating it: research another mathematically distinct 3D identity, add only if its transform system is explicit, preserve all clone/alias removals, and re-audit the complete resulting catalog.

## Research decision

Targeted ResearchForge package: `research/3d-fractal-followup-2026-07-29/`

- 8 queries
- OpenAlex: 109 records
- Crossref: 160 records
- arXiv: 160 records
- Library records: 429
- Unique DOIs: 259
- Accepted: `cantor_dust_3d`
- Rejected for insufficient exact construction evidence: Sierpinski icosahedron and Sierpinski dodecahedron

The accepted identity is `C³`, the three-fold Cartesian product of the middle-thirds Cantor set. Its eight corner similarities all contract by `1/3`; therefore its similarity dimension is `log(8)/log(3)`. Source and claim details are in `report.md`, `evidence-grid.json`, `evidence-gaps.json`, and `provenance.json`.

## Implementation

- Added stable module ID `cantor_dust_3d` to `raymarched3DCatalog`.
- Reused the polyhedral IFS renderer with a new fixed selector, not a user-facing variant control.
- Added an exact eight-map nearest-child distance function to `polyhedral_ifs_3d_gpu.frag`.
- Kept the existing planar `cantor_dust` because it is `C²`; the new attractor is `C³` and has a different ambient and Hausdorff dimension.
- Iteration depth remains a rendering approximation control rather than a catalog identity.
- Added an independent CPU membership oracle with three known product-set points.
- Added the identity to the scoped live registry ledger and updated public count claims.

## Catalog impact

- 3D identities: 23 → 24
- Ray-marched configs: 20 → 21
- Production fractals: 957 → 958
- Scientific visualizations: 1
- Debug/test registry modules: 965 → 966
- Escape-time entries: 501 (unchanged)
- Custom modules: 9 (unchanged)

The exact 24-ID catalog test retains the prior 24-entry removed-clone/alias exclusion set. No fixed depth, camera, color, constant, or scale preset was promoted.

## Render evidence

Baseline: `baseline_3d_thumbnail_report.json`

- selected/generated/pass: 23/23/23
- failures/skips/warnings/Flutter errors: 0/0/0/0

Final strict audit: `final_3d_thumbnail_report.json`

- selected/generated/render pass: 24/24/24
- failures/skips/quality warnings/Flutter errors: 0/0/0/0
- all-black/mostly-black/transparent/low-color/flat/blank: all 0
- math oracle: 1 pass, 0 failures, 23 unsupported/skipped

Cantor Dust 3D metrics:

- PNG bytes: 9,796
- unique RGB colors: 1,685
- luminance mean/stddev: 74.2656 / 46.8077
- dominant-color ratio: 0.2771
- transparent/black ratio: 0.0 / 0.0
- verdict: pass

The generated 96×96 image was also inspected and contains visible recursive three-axis structure.

## Verification

- Initial red tests failed because the module, selector, and oracle did not yet exist.
- Polyhedral source-contract and runtime-effect compilation tests: pass.
- Exact 24-ID identity/removed-clone tests: pass.
- Catalog count, public claim, and ledger tests: pass.
- Cantor `C³` membership oracle tests: 3/3 known points pass.
- Focused strict GPU audit: 1/1 pass.
- Complete strict 3D GPU audit: 24/24 pass.
- `flutter analyze`: no issues.
- `flutter test`: 1861 passed, 3 skipped.
- `bash -n scripts/run_fractal_render_audit.sh`: pass.
- `git diff --check`: pass.

## Prompt-to-artifact completion checklist

| Requirement | Concrete evidence | Status |
|---|---|---|
| Research more 3D fractals | Targeted 8-query, 3-source ResearchForge package with report/provenance/evidence files | Complete |
| Add another valid 3D identity | `cantor_dust_3d` registry config and selector-3 shader construction | Complete |
| Avoid aliases and parameter spam | Exact `C³` identity statement; fixed selector; depth remains a control; exact catalog test | Complete |
| Audit removals and additions | 24-ID expected set and 24 prior clone/alias exclusions | Complete |
| Verify mathematical construction | Eight-map/one-third source contract plus independent three-point `C³` oracle | Complete |
| Verify shader/render behavior | Runtime-effect compilation and strict 24-entry GPU report with objective image metrics | Complete |
| Update counts and ledger | 958 production / 966 debug-test assertions and public-copy tests; unique ledger entry | Complete |
| Reject weak candidates | Icosahedron and dodecahedron evidence gaps recorded rather than implemented speculatively | Complete |
| Repository regression gate | Full analyzer and 1861-test suite pass | Complete |

## Remaining limitation

Twenty-three existing 3D identities still lack stable formula-specific CPU math oracles. Their assurance remains shader source contracts, compilation, finite controls, and strict GPU metrics. This follow-up improves oracle coverage from 0/23 to 1/24 without fabricating approximate reference checks.
