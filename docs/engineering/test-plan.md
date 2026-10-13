# Verification plan

## Automated checks

Run from the repository root with the Flutter SDK and dependencies available:

| Risk | Command or test target | Observable expected result |
|---|---|---|
| Dart correctness and lint | `flutter analyze` | No analyzer errors; resolve warnings according to repository policy. |
| Unit and widget behavior | `flutter test` | All selected tests pass; any skip is reported with its reason. |
| Integration flows | `flutter test integration_test/` on a configured device | Catalog-to-viewer navigation, controls, and tested export flows complete without uncaught errors. Device and platform must be recorded. |
| Shader/module contract | `flutter test test/shaders/` and relevant module tests | Registered shader assets load/compile in the test backend, and module uniforms/defaults satisfy their tested contract. This is not proof of hardware GPU output. |
| Real GPU rendering | `flutter test integration_test/rendering/` on a supported desktop/device GPU | The selected rendering assertions and image checks pass on the named backend. Preserve screenshots/reports when the target test emits them. |
| Full catalog visual audit | `python3 scripts/audit-linux-fractals.py` on Linux with its documented display/GPU setup | Audit report records each selected module's render result and visual metrics. A timeout or omitted module is incomplete evidence. |

CI's current validation and device integration job definitions are in `.gitlab-ci.yml`. The optional Linux catalog audit runs separately from the standard validation job. A test's presence is not evidence that it passed; record the exact command, environment, and result for each acceptance claim.

## Risk-based scenarios

- Catalog: search, category display, list/grid state, and stable module identity.
- Viewer: module selection, configured default view, pan/zoom/rotation, reset, parameter changes, and accessibility semantics.
- Renderer: shader compile/load failure, GPU-health fallback, precision eligibility, cancellation during navigation, and a CPU formula's bounded render.
- Persistence: save and restore supported settings/presets; malformed stored values do not crash the app.
- Export/platform: verify file creation and share/wallpaper behavior on each supported platform; widget-level sheet coverage alone does not prove platform writes.
- Web: verify the browser preview separately; do not infer export, CPU precision, deep-zoom, or hardware-GPU parity from a successful page load.
- Playwright catalog smoke: with an active viewer session stored in
  `localStorage`, open `/?smokeModule=mandelbrot`. The explicit module must
  emit its opened and first-frame markers, and the canvas must be visible
  (`test/playwright/smoke-session-conflict.spec.mjs`).

## Limits and outstanding coverage

Real-device MediaStore and wallpaper verification, real-device gesture feel/deep zoom, and broad visual audit work remain listed in `TODO.md` and the current platform/audit documents. The visual-inventory validator checks ID counts, references, and shader paths; it does not prove GPU image quality, a first viewer frame, or native CPU-formula coverage. The inventory records capture/runtime-preview evidence for 177 of 1,027 Explore rows; 850 remain uncaptured. All 200 research definitions have no app renderer. First-view evidence is recorded for 14 Explore rows; `cpu_formula` is `not audited` in 1,154 of the 1,227 rows. Historical run counts in `PRD.md` are dated snapshots, not current verification receipts. No claim is made here that these checks ran during documentation maintenance.

## MAP host qualification

Scope: `GAUSS-MOAT-01-MAP`, not the wider `GAUSS-MOAT-001` milestone. The original native review approved local implementation at `6e671957a30ea7b44a80f8cfc4a8d5d31c73dd73` with 178 tests on its admitted baseline. Integration must independently check a frozen current-main candidate and the bounded [MAP contract](spec.md#map-implementation-and-bounded-contract); original admission/review is not retrospective approval of documentation reconciliation.

Required host checks use Flutter 3.44.6 / Dart 3.12.2 and current main's unchanged `pubspec.yaml`/`pubspec.lock`, resolved offline. Run `flutter gen-l10n` and require unchanged generated localization bytes. Run `flutter analyze --no-pub`, targeted `dart format --output=none --set-exit-if-changed` for the eight authored Dart files, and `git diff --check`. Verify documentation links, exact 15-file integration scope, approved incremental code delta, unchanged dependencies and preservation of unrelated source.

Run `flutter test --no-pub test/modules/gaussian_moat_model_test.dart test/features/viewer/gaussian_moat_walk_test.dart test/modules/tenth_wave_fractal_additions_test.dart test/modules/module_registry_widget_test.dart test/fractal/fractal_renderer_gesture_test.dart test/fractal/fractal_viewer_screen_widget_test.dart test/screens/localization_widget_test.dart test/fractal/fractal_controls_hud_test.dart test/fractal/fractal_renderer_widget_test.dart --reporter expanded`.

Discriminating MAP coverage: signed/axis fixtures (`1+i`, `1-i`, `3`, `3i`), origin/unit/composite rejection, exactly four B=1 vertices, independent trial-division agreement at every B=128 position, invalid bounds before work, cancellation without partial publication and native integer extremes on both axes. Viewer coverage must use the actual Gaussian entry and verify Explore preservation, four widths × EN/ES × two text scales, valid/invalid Apply, shared signed transforms after pane resize/pan/zoom, tap versus drag/wheel, keyboard focus/root validation, unchanged selection on rejected coordinates and captured candidate-highlight pixels.

The current-main diagnostic had 171 tests, not 178. Source comparison identifies eight cases introduced on the worker baseline and one older case replaced there (net seven): seven later 3D gesture cases and one HUD drag-handle case replace the old two-finger-tilt case. They target independent 3D gesture/HUD-handle implementations absent from current main, not Gaussian 2D selection, signed coordinates or the MAP HUD content slot. Do not import those implementations/tests to inflate this slice's count. Run current-main gesture/HUD regressions and all approved MAP tests; record exact names and source revisions in the private integration receipt.

This is the required integration gate, not a claim that a new candidate already passed. Retain actual command outputs, immutable candidate/tree identity, independent integration review, owned blob/diff checks and main ancestry readback in profile-local receipts. A completed MAP task records offline implementation/local integration only; keep WALK, growth and platform qualification tasks open.

NOT_CHECKED by this host gate: actual Linux/Android/browser journeys, physical storage/download/share, exported platform artifacts, native screen-reader/high-contrast qualification, device peak RSS/chunk latency/frame performance, Lean rebuilding and infinite-theorem certification. Host fixtures and capture pixels do not qualify these outcomes.
