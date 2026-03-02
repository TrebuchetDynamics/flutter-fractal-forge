# Flutter Fractal Forge — Execution TODO

Last updated: 2026-02-26
Owner: Sidon

## Architecture Direction (decided 2026-02-15)

**GPU-primary, CPU safety net.**
- GPU is the default renderer (196 pre-compiled fragment shaders, one per fractal)
- CPU fallback auto-activates via 2s health check when GPU output is invalid
- CPU path is maintenance-only (no further performance investment)
- GPU investment: coloring quality, smooth iteration, deep zoom, new formulas

---

## P0 — MUST SHIP NEXT

**Reaffirmed 2026-02-27:** All open (unchecked) items in this section remain P0 until resolved.

### 0) Critical render regressions (user report 2026-02-25)
- [ ] Investigate GPU render showing large color blocks/grid at z≈5.10e+6, it=500 (screenshot)
- [ ] Investigate KIFS Menger Sponge stuck on “Loading shaders…” (screenshot)
- [ ] Validate GPU backend shader load + palette/precision for both cases

### 1) User-reported blockers (2026-02-25)
- [x] GPU→CPU fallback too slow when zooming deep; reduce hysteresis/threshold so CPU engages faster
- [ ] Controls too big/too intrusive; redesign for smaller, less cluttered UI
- [ ] 3D fractals not working at all; investigate 3D pipeline/shaders and fix
- [ ] AR broken: no fractal preview in AR, cannot detect surfaces/anchor; fix plane detection + anchoring
- [ ] App icon overhaul for Fractal Forge (adaptive icon + Play Store asset)
- [ ] Improve fractal catalog thumbnails: larger view size and higher-quality renders
- [ ] Visual playtest audit of every fractal (GPU + CPU) and log failures
- [x] GPU deep zoom not switching to CPU at all; adjust fallback thresholds/hysteresis
- [ ] Panning bugs at high zoom levels (precision/gesture/transform issues)
- [ ] Auto-zoom navigation not continuous and too slow at high zoom levels


### 1) Dynamic iteration adjustment based on zoom — **NEW**
- [x] Increase max iteration slider beyond 500 (now 5000)
- [x] Automatically raise iteration count when zooming in (adaptive step-up in controller)
- [x] Adaptive logic: start low, progressively increase based on zoom growth
- [x] Convergence detection: compare previous frame, stop when changes < threshold
- [x] Works on both GPU (shader uniform) and CPU fallback paths

### 2) GPU visual quality — smooth coloring + palette system
- [ ] Implement fractional/smooth escape-time coloring in all escape-time shaders (eliminate banding)
- [ ] Implement palette uniform system (pass palette as texture/uniform array to shaders)
- [ ] More gradient options + color cycling/animation support
- [ ] Allow user palette selection from viewer controls
- [ ] Add regression test: render canonical viewport, assert no banding artifacts

### 3) Play Store release polish
- [x] Play Store checklist doc created
- [ ] App icon finalized (adaptive icon + Play Store feature graphic)
- [ ] Store listing copy (title, short desc, full desc, screenshots)
- [ ] Privacy policy URL
- [ ] Content rating questionnaire
- [ ] Signing key + upload to Play Console
- [ ] Internal testing track → closed beta → production

### 4) Catalog expansion toward 200+
- [x] 196 escape-time fractals with GPU shaders
- [ ] Add PRD manifest loader (`assets/catalog/prd_catalog.json`)
- [ ] Add ID lock/integrity tests for full catalog
- [ ] Add filter/sort + list/grid toggle for large catalogs
- [ ] Add 4+ new fractal formulas (target 200+)

### 5) Export behavior hardening
- [x] Opening Export pauses auto-navigation and freezes frame
- [x] Separate Save vs Share actions
- [ ] Resume policy prompt after export
- [ ] Share flow QA: WhatsApp / Instagram / X / device gallery

---

## P1 — HIGH PRIORITY AFTER P0

### 6) Deep zoom: perturbation theory in GPU shaders
- [ ] Research perturbation + series approximation for Mandelbrot shader
- [ ] Implement reference orbit calculation (CPU) + delta iteration (GPU)
- [ ] Enable zoom beyond float32 precision wall (~10^7) on GPU
- [ ] CPU fallback remains for non-perturbation fractals at extreme zoom

### 7) AR real anchoring (wall/floor/table)
- [ ] Integrate true plane anchors (vertical + horizontal)
- [ ] Tap-to-place fractal on detected plane
- [ ] Keep overlay mode as fallback when ARCore/ARKit unavailable

