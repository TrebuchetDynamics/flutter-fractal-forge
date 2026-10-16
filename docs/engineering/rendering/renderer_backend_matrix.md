# Renderer Backend Capability Matrix (2026-06-03)

## Verdict legend

- **PASS**: backend renders with sane output + progression checks.
- **PARTIAL**: backend works with limits or missing complete measurements.
- **FAIL**: backend unavailable or invalid output.

## Environments

| Environment                                                    | GPU                  | CPU fallback | Verdict                             | Reason                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| -------------------------------------------------------------- | -------------------- | ------------ | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Android emulator (`ranchu`/`emulation`, `sdk_gphone64_x86_64`) | Partial              | Pass         | **PASS (overall)**                  | Deterministic policy routes emulator to CPU (`android_emulator`) for stable output; GPU measurable via probe path but not default.                                                                                                                                                                                                                                                                                                         |
| Real Android device                                            | Unavailable          | Unavailable  | **FAIL (not testable in this run)** | No physical device connected in this session (`adb devices` only listed emulator).                                                                                                                                                                                                                                                                                                                                                         |
| Web JS (Chrome build target)                                   | Pass in Chrome smoke | Unknown      | **PARTIAL (runtime viable)**        | `flutter build web --release` succeeded; Chrome widget tests passed; served `build/web` booted through onboarding/catalog and opened a catalog card into a GPU-labelled viewer. Follow-up smoke after manifest-gated thumbnails reported `thumbnail404Count: 0`. Not production-complete: CPU precision fallback/export/share/deep-zoom browser behavior still unmeasured, and headless Chromium used software WebGL/SwiftShader warnings. |
| Web Wasm (`flutter build web --wasm`)                          | Unknown              | Unknown      | **PARTIAL (buildable)**             | Follow-up on 2026-08-02 with Flutter 3.44.6 built successfully; browser runtime, renderer behavior, and fallback paths remain unvalidated.                                                                                                                                                                                                                                                                                                 |

## Deterministic backend policy

Priority order implemented:

1. `forced_by_flag` (`FORCE_CPU_FALLBACK=true`)
2. `manual_toggle`
3. `module_unsupported` (non-2D)
4. `android_emulator`
5. `gpu_health_check_failed`
6. `deep_zoom_precision`
7. GPU healthy path (`none`)

Policy output is exposed in:

- logs (`[renderer] backend_decision backend=... reason=...`)
- viewer status text (release-safe wording)
- GPU debug JSON report (`backendReasonCode`)

## Web validation slice (2026-06-03)

Verdict: the Flutter web port is viable for the JavaScript browser target as an interactive rendering smoke, but not yet viable as a fully shippable web port.

Validated:

- `flutter build web --release` -> `✓ Built build/web`.
- `flutter test -d chrome test/renderer/precision_ladder_policy_test.dart test/fractal/fractal_renderer_widget_test.dart test/fractal/fractal_renderer_gesture_test.dart test/fractal/fractal_viewer_screen_widget_test.dart` -> `All tests passed!`.
- Headless Chromium served from `build/web`:
  - onboarding rendered;
  - `Skip` reached catalog with `464` modules visible;
  - clicking the first catalog card opened a viewer labelled `3D Fractal` with `GPU · z=1.00 · it=260`;
  - catalog-to-viewer screenshot changed-pixel ratio was `0.9959`, with the viewer screenshot `bright_ratio=0.7075`.

Follow-up validation after manifest-gated thumbnail loading:

- `flutter analyze` -> `No issues found!`.
- `flutter build web --release` -> `✓ Built build/web`.
- Fresh-profile headless Chromium served from `build/web` -> `thumbnail404Count: 0`, `networkErrorCount: 0` while still reaching catalog and viewer.

Known gaps from the same run:

- Headless Chromium logged software WebGL/SwiftShader and `ReadPixels` stall warnings; this proves browser rendering, not hardware GPU performance.
- Export/share flows, real-browser hardware GPU performance, CPU precision fallback, and deep-zoom browser behavior remain unvalidated.

Follow-up build validation on 2026-08-02 (Flutter 3.44.6):

- `flutter build web --release` -> `✓ Built build/web` and reported a successful Wasm dry run.
- `flutter build web --wasm` -> `✓ Built build/web`.
- Wasm browser runtime and renderer behavior remain unvalidated.

## Visual correctness checks

Implemented deterministic checks in `render_validation.dart`:

- center pixel non-black
- non-black histogram ratio sanity
- frame progression across frame pair
- iteration delta visibility across frame pair

Coverage:

- CPU path: validated each CPU render cycle (debug logs)
- GPU path: measured from live `RenderRepaintBoundary` frame pair probe

## Release-safe UX behavior

### Kept

- Debug controls remain in debug builds (`kDebugMode` overlays + indicators).

### Production-safe changes

- Removed confusing internal labels from always-on renderer surfaces.
- Added concise fallback copy: "Using stable renderer..." / "Stable renderer active".
- Renderer indicator ribbon now debug-only.

## Evidence references

- Logs directory: `agent_test_logs/release_pipeline_20260212/`
- Screenshots directory: `agent_test_logs/release_pipeline_20260212/screens/`

## Linux image-creation journey (2026-10-16)

Verdict: **PARTIAL** for the accepted Linux journey. This is local desktop GPU evidence, not cross-platform parity or overall release qualification.

Host/backend identity:

- Ubuntu 24.04.4 LTS, Linux 7.0.0-31-generic; Flutter 3.44.2 / Dart 3.12.2.
- AMD Radeon RX 6800 XT (`amdgpu`, PCI `1002:73bf`), Mesa 25.2.8, OpenGL 4.6. `glxinfo` reported `AMD Radeon RX 6800 XT (radeonsi, navi21, LLVM 20.1.2, DRM 3.64, 7.0.0-31-generic)`; this is accelerated rendering, not llvmpipe/software.
- Integration logs reported `backend=gpu` and successful shader loads for Mandelbrot and Mandelbulb. Mandelbrot passed its GPU health probe; Mandelbulb used the logged `3d_gpu_path` and appropriately skipped the 2D-only health probe.

Executed evidence:

- `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded` -> 12 passed, 1 explicit skip. Barnsley Fern's runtime `pan.y=0.5` disagrees with its declared `defaultCenterY=0.2`; its default-view assertion is skipped and remains a separately identified gap.
- `flutter test integration_test/flows/user_flows_test.dart -d linux --dart-define=FORCE_GPU_RENDER=true --reporter expanded --plain-name 'Linux 2D and 3D journey saves edited mathematical PNG artifacts'` -> passed. The test browses to Mandelbrot (`core.mandelbrot`) and Mandelbulb (`core.mandelbulb`), edits each viewer by gesture, inspects the current formula and qualification, saves through the viewer export UI, decodes the PNG at selected HD dimensions (1280×720), and asserts sampled image color variation. It also checks the edited pan/zoom/rotation remain unchanged and that the pre-existing favorite IDs and user preset survive. Placeholder renderer mode is required to be disabled; backend and shader logs confirmed the GPU paths.
- The journey uses a fresh temporary Linux export directory and removes it after numerical checks; no PNGs are retained for composition review.

Remaining qualification gaps: no inspired/unverified representative was exported; the journey was English-only; no saved artifact was retained for human visual review. Device and fallback backends, alternate locales, and broader catalog mathematical correctness are not implied by this evidence. The Linux accepted journey therefore remains partial, not a parity claim.
