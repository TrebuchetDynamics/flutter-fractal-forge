# Deep Zoom Precision Ladder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a coherent deep-zoom precision ladder for 2D escape-time fractals on Android: smooth preview while interacting, exact double-double refinement after idle, automatic-first precision UI, and deterministic Maestro regressions.

**Architecture:** Introduce a double-double numeric foundation and canonical viewport, attach precision profiles to 2D escape-time modules, centralize tier selection in a precision coordinator, keep GPU preview inside `FractalRenderer`, move exact refine composition to the viewer layer, and extend the CPU isolate renderer to evaluate escape-time families with double-double center coordinates.

**Tech Stack:** Flutter, Provider, SharedPreferences, custom double-double arithmetic, FragmentShader GPU preview, CPU tile isolate renderer, Flutter test, `integration_test`, Maestro CLI

---

## File Structure

### Core Numeric + Viewport

- Create: `lib/features/renderer/double_double.dart`
  - Immutable double-double scalar type (`hi`, `lo`) with normalized add/subtract/multiply helpers.
- Create: `lib/features/renderer/deep_zoom_viewport.dart`
  - Canonical 2D viewport (`centerX`, `centerY`, `zoom`) backed by `DoubleDouble`.
- Create: `lib/features/renderer/dd_complex.dart`
  - Double-double complex-number helpers for exact escape-time iteration.

### Precision Metadata + Decision Layer

- Create: `lib/core/modules/precision_profile.dart`
  - Precision preview/refine kinds, formula families, and threshold metadata for 2D escape-time modules.
- Create: `lib/features/renderer/precision_coordinator.dart`
  - Single decision layer that maps module + viewport + interaction + user preference to preview/refine state.
- Modify: `lib/core/services/renderer_settings_service.dart`
  - Introduce the shared `PrecisionPreference` enum before persistence/UI wiring.
- Modify: `lib/core/modules/fractal_module.dart`
  - Add optional `precisionProfile`.
- Modify: `lib/core/modules/builders/escape_time_builder.dart`
  - Attach default escape-time precision profiles for catalog modules.
- Modify: `lib/core/modules/julia_module.dart`
  - Attach Julia precision profile.
- Modify: `lib/core/modules/phoenix_module.dart`
  - Attach Phoenix precision profile.
- Modify: `lib/features/renderer/deep_zoom_precision_policy.dart`
  - Convert into a thin compatibility wrapper around module precision profiles so existing tests and call sites can be updated incrementally.

### State + Interaction

- Modify: `lib/features/renderer/providers/fractal_provider.dart`
  - Store canonical deep viewport, keep legacy `FractalViewState` in sync, expose viewport update helpers.
- Modify: `lib/features/renderer/gesture_handler.dart`
  - Perform pan/zoom against `DeepZoomViewport` with one shared zoom envelope (`1e-9 .. 1e30`).

### Rendering

- Modify: `lib/features/renderer/fractal_renderer.dart`
  - GPU preview only; select standard/df2/perturb preview based on `precisionProfile` and `PrecisionCoordinator`.
- Modify: `lib/features/renderer/cpu_fractal_renderer.dart`
  - Accept canonical viewport + exact/preview mode and use isolate requests that preserve low-order center terms.
- Modify: `lib/features/renderer/cpu_render_isolate.dart`
  - Carry `centerXHi`, `centerXLo`, `centerYHi`, `centerYLo`, exact-mode flag, and formula family through tile rendering.
- Create: `lib/features/renderer/dd_escape_time.dart`
  - Exact escape-time evaluator that uses `DoubleDouble` + `DDComplex`.
- Modify: `lib/features/viewer/components/cpu_fallback_pane.dart`
  - Feed exact viewport/refine mode into `CpuFractalRenderer` and keep snapshot fade behavior.

### Viewer UI + Settings

- Modify: `lib/core/services/renderer_settings_service.dart`
  - Persist `PrecisionPreference` independently from backend mode.
- Modify: `lib/features/viewer/fractal_viewer_screen.dart`
  - Compose preview vs exact refine at the viewer layer and replace the old deep-zoom banner with a precision chip/menu.
- Modify: `lib/features/viewer/viewer_gpu_health.dart`
  - Remove deep-zoom hysteresis ownership; limit this mixin to GPU health fallback and backend mode.
- Modify: `lib/features/viewer/viewer_hud.dart`
  - Render the precision chip and semantics labels.
- Modify: `lib/features/viewer/components/fractal_navigation_dock.dart`
  - Keep deterministic zoom controls exposed and add stable keys/semantics if tests need them.

### Tests + Maestro

- Create: `test/double_double_test.dart`
- Create: `test/deep_zoom_viewport_test.dart`
- Create: `test/fractal_controller_precision_state_test.dart`
- Create: `test/precision_coordinator_test.dart`
- Create: `test/dd_escape_time_test.dart`
- Modify: `test/deep_zoom_precision_policy_test.dart`
- Modify: `test/renderer_settings_service_test.dart`
- Modify: `test/fractal_renderer_gesture_test.dart`
- Modify: `test/fractal_viewer_screen_widget_test.dart`
- Modify: `test/a11y/viewer_screen_a11y_test.dart`
- Create: `integration_test/deep_zoom_precision_flow_test.dart`
- Create: `.maestro/deep_zoom/00_launch.yaml`
- Create: `.maestro/deep_zoom/10_precision_auto.yaml`
- Create: `.maestro/deep_zoom/20_precision_lock.yaml`
- Create: `scripts/run-maestro-deep-zoom.sh`

## Task 1: Add The Double-Double Numeric Foundation

**Files:**
- Create: `lib/features/renderer/double_double.dart`
- Test: `test/double_double_test.dart`

- [ ] **Step 1: Write the failing numeric tests**