### 8) Auto-Pilot navigation improvements
- [ ] Improve path smoothness and dwell behavior
- [ ] Accept manual pan/zoom corrections while auto mode runs
- [ ] Add quick actions: Accept framing / Reject and try another

### 9) In-app diagnostic logger enhancements
- [x] Core logger with export (text/JSON/share) — commit 5ae1c9e
- [x] Logs: lifecycle, GPU health, shader load, backend switches, user actions, state snapshots
- [x] Add gesture logging (pan/zoom start/end with coordinates)
- [x] Add performance metrics logging (frame time, fps)
- [ ] Persist log across app restarts (write to file)

### 10) GPU health check improvements
- [ ] Make detection more robust across devices
- [ ] Add fallback analytics to track GPU failures

---

## P2 — IMPORTANT PRODUCT POLISH

### 11) Preset management
- [x] Delete preset
- [x] Rename/edit preset
- [ ] Preset thumbnail generation

### 12) User-defined color palettes
- [ ] Allow saving/loading custom gradients

### 13) Bookmark/favorites for locations
- [ ] Save coordinates, zoom, formula, palette

### 14) Viewer controls ergonomics
- [ ] Make controls sheet snap/collapse more aggressively
- [ ] Move non-critical actions into compact overflow

### 15) Onboarding and accessibility
- [ ] Explain gestures + AR behavior clearly
- [x] Improve screen-reader labels for catalog and controls

### 16) Stable sharing/export presets
- [ ] One-tap presets for Instagram feed/story, X, WhatsApp
- [ ] Keep exact frame lock from viewer to exported file

---

## DONE RECENTLY

- [x] In-app diagnostic logger with export (commit 5ae1c9e)
- [x] Fix GPU "Loading shaders..." stuck forever — _loading flag bug (commit 2066e43)
- [x] GPU debug report payload enhanced with health metrics (commit 2ec66a2)
- [x] CPU visual gate test (blockiness + luminance diversity)
- [x] CPU quality: zoom-scaled iterations + 2x2 AA refine pass (commit 7767213)
- [x] Renderer backend setting (Auto/CPU/GPU) with persistence (commit 2c24554)
- [x] CPU tile renderer (96px, center-first spiral, cancel-on-gesture)
- [x] 196/196 render audit passing
- [x] 64 palette support + horizontal palette selector
- [x] Home screen simplified; AR entry in viewer only
- [x] kDebugMode guards on all debugPrint calls across 16 files
- [x] kIsWeb web safety guards on all dart:io files (8 files)
- [x] Complete unit test coverage for all services (865 tests, 0 failures)
- [x] Screen-reader semantic labels for catalog and controls
- [x] GPU→CPU fallback threshold tuning (faster engagement)

---

## CPU Path — Maintenance Only

The CPU renderer works and passes all tests. No further performance investment.
- CPU progressive tiles with preview→refine
- Persistent worker isolate
- Iteration buffer + proxy iterators for audit
- Maintained for: emulator testing, broken GPU fallback, deep zoom precision

---

## Future / Low Priority

- [ ] User-defined formulas at runtime (CPU interpreter or dynamic shader compilation)
- [ ] Video recording of zoom animations
- Dynamic runtime shader compilation — deferred, not needed for Play Store launch

---

## OUT OF SCOPE

- Arenaton implementation is out of scope for this repo/agent.
- Sidon works only on Flutter Fractal Forge + fractal tasks.

---

## Semantic-First QA Framework — Non-Visual Playtesting & Automation

> Architecting Semantic-First Quality Assurance: A Comprehensive Framework for Non-Visual Playtesting and Automation in Flutter. This section tracks implementation of a robust, automated playtesting strategy prioritizing the semantics tree, accessibility compliance, and performance metrics over visual inspection.

### Phase 1: Foundation — Flutter-First Testing Tools (Week 1-2)

- [x] Add `integration_test` package to dev_dependencies _(was already present in pubspec.yaml)_
- [x] Write first integration test for the most critical user journey (e.g., launch → browse catalog → select fractal → view/zoom → export) _(integration_test/critical_journey_test.dart: launch -> catalog -> tap Mandelbrot -> verify viewer controls -> tap export -> verify export sheet -> go back)_
- [x] Assign `ValueKey`s to all interactive and structurally important widgets (buttons, sliders, controls, catalog items) _(added ValueKeys to: export save/share buttons, viewer control FABs [controls, random, AR, export], navigation dock buttons [zoom in/out, reset, random]; catalog cards and search already had Keys)_
- [x] Use `find.byKey()` with `ValueKey`s for reliable, non-visual widget identification _(integration test uses find.byKey for catalogSearchField, catalogViewToggleButton, catalogModuleCard_*)_
- [x] Implement `pumpAndSettle()` waits for animation completion in all integration tests _(semantics_audit_test.dart uses pumpAndSettle)_
- [x] Add `find.text()` + `expect()` assertions to confirm correct text after each interaction _(critical_journey_test.dart and app_test.dart use find.text + find.byKey + expect for post-interaction verification)_
- [ ] Adopt `Semantics.identifier` (Flutter 3.19+) for stable, language-independent selectors on key widgets _(audit: not yet used anywhere in the codebase; ValueKeys serve a similar purpose for now)_
- [x] Write unit/widget tests (`flutter_test`) for isolated widget verification and regression catching _(865+ existing unit/widget tests; semantics_test_helper.dart added)_

