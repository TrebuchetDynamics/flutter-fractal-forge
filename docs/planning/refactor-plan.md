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
4. **Independent refactors, explicit input prerequisites.** The two implementation tasks have disjoint production/test write sets and do not depend on each other or catalog delivery. The codec task does require NUM-WALL-02's source/test outputs before its mandatory Number Walls consumer checks can run: those outputs existed in the local inspection baseline but are absent from the fresh remote-main delivery baseline. Record that real prerequisite, not a file-overlap scheduling edge. Music can proceed independently; both can run in isolated worktrees after the codec prerequisite is included and execution is explicitly authorized. Do not add live/exclusive resources: tests use mocks/disposable files, not shared audio hardware or a device. Do not overlap canonical integration or change an active producer's contract/status merely to deliver this plan.

### Task handoff

Task IDs are allocated through `autowork tasks`; the final saved records below are the execution contracts, not this historical roadmap.

| Requested direction / derived outcome | Saved task | Placement and prerequisites |
| --- | --- | --- |
| Code refactor: separate music synthesis, playback and service orchestration without changing behavior | [ACAD-009-795c5cbf](../../tasks/items/ACAD-009-795c5cbf.md) | Next, rank 13000; no product prerequisite |
| Code refactor: separate link serialization from platform delivery while preserving the old facade | [ACAD-010-7698d788](../../tasks/items/ACAD-010-7698d788.md) | Next, rank 14000; requires NUM-WALL-02 source/test inclusion |

The CLI allocated these IDs; their goal is `APP-QUALITY-001` despite the opaque ID prefix. Keep the allocated IDs unchanged. Recommended first task within this batch is the music extraction; the codec is an independent lane once NUM-WALL-02 supplies its required source/tests, not a successor to music. No consequential product question remains within this scope. Current higher-priority work and all live acceptance remain separate.

Each record includes exact proposed checks and bounded touches. Preserve the existing higher-priority work; place this batch at the bottom of `Next`, with no synthetic dependency between these two refactors or automatic planning successor; retain the codec's actual NUM-WALL-02 prerequisite. The whole presently knowable frontier is these two extractions. Further refactors need fresh evidence; no self-replenishing chain or broad renderer rewrite is implied.

### Verification, setup and pre-mortem

All implementation/build checks below are **proposed and unrun by this planning pass**. Future execution uses the pinned Flutter 3.44.6/Dart 3.12.2 and existing offline PUB_CACHE per root `AGENTS.md` and `docs/tasks/MAIN-CHECK-01.md`. Run the lockfile-enforced offline package preflight in each execution checkout before focused tests; do not install packages, repair the shared SDK, copy another checkout's package binding or change `pubspec.lock` to make a refactor pass.

- Music: existing service/coordinator/Fourier/effects tests, analyzer and release web compilation. Mock all playback. This proves no new browser build break; it does not prove audible playback on any real target.
- Links: new codec parity table, existing service/Home/Number Walls replay guards and analyzer. No real inbound link delivery or live navigation is required for offline acceptance.
- Integration/main: retain the root offline gate: `flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats`. Respect the repository's worker/landing/main check ownership; focused worker results are not a full-main result. Keep existing opt-in skips and genuine device/publication gaps explicit. Review the resulting merged candidate before claiming delivery.

Pre-mortem: (1) Moving musical helpers changes isolate reachability or cancellation ordering: keep top-level callback identities/order and use current compute/playback/coordinator guards plus web compilation. (2) New codec silently changes alias precedence, numeric formatting, accepted origins or DTO identity: keep one DTO, old facade exports and the exact old tables; exercise both APIs and existing boundary tests. Browser-address parsing intentionally accepts preview hosts; do not confuse it with the strict native/universal-link allowlist. (3) Planning/integration overwrites active or unintegrated work: use isolated write sets, preserve the catalog candidate and actual active task contracts, and inspect current source at execution/landing rather than treating this baseline as a lease.

Planning completion requires CLI task readback, a fresh read-only builder check, `autowork tasks validate --worktree .`, applicable local link/whitespace checks, and one scoped planning commit. The saved batch is branch-local until the canonical consumer includes it; report that distinction rather than claiming the runner can select unintegrated task IDs. Planning stops at that handoff and does not start implementation.

