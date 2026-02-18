# Refactor-plan.md — Flutter Fractal Forge
*Date: 2026-02-17*

## Objective
Refactor the app for **release stability and maintainability** without changing user-facing behavior.

This plan focuses on:
1. Reducing renderer complexity/risk
2. Raising test coverage on weak modules
3. Hardening export + lifecycle paths required for 1.0

---

## Why refactor now
Current audits show:
- Core paths are strong (`flutter test` passing, analyze clean, emulator smoke passing)
- But several modules have low or zero coverage (history, minimap, wallpaper, settings, auto_explore)
- Some integration tests are brittle (finder/scroll assumptions)
- Export file-write flow is not fully validated on real-device MediaStore path

We should refactor **before release** to avoid shipping hidden regressions.

---

## Non-goals
- No redesign of app UX
- No large feature additions during refactor
- No shader formula rewrites unless needed for correctness

---

## Refactor Principles
- Behavior-preserving first
- One risk domain per PR
- Add tests before/with every structural change
- Keep `flutter analyze` clean and tests green at each step

---

## Workstream A — Renderer boundaries (P0)
### Problems
`renderer` + `viewer` currently carry mixed responsibilities (policy, rendering decisions, UI wiring, probe behavior).

### Refactor
1. Extract backend policy into a single service layer:
   - `RendererBackendPolicy` (auto/cpu/gpu decisions)
   - `GpuHealthProbePolicy` (timeouts, emulator overrides)
   - `DeepZoomPolicy` (threshold + hysteresis)
2. Keep widget layer dumb:
   - `FractalRenderer` only renders + emits telemetry
   - controller/provider owns transitions
3. Centralize fallback telemetry schema so logs are machine-parseable.

### Deliverables
- New `lib/core/services/renderer_policy_service.dart`
- New `lib/core/services/gpu_health_probe_service.dart`
- Refactor callers in `lib/features/viewer/*` and `lib/features/renderer/*`
- Regression tests for backend switching logic

---

## Workstream B — Integration test reliability (P0)
### Problems
Integration tests rely on text finders and viewport assumptions.

### Refactor
1. Standardize finder strategy across tests:
   - Prefer `ValueKey` (`catalogModuleCard_*` / `catalogGridTile_*`)
   - Always `scrollUntilVisible` before tap
2. Add helper utilities:
   - `openModuleByKey()`
   - `openModuleByNameWithScroll()`
3. Remove hard-coded assumptions for catalog position/order.

### Deliverables
- `integration_test/test_utils/navigation_helpers.dart`
- Fix `full_screenshots_test.dart` Julia/Mandelbulb flows
- CI-safe emulator runs for screenshot tests

---

## Workstream C — Coverage lift for weak modules (P1)
### Target modules
- `history`
- `minimap`
- `wallpaper`
- `settings`
- `auto_explore`

### Refactor + Tests
1. **History**
   - Extract persistence adapter
   - Add tests for append/order/max-size/restore
2. **Minimap**
   - Isolate coordinate transform math
   - Add tests for viewport-to-world mapping and tap navigation
3. **Wallpaper**
   - Decouple style transform from platform write path
   - Add unit tests for output dimensions + style overlays
4. **Settings**
   - Move settings serialization into typed model
   - Add tests for migration/defaults/persistence
5. **Auto-explore**
   - Introduce deterministic seed mode for tests
   - Add tests for step generation bounds and stop conditions

### Deliverables
- 1–2 test files per weak module
- Coverage report delta documented in PR

---

## Workstream D — Export hardening (P0)
### Problems
Export UI is tested; end-to-end file creation path on real device still weak.

### Refactor
1. Split export into clear stages:
   - Capture
   - Encode
   - Persist (MediaStore/File)
   - Share
2. Add structured errors per stage.
3. Add integration test hooks for verifying "file created".

### Deliverables
- `ExportPipelineResult` typed result model
- Real-device QA checklist + automated assertions where possible
- No-crash guarantee around failed MediaStore writes

---

## Workstream E — Localization/quality debt (P2)
1. Resolve 7 missing ES strings
2. Add untranslated-strings check to CI
3. Add lint/check for accidental hard-coded UI text

---

## Milestone sequence
### Sprint 1 (P0 foundation)
- Workstream B (test reliability)
- Workstream D (export pipeline split)
- Keep all gates green

### Sprint 2 (renderer safety)
- Workstream A policy extraction
- Add probe timeout override for emulator

### Sprint 3 (coverage lift)
- Workstream C modules: history + settings + minimap

### Sprint 4 (coverage lift + cleanup)
- Workstream C modules: wallpaper + auto_explore
- Workstream E localization and CI checks

---

## Definition of Done (for this refactor)
- `flutter test` passes with no new skips
- `flutter analyze` clean
- `scripts/headless-emulator-test.sh` passes
- Integration tests no longer rely on brittle text-only card taps
- Export pipeline returns explicit stage-level success/failure
- Weak modules each have baseline tests
- No user-facing behavior regressions in catalog/viewer/gestures/export

---

## Guardrails
- Avoid large "mega PRs"; cap each PR to one workstream slice
- If regression appears in renderer behavior, revert quickly and re-slice
- Use feature flags only when unavoidable, remove before release

---

## First actionable tasks (next 48h)
- [ ] Fix `full_screenshots_test.dart` to use scroll-safe key-based finder helpers
- [ ] Add `integration_test/test_utils/navigation_helpers.dart`
- [ ] Implement `ExportPipelineResult` and refactor export stage error handling
- [ ] Add history persistence unit tests
- [ ] Add CI check for missing localization keys
