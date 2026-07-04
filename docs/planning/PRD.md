# PRD.md — Flutter Fractal Forge Production Readiness Document
*Authored: 2026-02-17 by Sidon (fractal domain lead)*  
*Historical readiness snapshot. Selected coverage/policy rows were refreshed on 2026-06-30 from live files and tests; older validation counts remain dated evidence, not current gate claims.*

---

## 1. Current State Audit

### 1.1 Validation Runs

#### flutter test
```
Command: flutter test -r expanded
Date: 2026-02-17 21:15 CST
Result: 336 PASSED, 3 SKIPPED, 0 FAILED
Skipped:
  - generate_catalog_thumbnails_test.dart: "Manual utility test; not meant for CI"
  - shader_benchmark_test.dart: "Benchmark requires a real device"
  - catalog_thumbnail_audit_test.dart: (implied, was part of run)
Final line: "00:14 +336 ~3: All tests passed!"
```

#### flutter analyze
```
Command: flutter analyze
Date: 2026-02-17 21:22 CST
Result: No issues found! (ran in 2.9s)
```

#### scripts/headless-emulator-test.sh (integration_test/app_test.dart)
```
Command: scripts/headless-emulator-test.sh
Date: 2026-02-17 21:15 CST
AVD: fractal_test | API: 34 (Android 14) | GPU: swiftshader_indirect
Result: 7 PASSED, 0 FAILED
Final line: "02:00 +7: All tests passed!"
Tests passed:
  ✓ Catalog displays fractal modules (196 modules in this 2026-02 validation; current live catalog is 974 production fractals / 981 debug-test registry modules as of 2026-07-02)
  ✓ Navigate to fractal viewer and back
  ✓ Navigate to each fractal module viewer (8 sampled)
  ✓ Search filters catalog
  ✓ Search then open module shows renderer and actions
  ✓ Viewer drag + pinch updates fractal view state
  ✓ Logger captures events correctly
```

#### flutter build appbundle --release
```
Command: flutter build appbundle --release
Date: 2026-02-17 21:20 CST
Result: ✓ Built build/app/outputs/bundle/release/app-release.aab
Size: 55.7 MB
```

---

### 1.2 Feature-area coverage snapshot

| Feature area | Dart Files | Unit/Widget Tests | Integration Tests | Status |
|---|---|---|---|---|
| catalog | 3 | 6 test files | user_flows, app_test | ✅ Covered |
| renderer | 15 | fractal_renderer_widget_test, gpu_health_probe_side_effects | emulator_gpu_proof, render_validation | ✅ Covered |
| viewer | 10 | fractal_viewer_screen_widget_test (24 tests) | user_flows, viewer_navigation, viewer_hold | ✅ Covered |
| gestures (gesture_handler.dart) | 1 | fractal_renderer_gesture_test (16 tests) | cpu_fallback_gestures, double_tap_anchor | ✅ Covered |
| controls | 1 | fractal_controls_widget_test (2 files) | user_flows (controls section) | ✅ Covered |
| formulas | 4 | frm_parser_test, cpu_formula_coverage_test | — | ✅ Covered |
| history | 4 | history_entry_test, history_provider_test, history_store_test | — | ✅ Covered |
| presets | 1 | preset_sheet_widget_test, preset_sheet_comprehensive_test | user_flows (save/apply) | ✅ Covered |
| minimap | 0 | — | — | ❌ Not present in current tree |
| onboarding | 1 | onboarding_test | — | ✅ Covered |
| export | 3 | export_service_test, export_options_sheet_widget_test, custom_export_dimensions_test | user_flows (export sheet opens) | ⚠️ Partial — Android MediaStore path still needs device coverage |
| wallpaper | 1 | wallpaper_options_test, wallpaper_service_test | — | ✅ Covered |
| settings | 1 | accessibility_settings_screen_test, renderer_settings_service_test | — | ✅ Covered |
| debug | 5 | crash_reporter_test (12 tests) | — | ✅ Covered |
| auto_explore | 3 | auto_explore_control_status_test, auto_explore_controls_test, auto_explore_runtime_state_test, auto_explore_service_test, auto_explore_zoom_planner_test | — | ✅ Covered |
| home | 1 | home_screen_widget_test (6 tests) | — | ✅ Covered |


---

## 2. Feature Gap Matrix