```dart
// test/double_double_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/renderer/double_double.dart';

void main() {
  group('DoubleDouble', () {
    test('keeps a low-order remainder next to a large high part', () {
      final value = DoubleDouble.fromParts(-0.75, 1e-18);
      final doubled = value * DoubleDouble.fromDouble(2.0);

      expect(doubled.hi, closeTo(-1.5, 1e-15));
      expect(doubled.lo, closeTo(2e-18, 1e-24));
    });

    test('preserves cancellation better than plain double addition', () {
      final a = DoubleDouble.fromDouble(1e16);
      final b = DoubleDouble.fromDouble(1.0);
      final c = (a + b) - a;

      expect(c.toDouble(), 1.0);
    });

    test('divides by a double without dropping the low component', () {
      final value = DoubleDouble.fromParts(3.0, 3e-16);
      final halved = value.divDouble(2.0);

      expect(halved.hi, closeTo(1.5, 1e-15));
      expect(halved.lo, closeTo(1.5e-16, 1e-22));
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `/home/xel/flutter/bin/flutter test test/double_double_test.dart`

Expected: FAIL with missing `double_double.dart` symbols such as `DoubleDouble`.

- [ ] **Step 3: Implement the numeric primitive**

```dart
// lib/features/renderer/double_double.dart
import 'package:flutter/foundation.dart';

@immutable
class DoubleDouble implements Comparable<DoubleDouble> {
  final double hi;
  final double lo;

  const DoubleDouble._(this.hi, this.lo);

  factory DoubleDouble.fromDouble(double value) => DoubleDouble._(value, 0.0);

  factory DoubleDouble.fromParts(double hi, double lo) {
    final normalized = _quickTwoSum(hi, lo);
    return DoubleDouble._(normalized.$1, normalized.$2);
  }

  static const zero = DoubleDouble._(0.0, 0.0);

  DoubleDouble operator +(DoubleDouble other) {
    final s = _twoSum(hi, other.hi);
    final t = _twoSum(lo, other.lo);
    final e = s.$2 + t.$1;
    final u = _quickTwoSum(s.$1, e);
    return DoubleDouble.fromParts(u.$1, u.$2 + t.$2);
  }

  DoubleDouble operator -(DoubleDouble other) {
    return this + DoubleDouble.fromParts(-other.hi, -other.lo);
  }

  DoubleDouble operator *(DoubleDouble other) {
    final p = _twoProd(hi, other.hi);
    final err = hi * other.lo + lo * other.hi + p.$2 + lo * other.lo;
    final normalized = _quickTwoSum(p.$1, err);
    return DoubleDouble.fromParts(normalized.$1, normalized.$2);
  }

  DoubleDouble divDouble(double value) {
    final q1 = hi / value;
    final ddQ1 = DoubleDouble.fromDouble(q1);
    final remainder = this - (ddQ1 * DoubleDouble.fromDouble(value));
    final q2 = remainder.hi / value;
    return DoubleDouble.fromParts(q1, q2);
  }

  DoubleDouble abs() =>
      isNegative ? DoubleDouble.fromParts(-hi, -lo) : this;

  bool get isNegative => hi < 0 || (hi == 0.0 && lo < 0);

  double toDouble() => hi + lo;

  @override
  int compareTo(DoubleDouble other) {
    if (hi < other.hi) return -1;
    if (hi > other.hi) return 1;
    if (lo < other.lo) return -1;
    if (lo > other.lo) return 1;
    return 0;
  }

  static (double, double) _quickTwoSum(double a, double b) {
    final s = a + b;
    return (s, b - (s - a));
  }

  static (double, double) _twoSum(double a, double b) {
    final s = a + b;
    final bb = s - a;
    final err = (a - (s - bb)) + (b - bb);
    return (s, err);
  }

  static (double, double) _twoProd(double a, double b) {
    final p = a * b;
    const splitter = 134217729.0;
    final aSplit = splitter * a;
    final aHi = aSplit - (aSplit - a);
    final aLo = a - aHi;
    final bSplit = splitter * b;
    final bHi = bSplit - (bSplit - b);
    final bLo = b - bHi;
    final err = ((aHi * bHi - p) + aHi * bLo + aLo * bHi) + aLo * bLo;
    return (p, err);
  }
}
```

- [ ] **Step 4: Run the numeric tests to verify they pass**

Run: `/home/xel/flutter/bin/flutter test test/double_double_test.dart`

Expected: PASS with `3 passed`.

- [ ] **Step 5: Commit**

```bash
git add test/double_double_test.dart lib/features/renderer/double_double.dart
git commit -m "feat: add double-double arithmetic foundation"
```

## Task 2: Add The Canonical Deep-Zoom Viewport And Sync It Through The Controller

**Files:**
- Create: `lib/features/renderer/deep_zoom_viewport.dart`
- Modify: `lib/features/renderer/providers/fractal_provider.dart`
- Modify: `lib/features/renderer/gesture_handler.dart`
- Test: `test/deep_zoom_viewport_test.dart`
- Test: `test/fractal_controller_precision_state_test.dart`
- Test: `test/fractal_renderer_gesture_test.dart`

- [ ] **Step 1: Write the failing viewport and controller tests**

```dart
// test/deep_zoom_viewport_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/renderer/deep_zoom_viewport.dart';
import 'package:flutter_fractals/features/renderer/double_double.dart';

void main() {
  test('zoomAround keeps the focused world point fixed', () {
    final viewport = DeepZoomViewport.initial().copyWith(
      centerX: DoubleDouble.fromDouble(-0.75),
      centerY: DoubleDouble.fromDouble(0.1),
      zoom: 1e12,
    );

    final next = viewport.zoomAround(
      normalizedX: -0.2,
      normalizedY: 0.35,
      targetZoom: 1e18,
    );

    final before = viewport.worldPointAt(-0.2, 0.35);
    final after = next.worldPointAt(-0.2, 0.35);
    expect((after.x - before.x).abs().toDouble(), lessThan(1e-20));
    expect((after.y - before.y).abs().toDouble(), lessThan(1e-20));
  });
}
```

```dart
// test/fractal_controller_precision_state_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/renderer/deep_zoom_viewport.dart';