### Planning validation and delivery boundary

The saved batch was read back through the CLI/files and validated with `autowork tasks validate --worktree .`: 115 tasks, 20 goals, no drafts. A scoped nonmutating check resolved all four local Markdown links/anchors, checked the two task write sets were disjoint, and confirmed the source fingerprints above plus the catalog candidate patch were unchanged. The catalog patch fingerprint checked was `7ca96b8175e7d30cd6a28e0a1fd733ae3cbda21ebf3a5534d9239e2e9175457b`. Whitespace checks passed.

A fresh read-only builder review against the local inspection baseline reported **“nothing important left”**, no established blocker, and independent isolated execution lanes with serialized integration. That baseline already contained NUM-WALL-02 outputs; the remote-delivery reconciliation below records their missing inclusion rather than reusing this as remote readiness. It confirmed the adapter/compute and codec/lifecycle seams against source, not by executing tests. Review session: `a7a2db2a/run-0`, reviewer run `2b4dc2c2-1d17-42d3-9b58-4e1e403b3f09` in the current planning conversation. Tool/cache availability and baseline test/build results remain unverified by this pass.

The original planning commit `769dd775` is retained on `plan/code-refactor-20261025` in `.worktrees/plan-code-refactor-20261025`. Git delivery reconstructs only its three planning paths on `delivery/refactor-plan-20261025`, based on freshly fetched origin/main `0dc1158fe4b2338196ffcd6febacc49a986777d8`; it does not merge the fourteen unrelated local Autowork commits into the remote. The two inspected production files have identical blobs on that upstream and the local inspection baseline.

Fresh upstream lacks `test/number_walls/number_wall_state_test.dart` and `test/number_walls/number_wall_viewer_test.dart`; its existing NUM-WALL-02 record owns both outputs and remains open. The codec contract therefore records `depends_on = ["NUM-WALL-02"]`, preserving all required checks. This is a source-inclusion prerequisite, not new feature work, a fabricated owner question or permission to close/publish the producer. Preserve every upstream task/goal/evidence record outside the two new task IDs.

Delivery authority covers this planning-only publication, not implementation or the separate catalog candidate. The live canonical checkout/coordinator is not modified by the isolated delivery; remote inclusion and local consumer synchronization are separate outcomes. Within this batch the first proposed implementation action remains the music task's unchanged-source focused guards, after a later explicit implementation instruction. At the planning-only publication baseline, the codec's consumer checks wait for its producer outputs; do not call them passing or runnable from that older source alone.

### Merge-all continuation

The owner's later “Merge all main” request authorizes composition of local main history, the published planning batch and the catalog checkpoint, not implementation of either refactor. The [main integration record](../tasks/MAIN-MERGE-20261025.md) binds the combined-source checks and repaired ingress-ownership blocker.

That composition includes NUM-WALL-02's source and both required Number Walls test files, retaining its existing completed record and receipt. The codec's typed dependency remains, but its missing-source hold from the planning-only publication no longer describes this combined source. Both refactor tasks remain open and unimplemented; their actual execution still follows the authorized task-selection and verification workflow. Do not conflate source inclusion, task selection eligibility, live qualification and completed refactoring.

## Flutter shell and Rust engine migration

Status: Accepted

Acceptance source: the owner's standalone Plan For Me request supplied the full
Flutter + Rust strangler migration, phases 0–14, operational rules and final DoD.
This accepts the migration direction for planning, not implementation or publication.
Everything labelled **Planner call** below is a delegated engineering decision.
This section owns this migration plan; earlier refactor proposals are not changed.

### Brief and invariant

Keep Flutter as the working UI/platform shell throughout migration. Rust will own
catalog semantics, parameter validation, mathematical state/camera, presets,
precision/capabilities, CPU/deep zoom/perturbation, GPU rendering, scheduling,
cancellation, export pixels/PNG and renderer diagnostics. Flutter retains widgets,
navigation, l10n/accessibility, physical input capture, storage transport, file
selection, MediaStore, share and wallpaper APIs. GPUI/CLI reuse is an architectural
benefit, not a second app or repository in this project.

