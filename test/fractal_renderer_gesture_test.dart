import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

void main() {
  Widget buildTestWidget(
    FractalController controller, {
    VoidCallback? onOpenControls,
    VoidCallback? onOpenPresets,
    VoidCallback? onOpenExport,
  }) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: FractalRenderer(
              onOpenControls: onOpenControls,
              onOpenPresets: onOpenPresets,
              onOpenExport: onOpenExport,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('FractalRenderer drag updates pan; pinch updates zoom',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    final initialPan = controller.view.pan.clone();
    final initialZoom = controller.view.zoom;

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);

    // Drag gesture should update pan.
    await tester.drag(find.byType(FractalRenderer), const Offset(40, 20));
    await tester.pump();

    expect(controller.view.pan.x, isNot(equals(initialPan.x)));
    expect(controller.view.pan.y, isNot(equals(initialPan.y)));

    // Pinch gesture should update zoom.
    // Use two touch pointers moving apart.
    final center = tester.getCenter(find.byType(FractalRenderer));
    final g1 = await tester.createGesture();
    final g2 = await tester.createGesture();

    await g1.down(center + const Offset(-40, 0));
    await g2.down(center + const Offset(40, 0));
    await tester.pump();

    await g1.moveTo(center + const Offset(-70, 0));
    await g2.moveTo(center + const Offset(70, 0));
    await tester.pump();

    await g1.up();
    await g2.up();
    // Wait for double-tap timeout and momentum animations to complete
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(controller.view.zoom, isNot(equals(initialZoom)));
  });

  testWidgets('Double-tap zooms in by default', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    final initialZoom = controller.view.zoom;

    await tester.tap(find.byType(FractalRenderer));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(FractalRenderer));
    await tester.pumpAndSettle();

    expect(controller.view.zoom, greaterThan(initialZoom));
  });

  testWidgets('3D drag clamps pitch before rotation feels off-axis',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final registry = ModuleRegistry();
    final controller = FractalController(registry);
    controller.selectModule(registry.byId('mandelbulb'), animate: false);

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();
    final initialY = controller.view.rotation.y;

    await tester.drag(find.byType(FractalRenderer), const Offset(0, 2000));
    await tester.pump();

    expect(controller.view.rotation.x.abs(),
        lessThanOrEqualTo((67.5 * math.pi / 180.0) + 1e-6));
    expect(controller.view.rotation.y, closeTo(initialY, 0.001));

    // Drain fling/double-tap timers created by the synthetic large drag.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Module switch stops in-flight zoom animation', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final registry = ModuleRegistry();
    final controller = FractalController(registry);

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    final renderer = find.byType(FractalRenderer);
    await tester.tap(renderer);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(renderer);
    await tester.pump(const Duration(milliseconds: 50));

    controller.selectModule(
      registry.modules.firstWhere((m) => m.id != controller.module.id),
      resetView: true,
    );
    await tester.pump();
    expect(controller.view.zoom, 1.0);

    await tester.pump(const Duration(milliseconds: 300));
    expect(controller.view.zoom, 1.0);
  });

  testWidgets('Double-tap zoom anchors to tap coordinate', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    final initialZoom = controller.view.zoom;
    final initialPan = controller.view.pan.clone();

    final renderer = find.byType(FractalRenderer);
    final topLeft = tester.getTopLeft(renderer);
    final tapPoint = topLeft + const Offset(60, 60);

    await tester.tapAt(tapPoint);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(tapPoint);
    await tester.pumpAndSettle();

    expect(controller.view.zoom, greaterThan(initialZoom));
    expect(controller.view.pan.x, lessThan(initialPan.x));
    expect(controller.view.pan.y, lessThan(initialPan.y));
  });

  testWidgets('Long-press shows context menu', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    // Long-press to show context menu
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();

    // Verify context menu appears with expected items
    expect(find.text('Reset View'), findsOneWidget);
    expect(find.text('Open Controls'), findsOneWidget);
    expect(find.text('Open Presets'), findsOneWidget);
    expect(find.text('Randomize'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
  });

  testWidgets('Right-click (secondary tap) shows context menu',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    // Desktop mouse users right-click instead of holding a long-press.
    final center = tester.getCenter(find.byType(FractalRenderer));
    final gesture = await tester.startGesture(
      center,
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Reset View'), findsOneWidget);
    expect(find.text('Open Controls'), findsOneWidget);
    expect(find.text('Open Presets'), findsOneWidget);
    expect(find.text('Randomize'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
  });

  testWidgets('Context menu reset option resets view', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    // Modify the view
    await tester.drag(find.byType(FractalRenderer), const Offset(40, 20));
    await tester.pump();

    expect(controller.view.pan.x, isNot(0.0));

    // Long-press and select reset
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset View'));
    await tester.pumpAndSettle();

    // Verify view was reset
    expect(controller.view.pan.x, equals(0.0));
    expect(controller.view.pan.y, equals(0.0));
  });

  testWidgets('Context menu randomize option randomizes params',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    final initialParams = Map<String, Object>.from(controller.params);

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    // Long-press and select randomize
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Randomize'));
    await tester.pumpAndSettle();

    // Verify at least some params changed (randomization should affect something)
    bool anyChanged = false;
    for (final key in controller.params.keys) {
      if (controller.params[key] != initialParams[key]) {
        anyChanged = true;
        break;
      }
    }
    // Note: There's a small chance randomization produces the same values
    // but this is statistically unlikely with multiple parameters
    expect(anyChanged || controller.params.isEmpty, isTrue);
  });

  testWidgets('Context menu callbacks are invoked', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    bool controlsOpened = false;
    bool presetsOpened = false;
    bool exportOpened = false;

    await tester.pumpWidget(buildTestWidget(
      controller,
      onOpenControls: () => controlsOpened = true,
      onOpenPresets: () => presetsOpened = true,
      onOpenExport: () => exportOpened = true,
    ));
    await tester.pumpAndSettle();

    // Test controls callback
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Controls'));
    await tester.pumpAndSettle();
    expect(controlsOpened, isTrue);

    // Test presets callback
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Presets'));
    await tester.pumpAndSettle();
    expect(presetsOpened, isTrue);

    // Test export callback
    await tester.longPress(find.byType(FractalRenderer));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();
    expect(exportOpened, isTrue);
  });

  testWidgets('Gestures disabled prevents all interactions', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    final initialPan = controller.view.pan.clone();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: FractalRenderer(gesturesEnabled: false),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Try to drag - should have no effect
    await tester.drag(find.byType(FractalRenderer), const Offset(40, 20));
    await tester.pump();

    expect(controller.view.pan.x, equals(initialPan.x));
    expect(controller.view.pan.y, equals(initialPan.y));
  });

  testWidgets('Pinch-to-zoom is smooth with interpolation', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    final zoomValues = <double>[];

    controller.addListener(() {
      zoomValues.add(controller.view.zoom);
    });

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    // Perform a gradual pinch
    final center = tester.getCenter(find.byType(FractalRenderer));
    final g1 = await tester.createGesture();
    final g2 = await tester.createGesture();

    await g1.down(center + const Offset(-30, 0));
    await g2.down(center + const Offset(30, 0));
    await tester.pump();

    // Move gradually
    for (int i = 1; i <= 5; i++) {
      await g1.moveTo(center + Offset(-30.0 - i * 8, 0));
      await g2.moveTo(center + Offset(30.0 + i * 8, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }

    await g1.up();
    await g2.up();
    await tester.pump();

    // Verify zoom changed progressively (smooth)
    expect(zoomValues.length, greaterThan(1));
    // Each zoom value should be reasonably close to the previous (no huge jumps)
    for (int i = 1; i < zoomValues.length; i++) {
      final ratio = zoomValues[i] / zoomValues[i - 1];
      expect(ratio, inInclusiveRange(0.5, 2.0)); // No crazy jumps
    }
  });

  testWidgets('Boundary rubber-banding clamps pan at positive edge',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    // Huge drag should still clamp pan in controller bounds.
    await tester.drag(
      find.byType(FractalRenderer),
      const Offset(5000, 5000),
    );
    await tester.pumpAndSettle();

    expect(controller.view.pan.x, inInclusiveRange(-3.0, 3.0));
    expect(controller.view.pan.y, inInclusiveRange(-3.0, 3.0));
  });

  testWidgets('Boundary rubber-banding clamps pan at negative edge',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(FractalRenderer),
      const Offset(-5000, -5000),
    );
    await tester.pumpAndSettle();

    expect(controller.view.pan.x, inInclusiveRange(-3.0, 3.0));
    expect(controller.view.pan.y, inInclusiveRange(-3.0, 3.0));
  });

  testWidgets('Mouse wheel zoom preserves targets inside controller bounds',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.byType(FractalRenderer));
    final targetZoom = 5e11;
    final scrollDeltaY = -math.log(targetZoom / controller.view.zoom) / 0.001;

    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: center,
        scrollDelta: Offset(0, scrollDeltaY),
        kind: PointerDeviceKind.mouse,
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.view.zoom, closeTo(targetZoom, targetZoom * 1e-9));
  });

  testWidgets('Mouse wheel zoom clamps to max and min limits', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.byType(FractalRenderer));

    // Scroll up aggressively to zoom in (should clamp).
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: center,
        scrollDelta: const Offset(0, -100000),
        kind: PointerDeviceKind.mouse,
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.view.zoom, lessThanOrEqualTo(1e12));

    // Scroll down aggressively to zoom out (should clamp).
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: center,
        scrollDelta: const Offset(0, 100000),
        kind: PointerDeviceKind.mouse,
      ),
    );
    await tester.pumpAndSettle();
    expect(controller.view.zoom, greaterThanOrEqualTo(1e-9));
  });

  testWidgets('Rapid dual double-tap does not stack duplicate triggers',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    final before = controller.view.zoom;

    // First double-tap.
    await tester.tap(find.byType(FractalRenderer));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.byType(FractalRenderer));
    await tester.pump(const Duration(milliseconds: 40));

    // Immediate second double-tap attempt (should not instantly stack).
    await tester.tap(find.byType(FractalRenderer));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.byType(FractalRenderer));
    await tester.pumpAndSettle();

    final after = controller.view.zoom;
    // Guard against duplicate rapid trigger: allow one step; reject multi-step jump.
    expect(after, greaterThan(before));
    expect(after, lessThanOrEqualTo(before * 3.0));
  });

  testWidgets('Two-finger tilt is clamped to max tilt angle', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.byType(FractalRenderer));
    final g1 = await tester.createGesture();
    final g2 = await tester.createGesture();

    await g1.down(center + const Offset(-40, 0));
    await g2.down(center + const Offset(40, 0));
    await tester.pump();

    // Keep distance/rotation stable and move both fingers vertically
    // to trigger tilt gesture path with a very large delta.
    await g1.moveTo(center + const Offset(-40, 700));
    await g2.moveTo(center + const Offset(40, 700));
    await tester.pumpAndSettle();

    await g1.up();
    await g2.up();
    await tester.pumpAndSettle();

    // 67.5 degrees in radians = 1.1780972450961724
    expect(controller.view.rotation.x, inInclusiveRange(0.0, 1.1782));
  });

  testWidgets('Mouse wheel zoom-out respects minimum clamp', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.byType(FractalRenderer));

    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: center,
        scrollDelta: const Offset(0, 500000),
        kind: PointerDeviceKind.mouse,
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.view.zoom, inInclusiveRange(1e-9, 1e12));
  });

  testWidgets('Rotation lock prevents two-finger rotation updates',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final controller = FractalController(ModuleRegistry());
    controller.setRotationLocked(true);

    await tester.pumpWidget(buildTestWidget(controller));
    await tester.pumpAndSettle();

    final initialZ = controller.view.rotation.z;
    final center = tester.getCenter(find.byType(FractalRenderer));

    final g1 = await tester.createGesture(pointer: 1);
    final g2 = await tester.createGesture(pointer: 2);

    await g1.down(center + const Offset(-40, 0));
    await g2.down(center + const Offset(40, 0));
    await tester.pump();

    // Twist the two pointers around center to simulate rotation.
    await g1.moveTo(center + const Offset(-20, -25));
    await g2.moveTo(center + const Offset(20, 25));
    await tester.pump();

    await g1.up();
    await g2.up();
    await tester.pumpAndSettle();

    expect(controller.view.rotation.z, equals(initialZ));
  });
}