void main() {
  test('controller keeps canonical viewport and legacy view in sync', () {
    final controller = FractalController(ModuleRegistry());
    final viewport = DeepZoomViewport.initial().copyWith(zoom: 1e24);

    controller.updateDeepViewport(viewport);

    expect(controller.deepViewport.zoom, 1e24);
    expect(controller.view.zoom, 1e24);
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `/home/xel/flutter/bin/flutter test test/deep_zoom_viewport_test.dart test/fractal_controller_precision_state_test.dart test/fractal_renderer_gesture_test.dart`

Expected: FAIL with missing `DeepZoomViewport`, missing `updateDeepViewport`, and old gesture code still clamping at the renderer/controller limits.

- [ ] **Step 3: Implement the viewport and controller synchronization**

```dart
// lib/features/renderer/deep_zoom_viewport.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/features/renderer/double_double.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:vector_math/vector_math.dart';

@immutable
class DeepZoomPoint {
  final DoubleDouble x;
  final DoubleDouble y;
  const DeepZoomPoint(this.x, this.y);
}

@immutable
class DeepZoomViewport {
  final DoubleDouble centerX;
  final DoubleDouble centerY;
  final double zoom;

  const DeepZoomViewport({
    required this.centerX,
    required this.centerY,
    required this.zoom,
  });

  factory DeepZoomViewport.initial() => DeepZoomViewport(
        centerX: DoubleDouble.zero,
        centerY: DoubleDouble.zero,
        zoom: 1.0,
      );

  factory DeepZoomViewport.fromView(FractalViewState view) => DeepZoomViewport(
        centerX: DoubleDouble.fromDouble(view.pan.x),
        centerY: DoubleDouble.fromDouble(view.pan.y),
        zoom: view.zoom,
      );

  DeepZoomViewport copyWith({
    DoubleDouble? centerX,
    DoubleDouble? centerY,
    double? zoom,
  }) {
    return DeepZoomViewport(
      centerX: centerX ?? this.centerX,
      centerY: centerY ?? this.centerY,
      zoom: zoom ?? this.zoom,
    );
  }

  DeepZoomPoint worldPointAt(double normalizedX, double normalizedY) {
    final invZoom = DoubleDouble.fromDouble(1.0 / zoom);
    return DeepZoomPoint(
      centerX + DoubleDouble.fromDouble(normalizedX) * invZoom,
      centerY + DoubleDouble.fromDouble(normalizedY) * invZoom,
    );
  }

  DeepZoomViewport zoomAround({
    required double normalizedX,
    required double normalizedY,
    required double targetZoom,
  }) {
    final anchor = worldPointAt(normalizedX, normalizedY);
    final nextInvZoom = DoubleDouble.fromDouble(1.0 / targetZoom);
    return DeepZoomViewport(
      centerX: anchor.x - DoubleDouble.fromDouble(normalizedX) * nextInvZoom,
      centerY: anchor.y - DoubleDouble.fromDouble(normalizedY) * nextInvZoom,
      zoom: targetZoom,
    );
  }

  FractalViewState toLegacyView(Vector3 rotation) {
    return FractalViewState(
      pan: Vector2(centerX.toDouble(), centerY.toDouble()),
      zoom: zoom,
      rotation: rotation,
    );
  }
}
```

```dart
// lib/features/renderer/providers/fractal_provider.dart
DeepZoomViewport _deepViewport = DeepZoomViewport.initial();

DeepZoomViewport get deepViewport => _deepViewport;

void updateDeepViewport(DeepZoomViewport viewport) {
  final minZoom = _moduleMinZoom(_module.id);
  final clampedZoom = viewport.zoom.clamp(minZoom, 1e30).toDouble();
  _deepViewport = viewport.copyWith(zoom: clampedZoom);
  _view = _deepViewport.toLegacyView(_view.rotation);
  _lastAdaptiveZoom = clampedZoom;
  notifyListeners();
}

void resetView() {
  _deepViewport = DeepZoomViewport.initial();
  _view = _deepViewport.toLegacyView(Vector3.zero());
  _lastAdaptiveZoom = _view.zoom;
  notifyListeners();
}
```

```dart
// lib/features/renderer/gesture_handler.dart
void _applyZoomAroundFocal({
  required FractalController controller,
  required double targetZoom,
  required Offset focalPoint,
  double? explicitRotationZ,
}) {
  final renderBox = context.findRenderObject() as RenderBox?;
  final size = renderBox?.size;
  final zoom = _rubberBand(targetZoom, _kMinZoom, _kMaxZoom);
  if (size == null) {
    controller.updateDeepViewport(
      controller.deepViewport.copyWith(zoom: zoom),
    );
    return;
  }

  final scalePx = math.max(1.0, math.min(size.width, size.height));
  final n = _normalizedPoint(focalPoint, size, scalePx);
  controller.updateDeepViewport(
    controller.deepViewport.zoomAround(
      normalizedX: n.dx,
      normalizedY: n.dy,
      targetZoom: zoom,
    ),
  );
}
```

- [ ] **Step 4: Update the gesture tests for the new zoom ceiling**

```dart
// add to test/fractal_renderer_gesture_test.dart
testWidgets('double-tap can grow zoom past the legacy 1e12 ceiling', (tester) async {
  final controller = FractalController(ModuleRegistry());
  controller.updateDeepViewport(
    controller.deepViewport.copyWith(zoom: 9e29),
  );

  await tester.pumpWidget(buildTestWidget(controller));
  await tester.pumpAndSettle();

  await tester.tap(find.byType(FractalRenderer));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(find.byType(FractalRenderer));
  await tester.pumpAndSettle();

  expect(controller.deepViewport.zoom, greaterThan(9e29));
});
```

- [ ] **Step 5: Run the viewport/controller tests to verify they pass**

Run: `/home/xel/flutter/bin/flutter test test/deep_zoom_viewport_test.dart test/fractal_controller_precision_state_test.dart test/fractal_renderer_gesture_test.dart`

Expected: PASS with all new viewport/controller tests green.

- [ ] **Step 6: Commit**

```bash
git add \
  lib/features/renderer/deep_zoom_viewport.dart \
  lib/features/renderer/providers/fractal_provider.dart \
  lib/features/renderer/gesture_handler.dart \
  test/deep_zoom_viewport_test.dart \
  test/fractal_controller_precision_state_test.dart \
  test/fractal_renderer_gesture_test.dart
git commit -m "feat: add canonical deep zoom viewport state"
```

## Task 3: Attach Precision Profiles And Add The Precision Coordinator

**Files:**
- Create: `lib/core/modules/precision_profile.dart`
- Create: `lib/features/renderer/precision_coordinator.dart`
- Modify: `lib/core/services/renderer_settings_service.dart`
- Modify: `lib/core/modules/fractal_module.dart`
- Modify: `lib/core/modules/builders/escape_time_builder.dart`
- Modify: `lib/core/modules/julia_module.dart`
- Modify: `lib/core/modules/phoenix_module.dart`
- Modify: `lib/features/renderer/deep_zoom_precision_policy.dart`
- Test: `test/precision_coordinator_test.dart`
- Test: `test/deep_zoom_precision_policy_test.dart`

- [ ] **Step 1: Write the failing coordinator and profile tests**

```dart
// test/precision_coordinator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/deep_zoom_viewport.dart';
import 'package:flutter_fractals/features/renderer/precision_coordinator.dart';

void main() {
  final registry = ModuleRegistry();
  final coordinator = PrecisionCoordinator();

  test('automatic mode keeps GPU preview while interacting at deep zoom', () {
    final module = registry.byId('mandelbrot');
    final decision = coordinator.decide(
      module: module,
      viewport: DeepZoomViewport.initial().copyWith(zoom: 1e20),
      isInteracting: true,
      preference: PrecisionPreference.automatic,
    );

    expect(decision.previewTier, PrecisionTier.extendedGpu);
    expect(decision.refineAfterIdle, isTrue);
    expect(decision.useCpuExactNow, isFalse);
  });

  test('locked precision forces exact refine immediately', () {
    final module = registry.byId('julia');
    final decision = coordinator.decide(
      module: module,
      viewport: DeepZoomViewport.initial().copyWith(zoom: 1e18),
      isInteracting: false,
      preference: PrecisionPreference.lockPrecision,
    );

    expect(decision.previewTier, PrecisionTier.precisionLocked);
    expect(decision.useCpuExactNow, isTrue);
  });
}
```

```dart
// add to test/deep_zoom_precision_policy_test.dart
test('reads exact-refine threshold from module precision profile', () {
  final registry = ModuleRegistry();
  final module = registry.byId('phoenix');
  final policy = DeepZoomPrecisionPolicy();

  expect(
    policy.shouldUseCpuFallback(moduleId: module.id, zoom: 1e18),
    isTrue,
  );
  expect(module.precisionProfile, isNotNull);
});
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `/home/xel/flutter/bin/flutter test test/precision_coordinator_test.dart test/deep_zoom_precision_policy_test.dart`

Expected: FAIL with missing `PrecisionPreference`, missing `precisionProfile`, and missing `PrecisionCoordinator`.

- [ ] **Step 3: Add the profile model and attach it to modules**

```dart
// lib/core/services/renderer_settings_service.dart
enum PrecisionPreference { automatic, lockPrecision, preferSpeed }
```

```dart
// lib/core/modules/precision_profile.dart
import 'package:flutter/foundation.dart';

enum PrecisionPreviewKind { standardGpu, df2Gpu, perturbGpu }
enum PrecisionRefineKind { none, cpuDoubleDouble }
enum EscapeTimeFormulaFamily {
  mandelbrot,
  julia,
  burningShip,
  tricorn,
  celtic,
  buffalo,
  multibrot3,
  multibrot4,
  multibrot5,
  phoenix,
}

@immutable
class PrecisionProfile {
  final PrecisionPreviewKind previewKind;
  final PrecisionRefineKind refineKind;
  final EscapeTimeFormulaFamily? formulaFamily;
  final double extendedGpuZoom;
  final double exactRefineZoom;

  const PrecisionProfile({
    required this.previewKind,
    required this.refineKind,
    required this.formulaFamily,
    required this.extendedGpuZoom,
    required this.exactRefineZoom,
  });

  bool get supportsExactRefine => refineKind == PrecisionRefineKind.cpuDoubleDouble;
}
```

```dart
// lib/core/modules/fractal_module.dart
import 'package:flutter_fractals/core/modules/precision_profile.dart';

final PrecisionProfile? precisionProfile;

const FractalModule({
  required this.id,
  required this.displayName,
  required this.dimension,
  required this.shaderAsset,
  required this.parameters,
  required this.defaultPreset,
  required this.builtInPresets,
  required this.setUniforms,
  this.precisionProfile,
});
```

```dart
// lib/core/modules/builders/escape_time_builder.dart
import 'package:flutter_fractals/core/modules/precision_profile.dart';

EscapeTimeFormulaFamily _familyForId(String id) {
  switch (id) {
    case 'julia':
      return EscapeTimeFormulaFamily.julia;
    case 'burning_ship':
      return EscapeTimeFormulaFamily.burningShip;
    case 'tricorn':
      return EscapeTimeFormulaFamily.tricorn;
    case 'celtic':
      return EscapeTimeFormulaFamily.celtic;
    case 'buffalo':
      return EscapeTimeFormulaFamily.buffalo;
    case 'multibrot3':
      return EscapeTimeFormulaFamily.multibrot3;
    case 'multibrot4':
      return EscapeTimeFormulaFamily.multibrot4;
    case 'multibrot5':
      return EscapeTimeFormulaFamily.multibrot5;
    case 'phoenix':
      return EscapeTimeFormulaFamily.phoenix;
    case 'mandelbrot':
    default:
      return EscapeTimeFormulaFamily.mandelbrot;
  }
}

PrecisionPreviewKind _previewKindFor(String id) {
  if (id == 'mandelbrot') return PrecisionPreviewKind.df2Gpu;
  const perturbIds = {
    'burning_ship',
    'buffalo',
    'tricorn',
    'celtic',
    'phoenix',
    'multibrot3',
    'multibrot4',
    'multibrot5',
  };
  if (perturbIds.contains(id)) return PrecisionPreviewKind.perturbGpu;
  return PrecisionPreviewKind.standardGpu;
}

PrecisionProfile _defaultProfileFor(String id) {
  final previewKind = _previewKindFor(id);
  return PrecisionProfile(
    previewKind: previewKind,
    refineKind: PrecisionRefineKind.cpuDoubleDouble,
    formulaFamily: _familyForId(id),
    extendedGpuZoom: previewKind == PrecisionPreviewKind.standardGpu ? 1e5 : 5e6,
    exactRefineZoom: 1e14,
  );
}
```

- [ ] **Step 4: Implement the coordinator**

```dart
// lib/features/renderer/precision_coordinator.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/precision_profile.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/deep_zoom_viewport.dart';

enum PrecisionTier { realtimeGpu, extendedGpu, precisionRefine, precisionLocked }

@immutable
class PrecisionDecision {
  final PrecisionTier previewTier;
  final bool refineAfterIdle;
  final bool useCpuExactNow;
  final String chipLabel;

  const PrecisionDecision({
    required this.previewTier,
    required this.refineAfterIdle,
    required this.useCpuExactNow,
    required this.chipLabel,
  });
}

class PrecisionCoordinator {
  const PrecisionCoordinator();

  PrecisionDecision decide({
    required FractalModule module,
    required DeepZoomViewport viewport,
    required bool isInteracting,
    required PrecisionPreference preference,
  }) {
    final profile = module.precisionProfile;
    if (profile == null || module.dimension != FractalDimension.twoD) {
      return const PrecisionDecision(
        previewTier: PrecisionTier.realtimeGpu,
        refineAfterIdle: false,
        useCpuExactNow: false,
        chipLabel: 'GPU',
      );
    }

    final overExtended = viewport.zoom >= profile.extendedGpuZoom;
    final overExact = viewport.zoom >= profile.exactRefineZoom && profile.supportsExactRefine;

    if (preference == PrecisionPreference.preferSpeed) {
      return PrecisionDecision(
        previewTier: overExtended ? PrecisionTier.extendedGpu : PrecisionTier.realtimeGpu,
        refineAfterIdle: false,
        useCpuExactNow: false,
        chipLabel: overExtended ? 'Deep GPU' : 'GPU',
      );
    }

    if (preference == PrecisionPreference.lockPrecision && overExact) {
      return const PrecisionDecision(
        previewTier: PrecisionTier.precisionLocked,
        refineAfterIdle: true,
        useCpuExactNow: true,
        chipLabel: 'Precision Locked',
      );
    }

    return PrecisionDecision(
      previewTier: overExtended ? PrecisionTier.extendedGpu : PrecisionTier.realtimeGpu,
      refineAfterIdle: overExact && !isInteracting,
      useCpuExactNow: overExact && !isInteracting,
      chipLabel: overExact ? 'Precision' : (overExtended ? 'Deep GPU' : 'GPU'),
    );
  }
}
```

- [ ] **Step 5: Run the coordinator/profile tests to verify they pass**

Run: `/home/xel/flutter/bin/flutter test test/precision_coordinator_test.dart test/deep_zoom_precision_policy_test.dart`

Expected: PASS with coordinator decisions matching the configured profiles.

- [ ] **Step 6: Commit**

```bash
git add \
  lib/core/modules/precision_profile.dart \
  lib/features/renderer/precision_coordinator.dart \
  lib/core/services/renderer_settings_service.dart \
  lib/core/modules/fractal_module.dart \
  lib/core/modules/builders/escape_time_builder.dart \
  lib/core/modules/julia_module.dart \
  lib/core/modules/phoenix_module.dart \
  lib/features/renderer/deep_zoom_precision_policy.dart \
  test/precision_coordinator_test.dart \
  test/deep_zoom_precision_policy_test.dart
git commit -m "feat: add precision profiles and coordinator"
```

## Task 4: Extend The CPU Refine Backend To Use Double-Double Escape-Time Evaluation

**Files:**
- Create: `lib/features/renderer/dd_complex.dart`
- Create: `lib/features/renderer/dd_escape_time.dart`
- Modify: `lib/features/renderer/cpu_render_isolate.dart`
- Modify: `lib/features/renderer/cpu_fractal_renderer.dart`
- Modify: `lib/features/viewer/components/cpu_fallback_pane.dart`
- Test: `test/dd_escape_time_test.dart`
- Test: `test/deep_zoom_quality_test.dart`

- [ ] **Step 1: Write the failing exact-refine tests**

```dart
// test/dd_escape_time_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/precision_profile.dart';
import 'package:flutter_fractals/features/renderer/dd_escape_time.dart';
import 'package:flutter_fractals/features/renderer/double_double.dart';

void main() {
  test('exact mandelbrot evaluator preserves low-order center offsets', () {
    final result = iterateEscapeTimeExact(
      family: EscapeTimeFormulaFamily.mandelbrot,
      centerX: DoubleDouble.fromParts(-0.743643887037151, 8e-19),
      centerY: DoubleDouble.fromParts(0.13182590420533, -7e-19),
      dx: DoubleDouble.zero,
      dy: DoubleDouble.zero,
      iterations: 500,
      bailout: 4.0,
    );

    expect(result.iteration, greaterThan(0));
    expect(result.smoothIteration, greaterThan(0));
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `/home/xel/flutter/bin/flutter test test/dd_escape_time_test.dart test/deep_zoom_quality_test.dart`

Expected: FAIL with missing exact evaluator and isolate/cpu renderer not preserving low-order center components.

- [ ] **Step 3: Add the exact evaluator**

```dart
// lib/features/renderer/dd_complex.dart
import 'package:flutter_fractals/features/renderer/double_double.dart';

class DDComplex {
  final DoubleDouble re;
  final DoubleDouble im;

  const DDComplex(this.re, this.im);

  DDComplex square() => DDComplex(
        re * re - im * im,
        DoubleDouble.fromDouble(2.0) * re * im,
      );

  DDComplex absParts() => DDComplex(re.abs(), im.abs());
}
```

```dart
// lib/features/renderer/dd_escape_time.dart
import 'dart:math' as math;
import 'package:flutter_fractals/core/modules/precision_profile.dart';
import 'package:flutter_fractals/features/renderer/double_double.dart';
import 'package:flutter_fractals/features/renderer/dd_complex.dart';

class ExactEscapeResult {
  final int iteration;
  final double smoothIteration;
  const ExactEscapeResult(this.iteration, this.smoothIteration);
}

ExactEscapeResult iterateEscapeTimeExact({
  required EscapeTimeFormulaFamily family,
  required DoubleDouble centerX,
  required DoubleDouble centerY,
  required DoubleDouble dx,
  required DoubleDouble dy,
  required int iterations,
  required double bailout,
  required double juliaCX,
  required double juliaCY,
  required double phoenixP,
}) {
  final cx = centerX + dx;
  final cy = centerY + dy;
  var z = family == EscapeTimeFormulaFamily.julia
      ? DDComplex(cx, cy)
      : const DDComplex(DoubleDouble.zero, DoubleDouble.zero);
  var prev = const DDComplex(DoubleDouble.zero, DoubleDouble.zero);
  final bailout2 = bailout * bailout;

  for (var it = 0; it < iterations; it++) {
    final prevZ = z;
    switch (family) {
      case EscapeTimeFormulaFamily.mandelbrot:
        z = DDComplex(
          z.re * z.re - z.im * z.im + cx,
          DoubleDouble.fromDouble(2.0) * z.re * z.im + cy,
        );
        break;
      case EscapeTimeFormulaFamily.julia:
        z = DDComplex(
          z.re * z.re - z.im * z.im + DoubleDouble.fromDouble(juliaCX),
          DoubleDouble.fromDouble(2.0) * z.re * z.im + DoubleDouble.fromDouble(juliaCY),
        );
        break;
      case EscapeTimeFormulaFamily.tricorn:
        z = DDComplex(
          z.re * z.re - z.im * z.im + cx,
          DoubleDouble.fromDouble(-2.0) * z.re * z.im + cy,
        );
        break;
      case EscapeTimeFormulaFamily.burningShip:
        final absZ = z.absParts();
        z = DDComplex(
          absZ.re * absZ.re - absZ.im * absZ.im + cx,
          DoubleDouble.fromDouble(2.0) * absZ.re * absZ.im + cy,
        );
        break;
      case EscapeTimeFormulaFamily.celtic:
        final square = z.square();
        z = DDComplex(square.re.abs() + cx, square.im + cy);
        break;
      case EscapeTimeFormulaFamily.buffalo:
        final square = z.square();
        z = DDComplex(square.re.abs() + cx, square.im.abs() + cy);
        break;
      case EscapeTimeFormulaFamily.multibrot3:
        final z2 = z.square();
        z = DDComplex(
          z2.re * prevZ.re - z2.im * prevZ.im + cx,
          z2.re * prevZ.im + z2.im * prevZ.re + cy,
        );
        break;
      case EscapeTimeFormulaFamily.multibrot4:
        final z2 = z.square();
        final z4 = z2.square();
        z = DDComplex(z4.re + cx, z4.im + cy);
        break;
      case EscapeTimeFormulaFamily.multibrot5:
        final z2 = z.square();
        final z4 = z2.square();
        z = DDComplex(
          z4.re * prevZ.re - z4.im * prevZ.im + cx,
          z4.re * prevZ.im + z4.im * prevZ.re + cy,
        );
        break;
      case EscapeTimeFormulaFamily.phoenix:
        z = DDComplex(
          z.re * z.re - z.im * z.im + DoubleDouble.fromDouble(juliaCX) + prev.re * DoubleDouble.fromDouble(phoenixP),
          DoubleDouble.fromDouble(2.0) * z.re * z.im + DoubleDouble.fromDouble(juliaCY) + prev.im * DoubleDouble.fromDouble(phoenixP),
        );
        break;
    }
    prev = prevZ;

    final mag2 = z.re.toDouble() * z.re.toDouble() + z.im.toDouble() * z.im.toDouble();
    if (mag2 > bailout2) {
      final smooth = it + 1 - math.log(math.log(mag2)) / math.ln2;
      return ExactEscapeResult(it, smooth);
    }
  }

  return ExactEscapeResult(iterations, iterations.toDouble());
}
```

- [ ] **Step 4: Thread exact center coordinates through the isolate request**

```dart
// lib/features/renderer/cpu_render_isolate.dart
final class CpuTileRenderRequest {
  const CpuTileRenderRequest({
    required this.moduleId,
    required this.formulaFamily,
    required this.centerXHi,
    required this.centerXLo,
    required this.centerYHi,
    required this.centerYLo,
    required this.zoom,
    required this.iterations,
    required this.bailout,
    required this.juliaCX,
    required this.juliaCY,
    required this.fullWidth,
    required this.fullHeight,
    required this.x0,
    required this.y0,
    required this.w,
    required this.h,
    required this.sampleCount,
    required this.exactPrecision,
  });

  final EscapeTimeFormulaFamily formulaFamily;
  final double centerXHi;
  final double centerXLo;
  final double centerYHi;
  final double centerYLo;
  final bool exactPrecision;
}
```

```dart
// lib/features/renderer/cpu_fractal_renderer.dart
final DeepZoomViewport viewport;
final bool exactPrecision;

final tileReq = CpuTileRenderRequest(
  moduleId: widget.module.id,
  formulaFamily: widget.module.precisionProfile!.formulaFamily!,
  centerXHi: widget.viewport.centerX.hi,
  centerXLo: widget.viewport.centerX.lo,
  centerYHi: widget.viewport.centerY.hi,
  centerYLo: widget.viewport.centerY.lo,
  zoom: widget.viewport.zoom,
  iterations: iterations,
  bailout: bailout,
  juliaCX: juliaC.x,
  juliaCY: juliaC.y,
  fullWidth: width,
  fullHeight: height,
  x0: tile.$1,
  y0: tile.$2,
  w: tile.$3,
  h: tile.$4,
  sampleCount: sampleCount,
  exactPrecision: widget.exactPrecision,
);
```

- [ ] **Step 5: Run the exact-refine tests to verify they pass**

Run: `/home/xel/flutter/bin/flutter test test/dd_escape_time_test.dart test/deep_zoom_quality_test.dart`

Expected: PASS with exact evaluator tests green and deep-zoom quality tests updated to reflect the new exact path.

- [ ] **Step 6: Commit**

```bash
git add \
  lib/features/renderer/dd_complex.dart \
  lib/features/renderer/dd_escape_time.dart \
  lib/features/renderer/cpu_render_isolate.dart \
  lib/features/renderer/cpu_fractal_renderer.dart \
  lib/features/viewer/components/cpu_fallback_pane.dart \
  test/dd_escape_time_test.dart \
  test/deep_zoom_quality_test.dart
git commit -m "feat: add exact escape-time CPU refine path"
```

## Task 5: Compose Precision At The Viewer Layer And Add Automatic-First UI

**Files:**
- Modify: `lib/core/services/renderer_settings_service.dart`
- Modify: `lib/features/renderer/fractal_renderer.dart`
- Modify: `lib/features/viewer/viewer_gpu_health.dart`
- Modify: `lib/features/viewer/fractal_viewer_screen.dart`
- Modify: `lib/features/viewer/viewer_hud.dart`
- Modify: `lib/features/viewer/components/fractal_navigation_dock.dart`
- Modify: `test/renderer_settings_service_test.dart`
- Modify: `test/fractal_viewer_screen_widget_test.dart`
- Modify: `test/a11y/viewer_screen_a11y_test.dart`

- [ ] **Step 1: Write the failing settings and HUD tests**

```dart
// add to test/renderer_settings_service_test.dart
test('persists precision preference independently from backend mode', () async {
  final prefs = await SharedPreferences.getInstance();
  final service = RendererSettingsService(prefs);

  await service.setPrecisionPreference(PrecisionPreference.lockPrecision);

  final reloaded = RendererSettingsService(prefs);
  expect(reloaded.precisionPreference, PrecisionPreference.lockPrecision);
  expect(reloaded.backendMode, RendererBackendMode.auto);
});
```

```dart
// add to test/fractal_viewer_screen_widget_test.dart
testWidgets('viewer shows precision chip and menu entries', (tester) async {
  await tester.pumpWidget(buildViewerApp());
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('viewerPrecisionChip')), findsOneWidget);
  await tester.tap(find.byKey(const Key('viewerPrecisionChip')));
  await tester.pumpAndSettle();

  expect(find.text('Automatic'), findsOneWidget);
  expect(find.text('Lock precision'), findsOneWidget);
  expect(find.text('Prefer speed'), findsOneWidget);
});
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `/home/xel/flutter/bin/flutter test test/renderer_settings_service_test.dart test/fractal_viewer_screen_widget_test.dart test/a11y/viewer_screen_a11y_test.dart`

Expected: FAIL because `viewerPrecisionChip` is missing, precision preference persistence is not implemented yet, and the viewer still shows the old deep-zoom banner instead of the chip/menu.

- [ ] **Step 3: Add the persisted precision preference**

```dart
// lib/core/services/renderer_settings_service.dart
static const String _keyPrecisionPreference = 'renderer_precision_preference';

PrecisionPreference _precisionPreference;

RendererSettingsService(this._prefs)
    : _backendMode = _decode(_prefs.getString(_keyBackendMode)),
      _precisionPreference = _decodePrecision(
        _prefs.getString(_keyPrecisionPreference),
      );

PrecisionPreference get precisionPreference => _precisionPreference;

Future<void> setPrecisionPreference(PrecisionPreference preference) async {
  if (_precisionPreference == preference) return;
  _precisionPreference = preference;
  await _prefs.setString(_keyPrecisionPreference, preference.name);
  notifyListeners();
}
```

- [ ] **Step 4: Replace the old deep-zoom banner with a precision chip + menu**

```dart
// lib/features/viewer/viewer_hud.dart
Widget _viewerBuildPrecisionChip(
  _FractalViewerScreenState state,
  BuildContext context,
) {
  return Semantics(
    label: 'Precision mode ${state._precisionDecision.chipLabel}',
    button: true,
    child: GestureDetector(
      key: const Key('viewerPrecisionChip'),
      onTap: () => state._openPrecisionMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.cyan.withValues(alpha: 0.7)),
        ),
        child: Text(
          state._precisionDecision.chipLabel,
          key: const Key('viewerPrecisionChipText'),
          style: const TextStyle(color: Colors.cyan, fontSize: 11),
        ),
      ),
    ),
  );
}
```

```dart
// lib/features/viewer/fractal_viewer_screen.dart
final PrecisionCoordinator _precisionCoordinator = const PrecisionCoordinator();
late PrecisionDecision _precisionDecision;
bool _viewerInteractionActive = false;

void _refreshPrecisionDecision() {
  final controller = context.read<FractalController>();
  final settings = context.read<RendererSettingsService>();
  _precisionDecision = _precisionCoordinator.decide(
    module: controller.module,
    viewport: controller.deepViewport,
    isInteracting: _viewerInteractionActive,
    preference: settings.precisionPreference,
  );
}

Future<void> _openPrecisionMenu(BuildContext context) async {
  final selection = await showMenu<PrecisionPreference>(
    context: context,
    position: const RelativeRect.fromLTRB(12, 96, 0, 0),
    items: const [
      PopupMenuItem(value: PrecisionPreference.automatic, child: Text('Automatic')),
      PopupMenuItem(value: PrecisionPreference.lockPrecision, child: Text('Lock precision')),
      PopupMenuItem(value: PrecisionPreference.preferSpeed, child: Text('Prefer speed')),
    ],
  );
  if (selection != null) {
    await context.read<RendererSettingsService>().setPrecisionPreference(selection);
    setState(_refreshPrecisionDecision);
  }
}
```

- [ ] **Step 5: Move preview/refine composition to the viewer and keep GPU health fallback separate**

```dart
// lib/features/viewer/fractal_viewer_screen.dart
final useHealthFallback = _backendDecision.backend == RendererBackend.cpu;
final useExactRefine = !useHealthFallback && _precisionDecision.useCpuExactNow;

child: useHealthFallback
    ? FractalRenderer(
        overrideChild: CpuFallbackPane(
          boundaryKey: _fractalKeyA,
          initialSnapshot: _lastGpuSnapshot,
          viewport: controller.deepViewport,
          exactPrecision: true,
        ),
      )
    : FractalRenderer(
        boundaryKey: _fractalKeyA,
        animationEnabled: !_freezeFrameForExport,
      ),

if (useExactRefine)
  Positioned.fill(
    child: IgnorePointer(
      child: CpuFallbackPane(
        boundaryKey: _fractalKeyA,
        initialSnapshot: _lastGpuSnapshot,
        viewport: controller.deepViewport,
        exactPrecision: true,
      ),
    ),
  ),
```

- [ ] **Step 6: Run the settings and viewer tests to verify they pass**

Run: `/home/xel/flutter/bin/flutter test test/renderer_settings_service_test.dart test/fractal_viewer_screen_widget_test.dart test/a11y/viewer_screen_a11y_test.dart`

Expected: PASS with the chip/menu visible, persisted preference working, and semantics updated.

- [ ] **Step 7: Commit**

```bash
git add \
  lib/core/services/renderer_settings_service.dart \
  lib/features/renderer/fractal_renderer.dart \
  lib/features/viewer/viewer_gpu_health.dart \
  lib/features/viewer/fractal_viewer_screen.dart \
  lib/features/viewer/viewer_hud.dart \
  lib/features/viewer/components/fractal_navigation_dock.dart \
  test/renderer_settings_service_test.dart \
  test/fractal_viewer_screen_widget_test.dart \
  test/a11y/viewer_screen_a11y_test.dart
git commit -m "feat: add automatic-first precision viewer controls"
```

## Task 6: Add Android Integration Coverage And Maestro Deep-Zoom Flows

**Files:**
- Create: `integration_test/deep_zoom_precision_flow_test.dart`
- Create: `.maestro/deep_zoom/00_launch.yaml`
- Create: `.maestro/deep_zoom/10_precision_auto.yaml`
- Create: `.maestro/deep_zoom/20_precision_lock.yaml`
- Create: `scripts/run-maestro-deep-zoom.sh`

- [ ] **Step 1: Write the failing integration test**

```dart
// integration_test/deep_zoom_precision_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('deep zoom auto refine and precision lock work on Android', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'onboarding_version': OnboardingService.currentVersion,
    });

    final presetStore = await PresetStore.create();
    final accessibilityService = await AccessibilityService.create();
    final rendererSettingsService = await RendererSettingsService.create();

    await tester.pumpWidget(
      FlutterFractalsApp(
        presetStore: presetStore,
        accessibilityService: accessibilityService,
        rendererSettingsService: rendererSettingsService,
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byKey(const ValueKey('catalogModuleCard_mandelbrot')).first);
    await tester.pump(const Duration(seconds: 2));

    for (var i = 0; i < 18; i++) {
      await tester.tap(find.byKey(const ValueKey('dockZoomIn')));
      await tester.pump(const Duration(milliseconds: 120));
    }

    expect(find.byKey(const Key('viewerPrecisionChip')), findsOneWidget);
    expect(find.textContaining('Precision'), findsWidgets);
  });
}
```

- [ ] **Step 2: Run the integration test to verify it fails**

Run: `/home/xel/flutter/bin/flutter test integration_test/deep_zoom_precision_flow_test.dart -d android`

Expected: FAIL because precision UI/state and deep zoom handoff are not fully wired yet.

- [ ] **Step 3: Add deterministic Maestro flows**

```yaml
# .maestro/deep_zoom/00_launch.yaml
appId: com.trebuchetdynamics.fractal.forge
name: "Deep Zoom 00 - Launch"
tags:
  - deep-zoom
  - smoke