Invariant for every task: preserve IDs, saved data, mathematical claims, observable
controls, renderer honesty and the existing working Flutter path. No silent fallback
to a different formula, no fabricated CPU precision, no two synchronized state owners.
Non-goals: catalog expansion, mathematical improvements during ports, new UI, server,
publication, host changes or GPUI implementation. Anti-goals: copied frames through
Dart on the interactive GPU path, renaming IDs, precision loss and regressions hidden
by weaker tests. The supplied 60/120 Hz outcome is a qualification target, not a
measurement made in this planning session.

### Repository evidence and corrections

Inspection baseline: local main `0b1ecfcde8d484950a71ad1dc28729426c4557e9`.
Seven unrelated dirty test files were present and are outside this plan's writes.
No Rust workspace or FRB dependency was found in the inspected tracked source.
The existing Rust 1.95.0 binaries are under
`/home/xel/.rustup/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin`; ambient PATH does
not expose cargo/rustc. Use a task-local PATH; do not change shell profiles.

- `lib/core/modules/module_registry.dart:81–142` merges declarative/custom modules,
  preserving existing entries and adding diagnostics under `kDebugMode`.
  `lib/features/catalog/data/catalog_repository.dart:63–70` creates a separate
  catalog identity. Preserve both `mandelbrot` and `core.mandelbrot`, not one
  renamed namespace. Registry order, performance-family entries, hidden legacy
  degree cards, diagnostics and public fractal counts are distinct inventories.
  `test/catalog/catalog_id_integrity_test.dart:16–29` contains historical counts;
  derive baseline counts from actual descriptors, not those comments or README.
- `lib/core/models/fractal_parameter.dart:13–40` includes `decimalInteger` as well
  as float/integer/enum/bool. Number Walls certification is asynchronous and
  module-owned (`docs/engineering/spec.md#number-walls-replay-validation-boundary`).
  Preserve exact decimal strings and prior committed grids on invalid ingress.
- `lib/core/controllers/fractal_controller.dart:796–839` normalizes view input;
  `input/fractal_view_input_bounds.dart:14–18` defines `maxZoom = 1e12`,
  `defaultMinZoom = 1e-9`, `cantorSetMinZoom = 0.2`, `minPan = -3.0`,
  `maxPan = 3.0`. NaN retains bounded last-good state; infinities clamp for pan/zoom;
  nonfinite rotations retain finite prior angles. Keep these in the first port.
  New arbitrary-depth navigation is later work, not an accidental relaxation.
- `test/fractal/fractal_controller_behavior_test.dart:12–25` asserts the normal
  zoom bounds; retain it. Replay also covers clamps, boolean normalization, reset,
  adaptive iterations, snapshots and saved presets. Gesture ownership remains in
  `lib/features/renderer/widgets/renderer/input/gesture_handler.dart` and renderer
  pointer/scale/double-tap handlers (`fractal_renderer.dart:322–333`); preserve
  wheel, pinch anchor, keyboard, drag/fling direction and nested controls.
- `lib/features/renderer/policy/precision_ladder_policy.dart:8–12,129–131` defines
  `5e6`, `1e30`, `1e12`, `1e9`, `1e7` thresholds and `hysteresisFrames = 2`
  (the latter at line 122).
  The policy's perturbation ceiling is not the controller's navigation ceiling.
  Replay decisions across boundary neighbors, power, module capabilities and
  hysteresis history, not just `(module, zoom)` stateless calls.
- `test/modules/escape_time_uniform_contract_test.dart:13–37` checks minimum slot
  capacity, not full semantic equivalence. Reuse it and
  `test/modules/escape_time_shader_manifest_test.dart`; do not call their pass
  complete shader ABI or mathematical proof. `builders/uniform_layout.dart`
  already provides family slot constants. Samplers are separate from float slots.
- `test/modules/catalog_preset_render_health_test.dart:36–66` demonstrates real
  FragmentProgram draw/readback and disposal. Reuse that seam, not mock images.
  Existing Number Walls, Gaussian/quaternion/trajectory and Fibonacci paths must
  appear in inventory; they are not all interchangeable FragmentShader formulas.
