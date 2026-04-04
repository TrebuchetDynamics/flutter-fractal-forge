# Refactoring Plan — Flutter Fractal Forge

> Archived refactor planning document. The file preserves earlier file counts and feature assumptions; use it as historical context, not as current architecture documentation.

> **Goal**: Maximize code reuse, streamline architecture for easier maintenance, debugging, and readability.

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
- `test/module_registry_widget_test.dart` — module registry tests
- `test/cpu_mandelbrot_visual_gate_test.dart` — CPU formula correctness
- `test/cpu_formula_coverage_test.dart` — CPU formula coverage
- `test/export_service_test.dart` — export logic
- `test/ar_overlay_screen_widget_test.dart` — screen tests
- `test/crash_reporter_test.dart` — crash reporter

### Test Strategy Per Refactoring

| Step | Verify with |
|---|---|
| R3 (param reader) | `flutter test` — all existing tests pass unchanged |
| R4 (dead modules) | `flutter test test/module_registry_widget_test.dart` — verify all modules still load |
| R1 (split viewer) | `flutter test test/fractal_viewer_screen_widget_test.dart` + `flutter test test/navigation_flow_widget_test.dart` |
| R2 (split renderer) | `flutter test test/fractal_renderer_widget_test.dart` + `flutter test test/fractal_renderer_gesture_test.dart` |
| R5 (CPU formulas) | `flutter test test/cpu_formula_coverage_test.dart` + `flutter test test/cpu_mandelbrot_visual_gate_test.dart` |
| R6 (shared UI) | `flutter test` — full suite |
| R7 (flatten main) | `flutter test test/widget_test.dart` + `flutter test test/home_screen_widget_test.dart` |

### Static Analysis Gate (before committing each step)

```bash
flutter analyze
```

### Integration Tests (final validation)

```bash
# Run on connected device or emulator
flutter test integration_test/user_flows_test.dart
flutter test integration_test/viewer_navigation_test.dart
```

---

## Files Changed Summary

| Action | Count | Total lines affected |
|---|---|---|
| New files (extracted) | ~12 | ~2500 (moved, not new logic) |
| Modified files | ~15 | ~3000 (imports, restructuring) |
| Deleted files | ~6 | ~1200 (dead code) |
| Net line change | — | **~-2000 lines** (less code overall) |