---
- launchApp:
    clearState: true
- tapOn:
    text: ".*Skip.*"
    optional: true
- assertVisible:
    text: ".*Fractal Catalog.*"
- tapOn:
    text: ".*Mandelbrot.*"
- assertVisible:
    text: ".*Precision.*"
    optional: true
```

```yaml
# .maestro/deep_zoom/10_precision_auto.yaml
appId: com.trebuchetdynamics.fractal.forge
name: "Deep Zoom 10 - Automatic Precision"
tags:
  - deep-zoom
  - regression
---
- repeat:
    times: 18
    commands:
      - tapOn:
          text: ".*Zoom In.*"
          waitToSettleTimeoutMs: 150
- assertVisible:
    text: ".*Precision.*"
- takeScreenshot: deep_zoom_auto_precision
```

```yaml
# .maestro/deep_zoom/20_precision_lock.yaml
appId: com.trebuchetdynamics.fractal.forge
name: "Deep Zoom 20 - Lock Precision"
tags:
  - deep-zoom
  - regression
---
- tapOn:
    text: ".*Precision.*"
- tapOn:
    text: "Lock precision"
- assertVisible:
    text: ".*Precision Locked.*"
- swipe:
    direction: LEFT
    duration: 500
- takeScreenshot: deep_zoom_precision_locked
- tapOn:
    text: ".*Reset.*"
    optional: true