- `docs/engineering/spec.md#rendering-interface` and
  `#export-and-compatibility-boundary` preserve CPU support and transparency limits.
  CPU alpha is not to be silently improved during a port. Mathematical or inspired/
  unverified provenance is retained independently of successful image rendering.

### Decided architecture and research

**Planner call:** use one in-repo workspace and three crates: `fractal-core`
(domain only), `fractal-render` (CPU/GPU services depending on core),
`fractal-bridge` (Flutter-facing adapter depending on both). The rule forbidding
Flutter/Android/GPUI knowledge applies to core/render, not bridge/platform glue.
Reject a big-bang rewrite and a second repository: both weaken differential parity
and rollback. Do not introduce wgpu into the initial nonrendering bridge.

**Planner call:** use flutter_rust_bridge v2 for commands, snapshots and opaque
engine handles; keep its Rust/Dart/codegen versions matched and locked at integration.
Exact patch selection and generated build-file layout are worker-reversible under
that compatibility contract. Upstream documents existing-project integration and
Web support: [FRB quickstart](https://cjycode.com/flutter_rust_bridge/quickstart),
[crate API](https://docs.rs/flutter_rust_bridge/latest/flutter_rust_bridge/).
Never run its project generator over the app without reviewing its write set.

**Planner call:** the sole state owner moves per engine session, not per field.
A migrated session accepts typed batched commands and returns immutable snapshots;
Dart's controller becomes a presentation adapter. Nonmigrated sessions stay entirely
Dart-owned. Use engine/session identity plus monotonic u64 revisions, reject stale
snapshots/frames after switch/reset/disposal, and pin exports to their captured
revision rather than discard an explicit export when the viewport changes.
Coalesce render requests (latest state wins), not incremental pan/zoom commands:
apply each ordered input transaction before publishing the newest render state.
Errors preserve last-good state; shutdown is idempotent and invalidates handles.
No mathematical callbacks or per-pixel FFI. Flutter gestures send physical inputs;
Rust eventually computes camera transforms and clamps. UI timers are not duplicated
as mathematical state authorities.

**Planner call:** typed parameters retain enum underlying values and canonical
arbitrary integers; deep coordinates use canonical decimal significand/exponent
strings internally validated by Rust, not an f64 round trip or a bigfloat FFI ABI.
Keep legacy preset readers and unknown/invalid ingress behavior until round-trip
fixtures prove a versioned migration. Rust returns localization keys; closures and
translated text stay in the Flutter adapter. Preserve built-in literal labels via
an explicit presentation mapping until keys exist; no catalog translation rewrite.

**Planner call:** WGSL becomes canonical only for migrated families. Keep a
versioned, generated shader binding manifest with alignment/types/sampler bindings,
not a promise that separate `floats`/`ints` vectors alone define a wgpu ABI.
Until then emit validated Flutter float-slot packets plus separate sampler bindings.
Use source hashes, resolved includes and existing slot tests in the baseline.
Automated GLSL normalization/Naga conversion can assist, never establish correctness.

[wgpu's platform table](https://github.com/gfx-rs/wgpu#supported-platforms) lists
Vulkan for Linux/Android and native Metal/DX12; WebGL2 is downlevel/best-effort,
not equivalent to WebGPU. [Flutter's SurfaceProducer guidance](https://docs.flutter.dev/release/breaking-changes/android-surface-plugins)
supports the Android surface route, not a cross-platform zero-copy guarantee.
Crucially, [flutter_wgpu 0.1.0](https://pub.dev/packages/flutter_wgpu) declares
Android SurfaceProducer but **Windows/Linux pixel buffer copy**. Use it as a
reference only, not as proof of the required Linux GPU composition path. The later
native texture spike must prove Android surface and Linux external-texture ownership,
fences, orientation, resize, context loss, background/resume and cleanup. Native
copying, if used diagnostically, is labelled and does not pass the zero-copy goal.
No claim of portable zero-copy or 120 Hz follows from these documents.

### Complete outcome map and ordered gates

This maps every supplied phase, operational requirement and final DoD. Later gates
are accepted scope, not speculative ready implementation cards. The closing planning
card expands them from implementation evidence; it may not drop or weaken them.

| Requested slice | Gate and proof / task mapping |
| --- | --- |
| Phase 0, baseline and differential harness | M0: RUST-M0-CONTRACTS, RUST-M0-REPLAY, RUST-M0-IMAGES; inventory plus deterministic replay plus source-bound real images. Capture before controller/render replacement. |
| Phase 1, workspace/CI/version/engine handles | RUST-M1-WORKSPACE, RUST-M1-BRIDGE; fmt/clippy/test plus unchanged Flutter guards. M1 additionally needs actual Linux and designated Waydroid smoke/lifecycle evidence; offline tests alone do not pass M1. |
| Phase 2, state/camera/parameters/controller adapter | M2: consume replay corpus, Rust owns full migrated session, old Flutter renderer consumes snapshots; invalid input and stale revisions preserve prior state. No dual mutable owner. |
| Phase 3, registry/catalog/presets/capabilities | M3: full baseline parity including production/debug/performance distinctions, ordering, stable IDs, exact integers, provenance and presentation keys; controls remain Flutter. |
| Phase 4, uniform mathematics | M4: family packets exactly reproduce legacy binding values/samplers and transparency; only adapter writes FragmentShader slots. |
| Phase 5, precision ladder | M5: deterministic Rust/Dart boundary/hysteresis/capability parity, no fictional CPU support; remove Dart policy only after matching replays. |
| Phase 6, CPU formulas/tiles/workers | M6: port only genuinely supported formulas, analytic/classification and RGBA parity, bounded jobs/memory, progress and cancellation; CPU work off UI thread. |
| Phase 7, deep zoom/perturbation | M7: reference orbits, double-float and arbitrary-precision references, stable coordinate serialization and honest fallback, without exposing library types through FFI. |
| Phase 8, wgpu Mandelbrot/native texture | M8: long-lived device/queue/pipelines/cache, renderer-owned task/mailbox; actual pinch → Rust → Vulkan/wgpu → compositor on Linux and Waydroid, no frame bytes through Dart. Hardware performance remains separate. |
| Phase 9, Mandelbulb | M9: prove 3D raymarch/camera/depth/lifecycle and edited-state rendering on both native targets, not just a second shader compilation. |
| Phase 10, families/WGSL/conversion/manifest | M10: escape-time, roots, attractors, IFS, cellular, number systems, 3D, hypercomplex and custom families port with descriptor/binding validation plus analytic/image parity and provenance retained. |
| Phase 11, viewport ownership | M11: Flutter viewport is presentation/input only, Rust owns render/backend/scheduler/cancellation/diagnostics; retire legacy renderer only after every required module has a qualified replacement. |
| Phase 12, export/PNG | M12: same engine and pinned snapshot for viewport and 4K/8K export; bounded memory/tiles/cancel, exact dimensions/crop/color/alpha/error semantics and PNG readback; Flutter saves/shares/platform actions only. |
| Phase 13, presets/persistence | M13: legacy fixtures → versioned Rust semantics → unchanged Flutter storage transport; saved/history/import/deep-link round trips, exact primes and rejection behavior remain compatible. |
| Phase 14, Web | M14A: Rust WASM core with legacy renderer; M14B: Rust WebGPU renderer and export/download; separate browser capabilities and loss/fallback checks. Native migration does not wait for Web, but final retirement cannot strand Web. |
| Flags, module routing, performance rules and final CI | Cross-cutting all gates: RUST_CORE/CPU/GPU/EXPORT default off until qualified, module/backend routing with compatible flag combinations, safe rollback without state loss. Coarse FFI, revision/session checks, latest-state scheduling, bounded threads and long-lived GPU resources. Preserve common offline checks; add Rust/analytic/shader/differential lanes and separately qualified Linux/Android/Web journeys. |
| Final 100% Rust DoD | All gates plus full catalog Rust-owned, PNG/diagnostics included, no Dart fractal formulas, backend decisions, uniform math or fractal rendering. Flutter UI/platform/accessibility remain. Audit dependencies/imports and actual runtime routing, not file extensions alone. |

### First executable frontier and checks

Plan round: 1 of 10. Six new tasks under RUST-ENGINE-001: five building tasks and
one closing `kind = plan` task RUST-PLAN-02 depending on all five.
RUST-M0-CONTRACTS and RUST-M0-REPLAY can run independently of
RUST-M1-WORKSPACE in isolated worktrees. RUST-M0-IMAGES consumes the contracts
manifest; RUST-M1-BRIDGE consumes the workspace and all M0 evidence. These edges
are data/gate prerequisites, not shared-file scheduling tricks. Shared plan/spec
updates require serialized integration; no shared live resource is needed offline.
Do not rerank the existing Waydroid recovery or change goal focus.

Planner calls for baseline: canonical JSON v1, stable sorted records with registry
order retained explicitly, no timestamps in deterministic payloads; hashes/toolchain/
backend/revision in provenance. Keep five named inventory files and separate replay
corpus. Export options/ranges/defaults, built-in preset semantics, CPU membership,
precision capability and resolved shader ABI without executing mathematical ports.
Render representatives: mandelbrot, julia, burning_ship, newton_z3, lorenz_2d,
sierpinski_triangle, number_wall, mandelbulb, milnor_brieskorn. The last is inspired; retain
its actual claim status. Resolve names to real descriptors and fail missing entries,
never replace one with a convenient gradient. Freeze 256×256, time zero, opaque
module defaults plus edited Mandelbrot/Mandelbulb views; capture true module-specific
paths (including Number Walls), not a forced shared shader. Images record source,
settings, backend and decoded hash; image health is not mathematical qualification.

New harnesses/fixtures and commands named in tasks are **proposed, unrun**. No test,
Flutter build, Rust build, install, benchmark or device journey ran during planning.
All implementation checks retain the pinned offline gate in AGENTS.md. First-round
Rust uses the existing 1.95.0 toolchain with task-local PATH; dependencies/codegen
must be provisioned in an isolated cache during execution, then tested locked/offline.
A missing cache/download is reported as setup failure, never a skipped pass.
Do not install packages or update Flutter during planning.

Risk/guard map: lost exact preset values → tagged decimal/enum replay fixtures;
stale sessions/exports → identity/revision lifecycle tests; false GPU success → real
source-bound readback and platform-specific texture gate. Frame tolerances for each
ported family must be chosen from M0 evidence, with analytic classification exact
where defined; do not invent one global SSIM threshold before baseline measurements.

Builder dispositions: ID namespace, decimal integers, controller/precision ceilings,
float/sampler ABI and Linux-copy claims are resolved above; build-file layout and
matched FRB patch selection are worker-reversible. Device transport/contention,
hardware-GPU timing and browser availability remain unassessed live checks, not
owner approval questions or reasons to block independent offline work. Follow the
standing Waydroid diagnosis/consent contract, coordinate ACAD-013-4142ef42, and never
demand a physical phone in place of Waydroid. Physical/hardware claims stay separate.
A fresh read-only builder review found two material verification gaps, both resolved
in RUST-M1-BRIDGE: compile Web with RUST_CORE both false and true, and use the
existing reserved-port native driver wrapper for later Linux smoke, not
`flutter test -d linux`. The wrapper must receive an actual task port lease and
private TMPDIR and return terminal protocol success with owned-process cleanup.
These procedures are planned, not run. No missing product decision remains for
this first offline batch. Live transport and capacity remain unassessed.

Expected first-round implementation delivery: five bounded changes/merges with the
repository's required review/integration gates, separate from this planning commit;
no measured delivery-time or runtime guarantee. Next-round planning must reconcile
M0/M1 reports and native qualification before admitting state migration and the
later texture spike. The goal remains unmet until final proof, not until the first
queue empties. An already-authorized runner can continue the chain; this session
starts none. Stop the chain by placing RUST-PLAN-02 in Needs decision.

Planning checks: `autowork capabilities` reported prepare_api 4, and consumer
preparation returned READY with no actions, in-flight contracts or pending migration.
Existing unrelated legacy-source/goal diagnostics remain outside this migration.
Final task validation passed: 123 tasks, 21 goals, no drafts; the six new task
records and goal were read back. No implementation checks were run. Selection is
assessed separately from committed-store contents; runtime/ownership admission and
remote inclusion are not established by this plan.
