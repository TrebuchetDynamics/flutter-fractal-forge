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