```

```bash
#!/usr/bin/env bash
# scripts/run-maestro-deep-zoom.sh
set -euo pipefail

adb devices
~/.maestro/bin/maestro test .maestro/deep_zoom/ --format junit
```

- [ ] **Step 4: Run the Maestro suite to verify it fails for the right reason before the implementation is complete**

Run: `bash scripts/run-maestro-deep-zoom.sh`

Expected: FAIL on missing precision chip/menu assertions before the UI/state work is fully in place. If it fails earlier on launch/install issues, fix the harness first and re-run.

- [ ] **Step 5: Run full verification after implementation**

Run: `/home/xel/flutter/bin/flutter test test/double_double_test.dart test/deep_zoom_viewport_test.dart test/fractal_controller_precision_state_test.dart test/precision_coordinator_test.dart test/dd_escape_time_test.dart test/deep_zoom_precision_policy_test.dart test/renderer_settings_service_test.dart test/fractal_renderer_gesture_test.dart test/fractal_viewer_screen_widget_test.dart test/a11y/viewer_screen_a11y_test.dart`

Expected: PASS with all targeted unit/widget tests green.

Run: `/home/xel/flutter/bin/flutter test integration_test/deep_zoom_precision_flow_test.dart -d android`

Expected: PASS on the connected Android device.

Run: `bash scripts/run-maestro-deep-zoom.sh`

Expected: PASS with all three deep-zoom flows green.

- [ ] **Step 6: Commit**

```bash
git add \
  integration_test/deep_zoom_precision_flow_test.dart \
  .maestro/deep_zoom/00_launch.yaml \
  .maestro/deep_zoom/10_precision_auto.yaml \
  .maestro/deep_zoom/20_precision_lock.yaml \
  scripts/run-maestro-deep-zoom.sh