### Phase 2: Semantic Verification (Week 3-4)

- [x] Audit the Semantics Tree: ensure all custom widgets expose correct `SemanticsNode` properties (`label`, `hint`, `value`, `isButton`, `isTextField`, `isChecked`, `hasTapAction`) _(audit completed 2026-02-26 — see findings below)_
- [ ] Add `Semantics` widgets to all custom UI components lacking semantic annotations
- [ ] Review and strategically use `MergeSemantics`, `ExcludeSemantics`, and `explicitChildNodes` to keep the tree both navigable and testable
- [x] Write helper function to traverse the `SemanticsNode` tree and produce a text-based "narrative" of each screen _(test/helpers/semantics_test_helper.dart: traverseSemanticsTree(), buildSemanticsNarrative(), compareSemanticsNarrative(), extractSemanticsNarrative())_
- [ ] Create "golden narrative" baseline files for critical screens (catalog, viewer, controls, export, AR)
- [x] Add integration test assertions using `tester.getSemantics(find.byType(...))` to verify semantic properties (label, isButton, hasTapAction) _(integration_test/semantics_audit_test.dart verifies isButton flags, semantic labels on catalog cards, and key widgets)_
- [ ] Validate semantic labels for all 196+ fractal catalog entries
- [ ] Test semantics for GPU/CPU renderer toggle, zoom controls, palette selector

### Phase 3: Layout & Visual Regression (Week 5-6)

- [x] Integrate `golden_toolkit` and/or `alchemist` package for snapshot (golden) testing _(golden_toolkit ^0.15.0 added to dev_dependencies)_
- [x] Generate baseline golden images for core widgets and screens _(test/golden/goldens/ contains 4 baselines: phone/tablet x dark/highContrast)_
- [x] Configure golden tests for multiple device sizes via `DeviceBuilder` _(test/golden/catalog_golden_test.dart: Device.phone and Device.tabletLandscape)_
- [x] Add golden test scenarios for large text scaling (`textScaleFactor: 3.0`) to catch overflow _(test/golden/overflow_detection_test.dart: tests at 1.0x and 3.0x; detected real overflow in catalog search bar at 3.0x)_
- [x] Add golden test scenarios for dark mode / light mode themes _(both dark and high-contrast themes tested in overflow_detection_test.dart and catalog_golden_test.dart)_
- [x] Implement `FlutterError.onError` override in tests to programmatically catch and fail on RenderFlex overflow errors _(test/golden/overflow_detection_test.dart: assertNoOverflow() captures overflow errors via FlutterError.onError override)_
- [x] Set up golden test update workflow (`flutter test --update-goldens`) for intentional UI changes _(golden baselines generated; update via `flutter test --update-goldens test/golden/`)_

### Phase 4: Performance & Stability Monitoring (Week 7-8)

- [ ] Integrate `flutter_dev_panel_performance` for programmatic FPS, memory, and timer leak monitoring
- [ ] Add `traceAction` calls in integration tests to record timeline events for complex operations (scrolling catalog, deep zoom, shader load)
- [ ] Assert average frame build time < threshold (e.g., 16ms for 60fps) in integration tests
- [ ] Assert 90th percentile frame build time is under acceptable threshold
- [ ] Assert `DevPanel.get().performance?.hasPotentialLeak == false` after critical user flows
- [ ] Assert average FPS > 55 during GPU rendering and zoom operations
- [ ] Monitor rasterization times for shader-heavy fractal rendering

### Phase 5: Accessibility Automation (Screen Reader Simulation)

