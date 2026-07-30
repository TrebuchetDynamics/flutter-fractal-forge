# 3D catalog identity audit

## Objective and acceptance criteria

Audit the 3D catalog so that it contains one entry per stable formula/rule, removes parameter-only clones and direct aliases, promotes renderer-backed missing 3D behavior, keeps useful parameter ranges/presets, and passes catalog, shader, image-health, analyzer, and full-test gates.

## Baseline

- Source: `docs/qa/fractal-audits/20260717T004639Z/final_thumbnail_report.json`
- Relevant source comparison: no 3D module or shader changes from baseline revision `36f18e3a351dfa524c00994ce734556205d02b15`; only `pubspec.yaml` differed.
- Extract: `baseline_3d_catalog.json`
- Entries evaluated: 43
- Render health: 43 pass, 0 non-pass, 0 failures, 0 skips, 0 warnings
- Math oracle: 0 pass, 0 fail, 43 skipped

Baseline rendering was healthy, but the catalog violated the repository's Counted Catalog Identity rule: fixed powers, scales, constants, and renderer aliases were exposed as separate fractals.

## Decisions and changes

### Removed from the registry

24 non-distinct entries:

- 9 fixed Mandelbox scale clones: `f0570`–`f0578`
- 9 fixed Mandelbulb power clones: `f0561`–`f0569`
- 3 fixed Quaternion Julia constant clones: `f0540`, `f0544`, `f0545`
- 3 direct aliases: `f0593_sierpinski_tetrahedron_3d`, `f0594_menger_sponge_3d`, `f0598_3d_koch_snowflake`

The four generated shared-3D builders and their obsolete tests were deleted. Duplicate Quaternion Julia and Dual-Quaternion entries were also removed from the 2D escape-time source catalog; those duplicates were already hidden by registry de-duplication.

### Consolidated without losing controls

- Mandelbox scale now reaches 4.0 on canonical `mandelbox`.
- Time-Modulated Mandelbulb power now reaches 24.0.
- Canonical `quaternion_julia_3d` now exposes custom `c0`–`c3` controls and preserves the three reviewed constants as built-in presets.
- Distinct `f0597_sierpinski_carpet_3d_menger_cross` remains as the Menger Cross rule in the curated ray-marched catalog.

### Added/promoted

- `implicit_affine_fractal_surface` moved from the 2D escape-time builder to the standard 3D ray-marched catalog.
- Its shader now uses camera rotation, pan target, adjustable affine scale, iterations, ray steps, bailout distance, palette selection, and transparent background.
- `hydrogen_orbital` remains available but moved to `Scientific Visualization`; it is a volumetric orbital renderer, not a fractal identity, and is excluded from the counted ledger.

No speculative external formula was added: the remaining reference-only candidates require a distinct renderer plus provenance/math validation. Parameter choices such as cubic Mandelbulbs do not qualify as new identities.

## Final 3D fractal catalog

18 formula/rule identities:

1. Mandelbox
2. Menger Cross 3D
3. KIFS Menger Sponge
4. KIFS Sierpinski Tetrahedron
5. KIFS Koch 3D
6. KIFS Snowflake 3D
7. Implicit Affine Fractal Surface
8. Quaternion Julia 3D
9. Dual-Quaternion Julia
10. Mandelbox Shape Inversion
11. 3D Apollonian Sphere Packing
12. Inversive Limit Set 3D
13. Time-Modulated Mandelbulb
14. Amazing Box
15. Bulbils
16. Hartverdrahtet
17. Tglad's Formula
18. Mandelbulb

## Verification

- `bash -n scripts/run_fractal_render_audit.sh`: pass
- Focused changed-module strict GPU audit (5 modules): 5 generated, 0 failed, 0 skipped, 0 warnings
- Final strict GPU audit (all 18 3D entries): 18 generated, 18 pass, 0 failed, 0 skipped, 0 warnings, 0 Flutter errors
- Final report: `final_3d_thumbnail_report.json`
- Final math oracle: 0 pass, 0 fail, 18 skipped (no stable 3D reference oracle exists yet)
- Focused catalog/module tests: pass
- `flutter analyze`: pass, no issues
- `flutter test`: pass, 1849 passed and 3 skipped
- `git diff --check`: pass

## Prompt-to-artifact checklist

| Requirement | Evidence | Status |
|---|---|---|
| Audit current 3D catalog | 43-entry baseline extract and identity-rule comparison | Complete |
| Remove unsuitable entries | 24 clones/aliases absent; `three_d_catalog_identity_test.dart` locks removal | Complete |
| Add/promote valid 3D behavior | Implicit Affine moved to ray-marched catalog with rotatable shader | Complete |
| Preserve useful variant access | Mandelbox/Mandelbulb ranges and Quaternion presets/controls | Complete |
| Remove non-fractal content from category | Hydrogen Orbital categorized as Scientific Visualization and skipped by ledger | Complete |
| Validate every final 3D entry | Strict 18/18 GPU report with objective image metrics | Complete |
| Keep public counts and ledger honest | README/store/PRD/TODO/count tests and scoped live-ledger cleanup | Complete |
| Repository regression gate | Analyzer and full test suite pass | Complete |

## Remaining limitation

All 18 3D math-oracle rows are skipped. Render health is fully covered, but formula correctness still relies on shader contract tests and source/provenance evidence until stable known-point 3D distance-estimator oracles are added.
