# Refactoring Plan — Flutter Fractal Forge

> **Goal**: Maximize code reuse, streamline architecture for easier maintenance, debugging, and readability.
>
> The original inventory and R1–R7 proposals below are historical, not a current execution order or proof of dead code. Use the [bounded current frontier](#bounded-code-refactor-frontier-2026-10-25) and its `tasks/` records for the present planning handoff.

## Current Architecture Summary

```
lib/
├── main.dart                         (406 lines — multi-step app init)
├── core/
│   ├── models/        (10 files)     — data classes
│   ├── modules/       (17 files)     — fractal definitions + catalog builder
│   ├── services/      (27 files)     — business logic singletons
│   ├── shaders/       (1 file)       — uniform schema
│   ├── theme/         (1 file)       — AppTheme
│   └── widgets/       (4 files)      — shared widgets (animation, error)
├── features/
│   ├── viewer/        (1 file)       — fractal_viewer_screen.dart ⚠️ 2929 lines
│   ├── renderer/      (12 files)     — GPU/CPU rendering + gestures
│   ├── catalog/       (3 files)      — fractal catalog browser
│   ├── controls/      (1 file)       — parameter controls sheet
│   ├── export/        (3 files)      — image/video export
│   ├── debug/         (5 files)      — dev overlays
│   ├── history/       (4 files)      — session history
│   ├── presets/       (1 file)       — preset sheet
│   └── ... (8 more feature dirs)
├── shared/
│   └── utils/         (2 files)      — ⚠️ very underutilized
└── l10n/              (6 files)      — localization
```

---

## Problems Identified

### P1. God-Object: `fractal_viewer_screen.dart` (2929 lines, 92 methods)

This single file handles **everything** the viewer does:
- GPU health probing & backend auto-detection
- Comparison mode (side-by-side renderer)
- Export orchestration (image, video, wallpaper)
- Debug report generation
- Random fractal jumping
- Backend mode picker dialog
- Controls / presets / history / batch export sheet launchers
- Performance overlay toggle
- Toolbar & app bar construction
- Module selector UI
- Auto-explore integration

**Impact**: Extremely hard to reason about, test in isolation, or modify one concern without touching the others.

---

### P2. Monolithic `fractal_renderer.dart` (1653 lines, 45 methods)

Mixes three distinct concerns:
1. **Gesture handling** (pan, zoom, rotate, double-tap, momentum)
2. **Shader loading** (caching, retries, error categorization)
3. **Rendering pipeline** (CustomPainter, frame loop, fallback)

---

### P3. Massive `cpu_formulas.dart` (3521 lines, ~200 formula functions)

Every fractal has its own `_cpu_<name>()` function that repeats the same escape-time iteration boilerplate with minor math variations. Many share identical coloring logic (`_palette`, `_smoothEscape`).

---

### P4. Duplicated `_readDouble` across module files

`_readDouble(Map<String, Object>, String, double)` is copy-pasted into at least:
- `mandelbrot_module.dart`
- `burning_ship_module.dart`
- `mandelbulb_module.dart`
- `julia_module.dart`
- `phoenix_module.dart`
- `nova_module.dart`
- `cpu_fractal_renderer.dart` (as `_readInt` + `_readDouble` pair)

---

### P5. Underutilized `shared/` layer

The `lib/shared/` directory only contains `utils/` with 2 files. No shared widgets, no shared UI patterns, no reusable bottom-sheet templates — despite many features needing the same patterns.

---

### P6. Large `ar_overlay_screen.dart` (1202 lines)

Duplicates patterns from `fractal_viewer_screen.dart`:
- Module selector bottom sheet
- Fractal controller setup & teardown
- Export orchestration
- Controls panel construction

---

### P7. Redundant legacy module files

`mandelbrot_module.dart`, `burning_ship_module.dart`, `celtic_module.dart`, `buffalo_module.dart`, `tricorn_module.dart`, `multibrot3_module.dart` each ~200 lines, but these fractals are **already registered** in the `escape_time_catalog.dart`. The dedicated files are dead code — their `build*Module()` functions are never called from `ModuleRegistry`.

---

## Proposed Refactoring (Priority Order)

### R1. Split the God-Object `fractal_viewer_screen.dart`

Extract responsibility into focused mixins or sub-widgets:

| New file | Responsibility | Approx. lines extracted |
|---|---|---|
| `viewer_gpu_health.dart` | GPU health probe, emulator detection, backend decision | ~270 lines |
| `viewer_toolbar.dart` | AppBar, toolbar buttons, compact mode toggle | ~200 lines |
| `viewer_comparison.dart` | Side-by-side comparison mode controller | ~100 lines |
| `viewer_export_actions.dart` | Export/share/wallpaper orchestration | ~250 lines |
| `viewer_debug_report.dart` | GPU debug report builder & share | ~160 lines |
| `viewer_dialogs.dart` | Backend picker, module selector, sheet launchers | ~200 lines |

**Result**: `fractal_viewer_screen.dart` drops from ~2929 → ~1700 lines, with each concern independently testable.

---

### R2. Split `fractal_renderer.dart` into single-concern files

| New file | Responsibility |
|---|---|
| `gesture_handler.dart` | All `_onScale*`, `_onDoubleTap*`, momentum, rubber-band logic |
| `shader_loader.dart` | `_loadShader`, retry logic, caching, error categorization |
| `fractal_painter.dart` | `CustomPainter` + frame building logic |

Keep `fractal_renderer.dart` as the composing `StatefulWidget` that delegates to these.

**Result**: ~1653 → ~500 lines in the main widget; gesture, shader, and paint logic each in their own <400 line file.

---

### R3. Extract shared `_readDouble` / `_readInt` utility

Create a `lib/core/modules/param_reader.dart`:

```dart
/// Safe parameter readers for uniform setters.
double readDouble(Map<String, Object> params, String key, double fallback) {
  final value = params[key];
  if (value is int) return value.toDouble();
  if (value is double) return value;
  return fallback;
}

int readInt(Map<String, Object> params, String key, int fallback) {
  final value = params[key];
  if (value is int) return value;
  if (value is double) return value.round();
  return fallback;
}
```

Replace all per-file `_readDouble` / `_readInt` copies with imports of this shared utility.

**Files affected**: `mandelbrot_module.dart`, `burning_ship_module.dart`, `julia_module.dart`, `phoenix_module.dart`, `mandelbulb_module.dart`, `nova_module.dart`, `cpu_fractal_renderer.dart`.

---

### R4. Delete dead legacy module files

These modules are **already built** by the `escape_time_catalog.dart` + `escape_time_builder.dart` pipeline. The dedicated files are never called:

| File | Status |
|---|---|
| `mandelbrot_module.dart` | ⚠️ Still referenced from registry — but catalog already builds it. Need to verify which path wins. |
| `burning_ship_module.dart` | Dead — catalog builds `burning_ship` |
| `celtic_module.dart` | Dead — catalog builds `celtic` |
| `buffalo_module.dart` | Dead — catalog builds `buffalo` |
| `tricorn_module.dart` | Dead — catalog builds `tricorn` |
| `multibrot3_module.dart` | Dead — catalog builds `multibrot3` |

> [!IMPORTANT]
> Before deleting, verify in `ModuleRegistry._buildAll()` that the catalog entry for each ID takes precedence and the dedicated file is truly unreachable. The current code guards with `if (!catalogIds.contains('...'))`.

---

### R5. Refactor `cpu_formulas.dart` for code reuse

**Pattern**: Most escape-time formulas follow the same structure:

```
1. Set up z = (x, y), c = (x, y)
2. Iterate: z = f(z, c) [the ONLY part that varies]
3. Check |z|² > bailout → escape
4. Color using _palette(_smoothEscape(...))
```

Create a reusable `_escapeTime()` higher-order function:

```dart
typedef ZUpdate = (double, double) Function(double zx, double zy, double cx, double cy);

(double r, double g, double b) escapeTimeFormula(
  double x, double y, int iterations, double bailout,
  ZUpdate update, {double power = 2.0}
) {
  double zx = 0, zy = 0;
  int it = 0;
  for (; it < iterations; it++) {
    final (nx, ny) = update(zx, zy, x, y);
    zx = nx; zy = ny;
    if (zx * zx + zy * zy > bailout) break;
  }
  if (it >= iterations) return _insideColor;
  return _palette(_smoothEscape(it: it, iterations: iterations, mag2: zx * zx + zy * zy, power: power));
}
```

Then each formula becomes a one-liner:

```dart
_cpu_mandelbrot(...) => escapeTimeFormula(x, y, iterations, bailout,
  (zx, zy, cx, cy) => (zx * zx - zy * zy + cx, 2 * zx * zy + cy));

_cpu_burning_ship(...) => escapeTimeFormula(x, y, iterations, bailout,
  (zx, zy, cx, cy) => (zx.abs() * zx.abs() - zy.abs() * zy.abs() + cx, 2 * zx.abs() * zy.abs() + cy));
```

**Result**: ~3500 lines → ~1200 lines. The core iteration/coloring logic is defined once, tested once.

---

### R6. Introduce shared UI patterns in `lib/shared/`


| New file | Widget | Used by |
|---|---|---|
| `shared/widgets/module_selector_sheet.dart` | `ModuleSelectorSheet` | viewer, overlay |
| `shared/widgets/bottom_sheet_scaffold.dart` | `AppBottomSheet` (consistent drag handle, padding, glass effect) | controls, presets, history, export, wallpaper |
| `shared/widgets/section_header.dart` | `SectionHeader` (title + optional action) | controls, export, presets |

---

### R7. Flatten `main.dart` app initialization

The current 5-tier nesting (`_UltraSafeApp` → `_SafeScaffoldApp` → `_Step1ThemeOnlyApp` → `_Step2MinimalProviderApp` → `_Step3DeepLinkInitApp` → `FlutterFractalsApp`) was likely built incrementally for crash debugging. Collapse into 2 clear layers:

1. **`AppShell`** — Error boundary + theme + localization
2. **`AppProviders`** — All providers + deep link setup
3. **`FlutterFractalsApp`** — Navigation / routing

---

## Execution Priority & Risk

| Priority | Refactoring | Risk | Impact |
|---|---|---|---|
| 🔴 **1** | R3: Extract `_readDouble` utility | Very Low | Quick win, removes duplication across 7+ files |
| 🔴 **2** | R4: Delete dead module files | Low (verify first) | Removes ~1200 lines of dead code |
| 🟡 **3** | R1: Split viewer screen | Medium | Biggest maintainability gain, touches integration tests |
| 🟡 **4** | R2: Split renderer | Medium | Cleaner separation of concerns |
| 🟡 **5** | R5: Refactor CPU formulas | Medium | Massive line reduction, risk of subtle math bugs per formula |
| 🟢 **6** | R6: Shared UI patterns | Low | Helps future features, optional |
| 🟢 **7** | R7: Flatten main.dart | Low | Aesthetic improvement, not urgent |

---

## Verification Plan

### Existing Test Suite

The project has a comprehensive test suite that should pass before and after each refactoring step:

**Unit Tests** (~49 files in `test/`):
```bash
flutter test
```

Key files that will act as regression guards:
- `test/fractal_viewer_screen_widget_test.dart` — viewer UI tests
- `test/fractal_renderer_widget_test.dart` — renderer widget tests
- `test/fractal_renderer_gesture_test.dart` — gesture handling tests
- `test/fractal_controller_behavior_test.dart` — controller state tests
- `test/modules/module_registry_widget_test.dart` — module registry tests
- `test/cpu/cpu_mandelbrot_visual_gate_test.dart` — CPU formula correctness
- `test/cpu/cpu_formula_coverage_test.dart` — CPU formula coverage
- `test/export_service_test.dart` — export logic
- `test/ar_overlay_screen_widget_test.dart` — screen tests
- `test/crash_reporter_test.dart` — crash reporter

### Test Strategy Per Refactoring

| Step | Verify with |
|---|---|
| R3 (param reader) | `flutter test` — all existing tests pass unchanged |
| R4 (dead modules) | `flutter test test/modules/module_registry_widget_test.dart` — verify all modules still load |
| R1 (split viewer) | `flutter test test/fractal_viewer_screen_widget_test.dart` + `flutter test test/navigation_flow_widget_test.dart` |
| R2 (split renderer) | `flutter test test/fractal_renderer_widget_test.dart` + `flutter test test/fractal_renderer_gesture_test.dart` |
| R5 (CPU formulas) | `flutter test test/cpu/cpu_formula_coverage_test.dart` + `flutter test test/cpu/cpu_mandelbrot_visual_gate_test.dart` |
| R6 (shared UI) | `flutter test` — full suite |
| R7 (flatten main) | `flutter test test/utilities/widget_test.dart` + `flutter test test/screens/home_screen_widget_test.dart` |

### Static Analysis Gate (before committing each step)

```bash
flutter analyze
```

### Integration Tests (final validation)

```bash
# Run on connected device or emulator
flutter test integration_test/flows/user_flows_test.dart
flutter test integration_test/flows/viewer_navigation_test.dart
```

---

## Files Changed Summary

| Action | Count | Total lines affected |
|---|---|---|
| New files (extracted) | ~12 | ~2500 (moved, not new logic) |
| Modified files | ~15 | ~3000 (imports, restructuring) |
| Deleted files | ~6 | ~1200 (dead code) |
| Net line change | — | **~-2000 lines** (less code overall) |

---

## Bounded code-refactor frontier 2026-10-25

Status: Accepted

**Authority:** the owner requested standalone Plan For Me for “code refactor”. This accepts a behavior-preserving engineering planning scope, not implementation, catalog integration, worker dispatch, publication or a new product direction. The approach and defaults below are planner decisions. This section supersedes the historical execution-priority table for this bounded batch, not its retained history.

### Brief, goal and boundaries

Flutter Fractal Forge lets people browse mathematical visuals, explore their parameters and share or export the result. Provider/FractalController owns viewer state; platform services deliver external events; viewer coordinators own asynchronous actions. Reuse `APP-QUALITY-001` for this architecture-quality frontier, consistent with [the product quality direction](../../PRD.md#mcp-assisted-architecture-and-ui-improvement). Do not change that goal's priority, focus, qualification or completed task history.

The goal is to separate two demonstrated responsibility seams while preserving public import paths, observable outputs and ownership rules. Success is cohesive code ownership plus unchanged tested behavior, **not a line-count target, speed claim or whole-app-quality verdict**.

Non-goals and anti-goals: no state-management migration, new dependency, schema/URL-format change, musical redesign, numerical algorithm rewrite, shader change, visual redesign, new live qualification or release. Do not fold bug fixes or new abstractions into a mechanical extraction unless a directly blocking prerequisite is established and documented at the task's existing seam. In particular, do not revive the historical generic CPU escape-loop rewrite or delete modules based on the old unreachable-code assertion.

Preserve the locally verified, unintegrated catalog candidate in `.worktrees/ui-catalog-20261025`; its acceptance and earlier tests do not establish canonical inclusion or authorize integration here. The selected refactors do not touch its catalog widgets, locales, fixtures or rendering algorithms.

### Discovery and evidence

Inspection baseline: `641f3c675b45d77b50f5965843d8cb413c252e33`. These observations come from current source and task records; no code graph, failing test, runtime improvement or performance baseline is claimed.

| Classification | Evidence and implication |
| --- | --- |
| DOCUMENTED | `lib/AGENTS.md`, `lib/core/AGENTS.md` and `lib/features/viewer/AGENTS.md` retain Provider/controller ownership and core-to-feature dependency boundaries. `CONTEXT.md` defines Image-Conditioned Composition and Musical Identity Tier: these are invariants, not refactor opportunities to recompose the music. |
| OBSERVED | `lib/core/modules/param_reader.dart` already supplies finite-safe numeric readers; `lib/features/renderer/cpu/cpu_fractal_renderer.dart` uses them. Viewer action/chrome/export helpers and `lib/app/` already exist. Therefore the old R3/R1/R2/R7 inventory cannot be replayed as if no extraction happened. This does not assert every historical item is fully complete. |
| OBSERVED | `lib/features/viewer/audio/fractal_music_service.dart` is 2,321 lines at this baseline: public frame/features/identity definitions, lifecycle orchestration around line 330, private platform adapters around 485–832, and compute/composition/PCM/WAV routines from 833 onward. Cancellation publication rules, process/temp-file handling and musical arithmetic share one change/review surface. SHA-256: `f1b73d5c2ab639abbba858b8e948a90c1fa0a022aa22472a5e242b91c426654d`. |
| OBSERVED | `lib/core/services/platform/deep_link_service.dart` is 1,336 lines: DTO/query/route contracts, five public static parse/build entry points, and native MethodChannel/stream ownership. Helpers refer back to the service's private query contracts. SHA-256: `3a669f4069cdf7af477c9e271a67b6c54cfb9801bb3dd5f7549fdf4ec0f2da7f`. A codec extraction must move those contracts together, not create a codec↔service import cycle. |
| OBSERVED | Existing public-seam guards are in `test/features/viewer/fractal_music_service_test.dart`, viewer coordinator/Fourier tests, `test/services/deep_link_service_test.dart`, `test/screens/home_screen_widget_test.dart` and Number Walls replay tests. Their source was inspected; their execution in this planning occurrence is **UNRUN**. |
| OBSERVED | The task store contained 113 tasks/20 goals and validated without drafts. APP-001 through APP-005 and earlier music/timer repairs are closed; no open task duplicates these extractions. NUM-WALL-04 was actually in flight; NUM-WALL-05 depends on it; SINEWARP-002-47 remains separate accepted work. Preserve those contracts and priorities. |
| INFERRED | Separating these cohesive responsibilities should narrow unrelated reviews and make future ownership mistakes easier to detect. No defect reduction, speedup or maintenance percentage has been measured. |

The accepted architecture-quality direction is partially verified, not a blank cheque for a rewrite. These tasks close a bounded structural gap; they do not replace pending device acceptance or certify other features. Existing prepare diagnostics concerning legacy source links/unqualified goals are unrelated warnings, not permission to rewrite the backlog or declare goals met.

### Decided design and rejected alternatives

1. **Music: preserve the existing Dart library and facade.** Introduce `audio/fractal_music_playback.dart` and `audio/fractal_music_synthesis.dart` as `part` files of `fractal_music_service.dart`. Move the private adapter hierarchy/factory to playback; move the existing top-level compute, composition, synthesis and WAV routines to synthesis. Keep public types, configuration constants, features/identity entry points and service orchestration in the facade. Keep the existing conditional browser-player import unchanged. Shared private symbols remain library-private; all old consumers continue importing the same facade. Preserve arithmetic, callback names, sample ordering, default values, await boundaries, cancellation generations and publication guards. This is a responsibility split, not a new independently importable DSP package. Rejected: a new public adapter API, dependency injection framework or normal-library split requiring broad promotion/duplication of private musical helpers.
2. **Links: separate a stateless codec from platform delivery.** Introduce `core/services/platform/deep_link_codec.dart`, containing the one authoritative `DeepLinkData` class, route/query/value helpers and a `DeepLinkCodec` with the existing five signatures: `parseIncomingLink`, `parseBrowserUri`, `parseUri`, `buildUri`, `buildWebUri`. Move all codec query constants, aliases, numeric bounds and formatting/diagnostic behavior with it. `DeepLinkService` retains compatibility delegates and const scheme/host aliases, re-exports `DeepLinkData`, and alone owns `_initialBrowserUri`, `_channel`, `_handlerOwner`, the broadcast stream and initialize/dispose logic. Codec helpers refer to codec contracts, never import the service. Existing logger/model/vector dependencies are allowed; the codec has no MethodChannel or stream lifecycle. Rejected: moving everything into parts (would not establish this stateless dependency seam), changing accepted URLs, or deleting the old facade and rewriting every caller.
3. **Verification: preserve behavior rather than manufacture a refactor metric.** Existing behavior tests should pass before and after a pure move; do not invent a failing baseline or source-string/line-count test to make it look like a bug fix. For the new codec boundary, add one focused facade/codec compatibility table in the proposed `test/services/deep_link_codec_test.dart`: direct import initially fails until the seam exists. Cover representative custom/web/browser forms, malformed/duplicate recognized keys, precision/typed scalar replay and canonical output equality using existing fixtures where practical. Reuse the extensive current arithmetic/audio/cancellation guards instead of duplicating them. New or changed behavior discovered during execution gets a focused regression before repair, within the owning task's scope.
4. **No new product dependencies.** The two implementation tasks are independent and have disjoint production/test write sets. Neither requires the catalog candidate to land. They can be implemented in isolated worktrees in parallel after execution is explicitly authorized. Do not add live/exclusive resources: tests use mocks/disposable files, not shared audio hardware or a device. Do not overlap canonical integration or change an active task merely because a new branch has a plan.

### Task handoff

Task IDs are allocated through `autowork tasks`; the final saved records below are the execution contracts, not this historical roadmap.

| Requested direction / derived outcome | Saved task | Placement and prerequisites |
| --- | --- | --- |
| Code refactor: separate music synthesis, playback and service orchestration without changing behavior | [ACAD-009-795c5cbf](../../tasks/items/ACAD-009-795c5cbf.md) | Next, rank 13000; no product prerequisite |
| Code refactor: separate link serialization from platform delivery while preserving the old facade | [ACAD-010-7698d788](../../tasks/items/ACAD-010-7698d788.md) | Next, rank 14000; no product prerequisite |

The CLI allocated these IDs; their goal is `APP-QUALITY-001` despite the opaque ID prefix. Keep the allocated IDs unchanged. Recommended first task within this batch is the music extraction; the codec is an independent lane, not its successor. No consequential product question remains within this scope. Current higher-priority work and all live acceptance remain separate.

Each record includes exact proposed checks and bounded touches. Preserve the existing higher-priority work; place this batch at the bottom of `Next`, with no synthetic dependency edge or automatic planning successor. The whole presently knowable frontier is these two extractions. Further refactors need fresh evidence; no self-replenishing chain or broad renderer rewrite is implied.

### Verification, setup and pre-mortem

All implementation/build checks below are **proposed and unrun by this planning pass**. Future execution uses the pinned Flutter 3.44.6/Dart 3.12.2 and existing offline PUB_CACHE per root `AGENTS.md` and `docs/tasks/MAIN-CHECK-01.md`. Run the lockfile-enforced offline package preflight in each execution checkout before focused tests; do not install packages, repair the shared SDK, copy another checkout's package binding or change `pubspec.lock` to make a refactor pass.

- Music: existing service/coordinator/Fourier/effects tests, analyzer and release web compilation. Mock all playback. This proves no new browser build break; it does not prove audible playback on any real target.
- Links: new codec parity table, existing service/Home/Number Walls replay guards and analyzer. No real inbound link delivery or live navigation is required for offline acceptance.
- Integration/main: retain the root offline gate: `flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats`. Respect the repository's worker/landing/main check ownership; focused worker results are not a full-main result. Keep existing opt-in skips and genuine device/publication gaps explicit. Review the resulting merged candidate before claiming delivery.

Pre-mortem: (1) Moving musical helpers changes isolate reachability or cancellation ordering: keep top-level callback identities/order and use current compute/playback/coordinator guards plus web compilation. (2) New codec silently changes alias precedence, numeric formatting, accepted origins or DTO identity: keep one DTO, old facade exports and the exact old tables; exercise both APIs and existing boundary tests. Browser-address parsing intentionally accepts preview hosts; do not confuse it with the strict native/universal-link allowlist. (3) Planning/integration overwrites active or unintegrated work: use isolated write sets, preserve the catalog candidate and actual active task contracts, and inspect current source at execution/landing rather than treating this baseline as a lease.

Planning completion requires CLI task readback, a fresh read-only builder check, `autowork tasks validate --worktree .`, applicable local link/whitespace checks, and one scoped planning commit. The saved batch is branch-local until the canonical consumer includes it; report that distinction rather than claiming the runner can select unintegrated task IDs. Planning stops at that handoff and does not start implementation.

### Planning validation and delivery boundary

The saved batch was read back through the CLI/files and validated with `autowork tasks validate --worktree .`: 115 tasks, 20 goals, no drafts. A scoped nonmutating check resolved all four local Markdown links/anchors, checked the two task write sets were disjoint, and confirmed the source fingerprints above plus the catalog candidate patch were unchanged. The catalog patch fingerprint checked was `7ca96b8175e7d30cd6a28e0a1fd733ae3cbda21ebf3a5534d9239e2e9175457b`. Whitespace checks passed.

A fresh read-only builder review of both saved records reported **“nothing important left”**, no established blocker, and independent isolated execution lanes with serialized integration. It confirmed the adapter/compute and codec/lifecycle seams against source, not by executing tests. Review session: `a7a2db2a/run-0`, reviewer run `2b4dc2c2-1d17-42d3-9b58-4e1e403b3f09` in the current planning conversation. Tool/cache availability and baseline test/build results remain unverified by this pass.

This batch is saved on `plan/code-refactor-20261025` in `.worktrees/plan-code-refactor-20261025` to preserve the live canonical coordinator and its active contracts. A planning-branch commit does not put these tasks in canonical main or dispatch them. The next delivery step is supported reconciliation of this planning-only commit into the consumer; implementation still requires a later explicit instruction. Within the accepted batch, the first proposed implementation action is the music task's unchanged-source focused guards; the codec task can use its separate lane once execution is authorized.