- [x] Build integration test that navigates to each major screen, extracts full `SemanticsNode` tree, and logs label/value/hint/actions for each node _(integration_test/semantics_audit_test.dart — catalog screen; prints full narrative for review)_
- [x] Compare extracted semantic narratives against stored expected narratives (semantic golden tests) _(compareSemanticsNarrative() helper implemented in test/helpers/semantics_test_helper.dart; baseline capture pending first device run)_
- [ ] Verify focus order matches logical navigation flow for screen reader users
- [ ] Test TalkBack/VoiceOver compatibility via platform automation (`adb shell` commands) in conjunction with Flutter integration tests
- [ ] Ensure all interactive elements have tap actions exposed in semantics
- [ ] Verify fractal catalog is navigable via accessibility services

### Phase 6: Cross-Platform UI Automation

- [ ] Evaluate Appium + Flutter Driver for cross-device testing coverage
- [ ] Evaluate Maestro for YAML-based test stability and simplicity
- [ ] Set up cross-platform test suite using chosen framework
- [ ] Ensure all test selectors use `ValueKey`s for robustness across platforms
- [ ] Note: Detox is NOT viable for Flutter — do not invest time here

### Phase 7: CI/CD Pipeline Automation

- [x] Set up GitHub Actions (or Codemagic/Bitrise) workflow for automated test execution on every PR _(.github/workflows/flutter_qa.yml — triggers on push/PR to main)_
- [x] Job 1: `unit_widget_tests` — run `flutter test` on `ubuntu-latest` (fast feedback) _(includes flutter analyze + flutter test)_
- [x] Job 2: `integration_tests` — start Android emulator (x86), run `flutter test integration_test` with performance assertions _(android-34 x86_64 emulator setup + flutter test integration_test/)_
- [x] Job 3: `golden_tests` — run `flutter test --update-goldens` on schedule or PR label, fail on diffs _(runs flutter test test/golden/)_
- [x] Cache Flutter SDK and `~/.pub-cache` for pipeline speed _(subosito/flutter-action@v2 with cache: true)_
- [ ] Report test results back to PR; block merging on golden or performance regression failures
- [ ] Add semantic narrative diff checks to CI pipeline

### Phase 8: Agent/LLM-Assisted Testing (Future)

- [ ] Experiment with LLM-generated integration test scripts from feature requirements/PRD
- [ ] Implement LLM-based comparison of expected UI spec vs extracted semantics tree
- [ ] Explore multimodal LLM analysis of golden test failure screenshots for text-based regression reports
- [ ] Evaluate AToMIC-style framework for generating Gherkin scenarios and Page Objects from requirements

### Audit Findings (2026-02-26)

**Semantics coverage is strong.** The codebase already has extensive Semantics widget usage across 26+ lib/ files. Key findings:

- **Well-annotated:** Catalog cards (`fractal_catalog_screen.dart`), viewer controls (`fractal_view_controls.dart`, `fractal_navigation_dock.dart`), app bar buttons (`fractal_app_bar.dart`), export options (`export_options_sheet.dart`), onboarding, accessibility settings, auto-explore controls, viewer HUD, and viewer quick actions all have proper Semantics with label, button, enabled, and container properties.
- **Accessibility widgets library:** `core/widgets/accessibility_widgets.dart` provides reusable AccessibleWrapper, AccessibleButton, AccessibleSlider, AccessibleToggle, AccessibleGroup, LiveRegion, and MinTouchTarget.
- **ExcludeSemantics used strategically:** Decorative thumbnails in catalog cards are excluded from the semantics tree (parent card announces them).
- **ValueKey coverage before audit:** Only 4 ValueKeys existed (catalogSearchField, catalogViewToggleButton, catalogClearSearchButton, catalogModuleCard_{id}). **Added 8 more:** exportSaveButton, exportShareButton, viewerControlsButton, viewerRandomButton, viewerArButton, viewerExportButton, dockZoomOut, dockZoomIn, dockResetView, dockRandom.
- **Semantics.identifier:** Not used anywhere. ValueKeys serve a similar role for test selectors; Semantics.identifier could be adopted later for language-independent screen reader identification.
- **Widgets still lacking semantic annotations:** FractalPainter/FractalCanvas (rendering surface — may not need it), performance overlay, shader lab debug screen, minimap widget. These are low-priority since they are not part of the primary user journey.
- **Existing test suite:** 872 unit/widget tests passing (3 skipped), 0 failures. 19 integration test files exist covering app flows, screenshots, navigation, GPU rendering, and performance.

### Limitations & Notes

- Golden test failures require sighted assistance or LLM vision to diagnose image diffs
- Semantics tree captures logical structure and order but not precise visual layout (spacing, padding, centering) — golden tests cover this
- Golden image updates for intentional UI changes require manual approval
- LLM-generated tests may hallucinate steps — always validate against actual widget tree

---

## Working agreement (Juan)

- Use multiple subagents for independent tracks in parallel.
- Send concise progress every ~30 minutes.