| Feature | Current Status | Acceptance Criteria | Priority |
|---|---|---|---|
| Catalog grid/list view | ✅ Shipped | 209 modules, search, category headers, preference persisted | P0 |
| Catalog thumbnails | ⚠️ Audit aligned | Launch Thumbnail Standard: 320×320 bundled PNGs; staged smoke output may use 256×256 | P0 |
| GPU renderer (escape-time) | ✅ Shipped | 196 shaders pass audit (196/196 PASS, edge 0.01–0.99) | P0 |
| CPU fallback auto-switch | ✅ Shipped | GPU health fallback triggers after 2 invalid frames; deep-zoom CPU Precision is routed by `PrecisionLadderPolicy` | P0 |
| Smooth escape-time coloring | ✅ Shipped | `float(it) - log2(log2(...))` on 10 core shaders | P0 |
| Perturbation theory (Mandelbrot) | ✅ Shipped | double-double CPU ref orbit + delta GPU shader, ~1e30 range | P1 |
| Perturbation (all escape-time) | ⚠️ Planned | Julia, Burning Ship, Celtic, Buffalo, Tricorn, Phoenix, Multibrot 3/4/5 | P1 |
| Pan gesture | ✅ Shipped | Rubber-banding at ±3.0; no lag; momentum on release | P0 |
| Pinch-to-zoom | ✅ Shipped | Anchored to midpoint; momentum; clamped [1e-10, 1e10] | P0 |
| Double-tap zoom | ✅ Shipped | 2× zoom anchored to tap coordinate | P0 |
| Two-finger tilt | ✅ Shipped | ±67.5° clamp; tested in gesture suite | P1 |
| Two-finger rotation | ✅ Shipped | 0.12 rad threshold; lock-out during zoom/pan | P1 |
| Rotation/tilt feel | ⚠️ Needs tuning | Needs real-device feel test | P1 |
| Presets save/restore | ✅ Shipped | pan+zoom+module+julia-C round-trip ±1e-6 | P1 |
| Factory presets | ⚠️ Partial | Mandelbrot + Julia shipped; need 5 more categories | P1 |
| History navigation | ⚠️ Partial | Back button in viewer works; no history list UI | P2 |
| Export PNG/JPG/WebP | ✅ Shipped | ExportService generates filenames, applies wallpaper styles | P0 |
| Export to MediaStore (gallery) | ⚠️ Untested | Needs real-device test — MediaStore write not in emulator suite | P0 |
| Wallpaper set | ⚠️ Partial | WallpaperManager code exists; no integration test | P1 |
| Onboarding | ✅ Shipped | 3-step walkthrough; skippable; version-gated | P0 |
| Minimap | ❌ Not present | No active `lib/features/minimap` module found in the current tree | P2 |
| Settings (renderer backend) | ✅ Shipped | Auto/CPU/GPU modes; persisted in SharedPreferences | P1 |
| Settings (accessibility) | ✅ Shipped | High contrast + reduced motion | P1 |
| Localization EN | ✅ Shipped | Complete | P0 |
| Localization ES | ✅ Covered | `app_es.arb` has parity with `app_en.arb` (431 keys each) | P2 |
| In-app diagnostic logger | ✅ Shipped | Export as text/JSON from debug screen | P2 |
| Auto-explore | ✅ Covered | Service, controls, runtime state, and zoom planner have focused tests | P2 |
| FRM formula editor UI | ❌ Not shipped | Code exists; no production-accessible UI surface | P3 |
| Accessibility (TalkBack) | ✅ Shipped | 221 catalog items have semantic labels (accessibility_test) | P0 |
| Touch targets 48×48 dp | ✅ Shipped | accessibility_test passes | P0 |
| High contrast mode | ✅ Shipped | accessibility_test passes | P1 |

---

## 3. Production Hard Gates

