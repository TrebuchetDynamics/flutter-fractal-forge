# Verification plan

## Automated checks

Run from the repository root with the Flutter SDK and dependencies available:

| Risk | Command or test target | Observable expected result |
|---|---|---|
| Dart correctness and lint | `flutter analyze` | No analyzer errors; resolve warnings according to repository policy. |
| Unit and widget behavior | `flutter test` | All selected tests pass; any skip is reported with its reason. |
| Integration flows | `flutter test integration_test/` on a configured device | Catalog-to-viewer navigation, controls, and tested export flows complete without uncaught errors. Device and platform must be recorded. |
| Shader/module contract | `flutter test test/shaders/` and relevant module tests, including `test/core/modules/builders/uniform_layout_test.dart` and `test/modules/mandelbulb_shared_pan_target_test.dart` | Selected shader assets load/compile in the test backend; source and asset tests check their declared contracts; shared ray-marched 3D frame slots carry time, resolution, pan, zoom, and rotation consistently across the shared builder and custom modules. This is not proof of hardware GPU output or visual camera feel. |
| Real GPU rendering | `flutter test integration_test/rendering/` on a supported desktop/device GPU | The selected rendering assertions and image checks pass on the named backend. Preserve screenshots/reports when the target test emits them. |
| Full catalog visual audit | `python3 scripts/audit-linux-fractals.py` on Linux with its documented display/GPU setup | Audit report records each selected module's render result and visual metrics. A timeout or omitted module is incomplete evidence. |

CI's current validation and device integration job definitions are in `.gitlab-ci.yml`. The optional Linux catalog audit runs separately from the standard validation job. A test's presence is not evidence that it passed; record the exact command, environment, and result for each acceptance claim.

## Risk-based scenarios

- Catalog: search, category display, list/grid state, and stable module identity.
- Viewer: module selection, configured default view, pan/zoom/rotation, reset, parameter changes, and accessibility semantics.
- Renderer: shader compile/load failure, GPU-health fallback, precision eligibility, cancellation during navigation, and a CPU formula's bounded render.
- Persistence: save and restore supported settings/presets; malformed stored values do not crash the app.
- Export/platform: verify file creation and share/wallpaper behavior on each supported platform; widget-level sheet coverage alone does not prove platform writes.
- Visual-audit qualification: verify true defaults, runtime previews, and the first viewer GPU frame separately. Run native CPU checks where supported, record unsupported/skipped checks, and preserve formulas while logging failures.
- Smooth coloring: run the focused regression set and reconcile coverage against the full applicable polynomial escape-time shader inventory. Passing sampled families does not establish complete coverage.
- Web: verify the browser preview separately; do not infer export, CPU precision, deep-zoom, or hardware-GPU parity from a successful page load.
- Playwright catalog smoke: with an active viewer session stored in
  `localStorage`, open `/?smokeModule=mandelbrot`. The explicit module must
  emit its opened and first-frame markers, and the canvas must be visible
  (`test/playwright/smoke-session-conflict.spec.mjs`).

## Accepted cross-platform release journey

Status: Accepted

Source: [Owner-approved release contract](../../PRD.md#active-release-contract), accepted in the 2026-10-11 repository interview. This section defines planned qualification, not an executed pass.

Run the same browse → customize → understand → export outcome on Android, web, and Linux. Representative module IDs are an engineering choice, not a catalog-wide certificate. Reuse `mandelbrot` and `mandelbulb` for the 2D/3D paths, plus one clearly qualified unverified/inspired entry to test honest disclosure.

For each target, record the build/source identity, device or browser, actual backend, module IDs, exact actions, logs, and saved PNGs. Check search/navigation, edited parameters/view, current formula or qualification, and preserved favorites/presets. Decode saved files and check selected dimensions and visible mathematical content. Compare the export with the edited viewer state without demanding pixel identity across different output resolutions. No silent loading/gradient/placeholder substitution counts as a mathematical export pass. Preserve bounded approximate catalog previews with explicit labels.

| Target | Planned verification path | Complete-journey status |
|---|---|---|
| Web | Extend the existing Playwright targets in `test/playwright/` to exercise an actual PNG download from the production web build. Verify downloaded bytes and browser errors, not just a first-frame marker. Build with `flutter build web --no-pub`. Record the supported browser used. | Unverified |
| Linux | Extend `integration_test/flows/user_flows_test.dart` and the existing export tests to save/decode real artifacts. Run `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` plus the exact added export target. | Unverified |
| Android | Exercise the same flow on a named Android device and verify the actual MediaStore destination and visible/readable exported image. Record the selected device ID and the exact integration command. Emulator/software rendering and physical-device results remain separate. | Unverified |

Existing widget, compiled-shader, golden, and browser smoke results remain useful lower-level evidence. They do not close this complete journey. Unsupported environments or missing devices are reported as gaps, never substituted with fabricated results. macOS/Windows, video export, and whole-catalog mathematical certification are excluded from this new gate.

## Limits and outstanding coverage

Real-device MediaStore and wallpaper verification, real-device gesture feel/deep zoom, and broad visual audit work remain listed in `TODO.md` and the current platform/audit documents. The visual-inventory validator checks ID counts, references, and shader paths; it does not prove GPU image quality, a first viewer frame, or native CPU-formula coverage. The inventory records capture/runtime-preview evidence for 187 of 1,028 Explore rows; 841 remain uncaptured. All 200 research definitions have no app renderer. First-view evidence is recorded for 14 Explore rows; `cpu_formula` is `not audited` in 1,145 of the 1,228 rows. These totals describe recorded inventory evidence, not a fresh GPU or artifact qualification. Historical run counts in `PRD.md` are dated snapshots, not current verification receipts. No claim is made here that these checks ran during documentation maintenance.
