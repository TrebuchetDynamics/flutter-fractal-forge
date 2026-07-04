# Renderer Backend Capability Matrix (2026-06-03)

## Verdict legend
- **PASS**: backend renders with sane output + progression checks.
- **PARTIAL**: backend works with limits or missing complete measurements.
- **FAIL**: backend unavailable or invalid output.

## Environments

| Environment | GPU | CPU fallback | Verdict | Reason |
|---|---|---|---|---|
| Android emulator (`ranchu`/`emulation`, `sdk_gphone64_x86_64`) | Partial | Pass | **PASS (overall)** | Deterministic policy routes emulator to CPU (`android_emulator`) for stable output; GPU measurable via probe path but not default.
| Real Android device | Unavailable | Unavailable | **FAIL (not testable in this run)** | No physical device connected in this session (`adb devices` only listed emulator).
| Web JS (Chrome build target) | Pass in Chrome smoke | Unknown | **PARTIAL (runtime viable)** | `flutter build web --release` succeeded; Chrome widget tests passed; served `build/web` booted through onboarding/catalog and opened a catalog card into a GPU-labelled viewer. Follow-up smoke after manifest-gated thumbnails reported `thumbnail404Count: 0`. Not production-complete: CPU precision fallback/export/share/deep-zoom browser behavior still unmeasured, and headless Chromium used software WebGL/SwiftShader warnings. |
| Web Wasm (`flutter build web --wasm`) | Unavailable | Unavailable | **FAIL** | Explicit Wasm build failed through `share_plus` importing `dart:html` and transitive `ffi`/`win32` imports of `dart:ffi`. |

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
- `flutter test -d chrome test/precision_ladder_policy_test.dart test/fractal_renderer_widget_test.dart test/fractal_renderer_gesture_test.dart test/fractal_viewer_screen_widget_test.dart` -> `All tests passed!`.
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
- Explicit Wasm build failed because current dependencies are not Wasm-compatible (`share_plus`/`dart:html`, `ffi`, `win32`/`dart:ffi`).
- Export/share flows, real-browser hardware GPU performance, CPU precision fallback, and deep-zoom browser behavior remain unvalidated.

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