| Gate | Result | Evidence |
|---|---|---|
| `flutter test`: 0 fail, exact count | ✅ PASS | 336 passed, 3 skipped, 0 failed (2026-02-17 21:15) |
| `flutter analyze`: No issues found | ✅ PASS | "No issues found! (ran in 2.9s)" (2026-02-17 21:22) |
| `headless-emulator-test.sh`: all pass | ✅ PASS | 7/7 passed on API 34 emulator (2026-02-17 21:17) |
| `flutter build appbundle --release`: size reported | ✅ PASS | 55.7 MB (2026-02-17 21:20) |
| Cold start on API 34: no crash in 2 min | ✅ PASS | Integration test ran 120 s; 0 FATAL EXCEPTION, 0 ANR; catalog showed 196 modules at 2026-02 validation; current live count is 974 production fractals |
| All 5 gesture types respond: no freeze | ✅ PASS | Gesture test 16/16; integration test "drag+pinch changed pan/zoom" ✓; tilt test ✓ |
| Catalog loads: no blank state | ✅ PASS | Integration: "Catalog shows 196 modules" at 2026-02 validation; current live count is 974 production fractals |
| Viewer loads within 3 s: no black screen | ✅ PASS | first_frame_ms=89 (Mandelbrot GPU, first compile); first_frame_ms=1 (cache hit) |
| Export flow: file created, no crash | ⚠️ PARTIAL | Export sheet opens + format options visible ✓; actual MediaStore write not tested on emulator |
| AndroidManifest: 0 uses-permission (main) | ✅ PASS | `android/app/src/main/AndroidManifest.xml` has 0 `<uses-permission>` tags; INTERNET in debug/profile only |

**Overall gate status:** 9/10 PASS, 1 PARTIAL (export file creation).

---

## 4. Known P0/P1 Issues

### P1-001: `full_screenshots_test.dart:168` — Julia card not found
**File:** `integration_test/full_screenshots_test.dart`  
**Line:** 168  
**Symptom:** `StateError: No element` when calling `findModuleCard('Julia').first`  
**Root cause:** `findModuleCard` uses `find.text('Julia')` as an ancestor match. On emulator in default grid view, the "Julia" card is not in the initial viewport and `find.text` does not scroll to it. The finder returns empty.  
**Reproduction:**
```bash
scripts/headless-emulator-test.sh flutter test integration_test/full_screenshots_test.dart \
  -d emulator-5554 --reporter expanded --plain-name 04_viewer_julia
```
**Impact:** `04_viewer_julia`, `06_view_presets`, and any test that calls `findModuleCard('Julia')` fail.  
**Fix needed:** Scroll to card before tapping; use `tester.scrollUntilVisible(find.text('Julia'), 200)` or use a ValueKey-based finder consistent with `app_test.dart`.

---

### P1-002: `gpu_health_probe skipped reason=to_image_timeout` (emulator only)
**File:** `lib/features/viewer/viewer_gpu_health.dart`  
**Line:** 302  
**Symptom:** GPU health probe's `RepaintBoundary.toImage()` times out on SwiftShader emulator. Probe logs `skipped reason=to_image_timeout` instead of pass/fail.  
**Observed in:** Integration test run 2026-02-17 — appears on modules: mandelbrot (first open), burning_ship, multibrot3, nova_julia, fatou  
**Reproduction:** Run any integration test on `emulator-5554` with `swiftshader_indirect`; GPU probe fires ~6 s after viewer opens; SwiftShader `toImage()` does not return within probe timeout.  
**Impact on emulator:** Health probe cannot confirm GPU pass → subsequent probe fires → probe marked skipped (not failed). App does NOT fall back to CPU, so rendering continues GPU. This is correct behavior (probe timeout ≠ GPU failure) but produces noisy logs and delays accurate health confirmation.  
**Impact on real device:** None observed — `toImage()` returns in < 200 ms on Vulkan/OpenGL hardware.  
**Fix needed:** Increase probe `toImage()` timeout on emulator via `--dart-define=EMU_PROBE_TIMEOUT_MS=8000`, or detect SwiftShader via `gl_renderer` string and skip `toImage()` validation, relying on non-black ratio sampling only.

---

### P2-001: Spanish localization parity — resolved in current tree
**File:** `lib/l10n/app_es.arb`  
**Evidence:** `app_en.arb` and `app_es.arb` each define 431 message keys; no key gap found.  
**Remaining risk:** Translation quality still needs human language review before release.

---

### P2-002: `full_screenshots_test.dart` — Mandelbulb card not always visible
**File:** `integration_test/full_screenshots_test.dart`  
**Line:** 149  
**Symptom:** `findModuleCard('Mandelbulb')` can fail if the 3D section header is not in viewport at pump time. Not consistently reproducible — depends on catalog initial scroll position.  
**Impact:** `03_viewer_mandelbrot_3d` test is flaky.

---

### P2-003: History module test coverage gap — resolved in current tree
**Files:** `lib/features/history/*.dart`  
**Evidence:** `history_entry_test.dart`, `history_provider_test.dart`, and `history_store_test.dart` cover identity, navigation, persistence, corruption handling, and caps.  
**Remaining risk:** Integration coverage for full viewer history flows can still deepen later.