git commit -m "test: add deep zoom integration and maestro coverage"
```

## Self-Review Checklist

- [ ] Every 2D escape-time module that is supposed to participate in this system has a non-null `precisionProfile`.
- [ ] `FractalRenderer` no longer makes its own deep-zoom CPU fallback decision; it only owns GPU preview selection.
- [ ] Viewer composition owns exact refine overlay vs health-fallback CPU replacement.
- [ ] Controller and gestures use one shared max zoom (`1e30`) and one canonical viewport.
- [ ] Maestro flows depend on stable, visible UI labels and keys, not undocumented multi-touch gestures.

## Final Verification

Run all targeted tests and Android regressions before claiming completion:

```bash
/home/xel/flutter/bin/flutter test \
  test/double_double_test.dart \
  test/deep_zoom_viewport_test.dart \
  test/fractal_controller_precision_state_test.dart \
  test/precision_coordinator_test.dart \
  test/dd_escape_time_test.dart \
  test/deep_zoom_precision_policy_test.dart \
  test/renderer_settings_service_test.dart \
  test/fractal_renderer_gesture_test.dart \
  test/fractal_viewer_screen_widget_test.dart \
  test/a11y/viewer_screen_a11y_test.dart

/home/xel/flutter/bin/flutter test integration_test/deep_zoom_precision_flow_test.dart -d android

bash scripts/run-maestro-deep-zoom.sh
```