---

### P2-004: Minimap gap — feature not present in current tree
**File:** `lib/features/minimap/minimap_widget.dart` is not present.  
**Impact:** Do not spend test/polish work here unless the minimap feature is restored.

---

## 5. Render Quality Audit

*Source: integration_test/app_test.dart run on emulator-5554, API 34, SwiftShader indirect, 2026-02-17 21:17–21:19 CST.*  
*Source: fractal_render_audit_test.dart (CPU renderer), 196/196 modules passed the 2026-02 variance check. Current live catalog count is 974 production fractals (981 debug/test registry modules including 7 diagnostics).*

### 5.1 Mandelbrot Coloring
- **Backend:** GPU (`shaders/mandel_step_smooth.frag`)
- **First frame:** 89 ms (cold, includes shader compile 58 ms)
- **Cache hit frame:** 1 ms
- **Center pixel on emulator:** RGB(244, 0, 211) — purple/magenta — smooth escape-time coloring is active
- **Non-black ratio:** 0.8725 (87.25% of pixels non-black) — correct; Mandelbrot interior set is ~12.7% of canonical view
- **GPU health:** `pass=true`, `centerNonBlack=true`, `histogramSane=true`, `sampleCount=3780`
- **Observation:** Smooth coloring eliminates iteration banding completely. Color is palette-driven via `sampler2D uPalette`. On emulator the purple/magenta hue is specific to the default palette at the initial zoom; this is expected and correct.

### 5.2 Julia Shapes
- **Backend:** GPU (`shaders/nova_julia_gpu.frag` and others)
- **First frame:** nova_julia 40 ms (shader compile 16 ms)
- **Shape observation:** Julia and nova_julia modules visible in catalog at 320×320 thumbnail; render audit shows edge=0.93 for nova_julia — correct feature-rich output (edge density close to 1.0 means rich structure near the viewport edge)
- **Direct viewer test:** Search→open Burning Ship Julia — `first_frame_ms=0` (cache hit), viewer loads correctly, `find.byType(FractalRenderer)` finds widget
- **Concern:** `04_viewer_julia` integration screenshot test fails (P1-001) so we cannot confirm a live screenshot of Julia on emulator this cycle

### 5.3 Tilt Feel
- **Tested:** Unit test `fractal_renderer_gesture_test.dart` line 407 — "Two-finger tilt is clamped to max tilt angle"
- **Max tilt:** ±67.5° (`_kTiltMaxRadians = 67.5 * π / 180`)
- **Emulator observation:** Tilt gesture works mechanically (angle clamped correctly, test passes). Real-device feel has not been tested this cycle — SwiftShader cannot render 3D rotation feedback smoothly. Real device test deferred.
- **Risk:** Tilt feels "slippery" on real devices if the 0.0009 rad/px multiplier is too high or too low. No human has tested this since the perturbation refactor.

### 5.4 Deep Zoom Behavior
- **Policy:** `PrecisionLadderPolicy`
  - Mandelbrot: double-float GPU preview handles up to 1e12, then CPU Precision when native CPU support is available
  - Perturbation-enabled (julia, burning_ship, celtic, buffalo, tricorn, phoenix): GPU preview handles up to 1e30
  - Unknown/default: GPU stays approximate; synthetic CPU previews are not labeled CPU Precision
  - Hysteresis: 2 consecutive CPU-eligible samples before CPU Precision activation
- **Test coverage:** `precision_ladder_policy_test.dart`, `deep_zoom_precision_policy_test.dart`, and `deep_zoom_quality_test.dart` cover threshold/status routing
- **Emulator observation:** At zoom=5.0 (test default for thumbnail generation), all 196 escape-time shaders produce non-gradient output (render audit: 196/196 PASS, edge 0.01–0.99)
- **Actual deep zoom test:** Not feasible on SwiftShader at 1e14+; at those zoom levels SwiftShader is too slow to render in test timeouts. Real-device deep zoom untested this cycle.
- **Note on deltoid/eisenstein:** These two modules have very low edge entropy (deltoid: 0.07, eisenstein: 0.01) at the default viewport. This is likely correct — both are highly structured tiling fractals that appear nearly blank at default zoom. Audit passes them but they deserve visual QA on real device.

### 5.5 Shader Compile Times (emulator baseline)
| Shader | Cold compile (ms) | Cache hit (ms) |
|---|---|---|
| mandel_step_smooth.frag | 58 | 0 |
| burning_ship_gpu.frag | 32 | 0 |
| tricorn_gpu.frag | 32 | 0 |
| celtic_gpu.frag | 18 | 0 |
| buffalo_gpu.frag | 17 | 0 |
| nova_julia_gpu.frag | 16 | 0 |
| multibrot3_gpu.frag | 216 | 0 |
| fatou_gpu.frag | 98 | 0 |

*multibrot3 compile at 216 ms is the slowest observed. On real Vulkan hardware this will be significantly lower.*

---

## 6. Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| MediaStore export fails on Android 10+ (scoped storage) | High | P0 — users cannot save images | Real-device export test before release; verify `MediaStore.Images.Media.insertImage()` path |
| GPU health probe timeout on slow real devices | Low | P2 — noisy logs, delayed health confirmation | Increase timeout; detect GPU tier at startup |
| Mandelbulb/Mandelbox CPU render freeze | Low | P1 — ANR if 3D ever routes to CPU | Backend policy keeps 3D on GPU even in CPU-only mode; keep regression coverage |
| Perturbation theory for all escape-time fractals not shipped | Certain | P2 — deep zoom breaks for 9 non-Mandelbrot escape-time fractals | Prioritize; shared `escape_time_perturb_gpu.frag` with uFormula selector already planned |
| Spanish translation quality | Medium | P2 — awkward localized UX | Key parity exists; schedule human language review before release |
| History module regression | Low | P2 — navigation/persistence regressions | Unit coverage exists; add end-to-end viewer-history coverage if this becomes launch-critical |
| `full_screenshots_test.dart` Julia finder bug | Certain | P1 — CI test fails | Fix scrollUntilVisible; low effort |
| Emulator probe timeout noise | Certain (emulator only) | P3 — confusing logs | Add EMU_PROBE_TIMEOUT_MS dart define |

---

## 7. Milestone Plan to 1.0

### M0: Foundation (COMPLETE as of 2026-02-17)
- [x] 336 unit/widget tests passing, 0 failures
- [x] flutter analyze: No issues
- [x] Headless emulator integration test: 7/7 pass (API 34)
- [x] AAB builds clean at 55.7 MB
- [x] Launch Thumbnail Standard aligned: bundled catalog assets target 320×320; staged smoke output may use 256×256
- [x] GPU-primary rendering + CPU auto-fallback
- [x] Smooth escape-time coloring on 10 core shaders
- [x] Perturbation theory (Mandelbrot)
- [x] All 5 gesture types tested and passing

### M1: P0/P1 Bug Fixes (Target: 1 week)
- [ ] Fix `full_screenshots_test.dart` Julia finder (P1-001) — `scrollUntilVisible` fix
- [ ] Real-device export to MediaStore — test and confirm file creation + gallery write
- [ ] Fix `gpu_health_probe` timeout on emulator (P1-002) — configurable timeout dart-define
- [x] Resolve Spanish localization key parity (P2-001)
- [x] Add test coverage for history module

### M2: Feature Completion (Target: 2 weeks)
- [ ] Perturbation theory for all escape-time fractals (Julia, Burning Ship, Celtic, Buffalo, Tricorn, Multibrot 3/4/5, Phoenix) — shared `escape_time_perturb_gpu.frag`
- [x] Auto-scale iterations by zoom (G3)
- [ ] Color cycling (G15) — palette texture already in place
- [ ] Bookmark locations (N4) — integrate into history
- [ ] Factory preset expansion (5+ categories)
- [ ] Re-scope minimap only if the feature is restored

### M3: Quality Bar (Target: 3 weeks)
- [ ] Real-device tilt feel tuning (test on Pixel 6a and Samsung A54)
- [ ] Real-device deep zoom test (Mandelbrot to 1e20; Julia to 1e30 with perturbation)
- [ ] Wallpaper integration test on real device (WallpaperManager API 27+)
- [x] Add test coverage for settings and auto_explore
- [ ] deltoid/eisenstein visual QA — confirm blank at default zoom is expected

### M4: Release Gate (Target: 4 weeks)
- [ ] All 10 hard gates GREEN (currently 9/10)
- [ ] 0 known P0/P1 bugs
- [ ] Play Store listing complete (already done per ../store/play-store-checklist.md)
- [ ] Privacy policy published
- [ ] Internal test track → Closed beta → Production rollout 20%

---

*Document maintained by Sidon. Update after every sprint with new gate results.*
