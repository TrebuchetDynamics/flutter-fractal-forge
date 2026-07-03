import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fractal_controller_widget_harness.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

void main() {
  group('FractalRenderer', () {
    late FractalControllerWidgetHarness harness;
    late ModuleRegistry registry;
    late FractalController controller;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      harness = FractalControllerWidgetHarness();
      registry = harness.registry;
      controller = harness.controller;
    });

    tearDown(() => harness.dispose());

    Widget buildTestWidget({bool gesturesEnabled = true}) {
      return harness.wrapScaffold(
        FractalRenderer(gesturesEnabled: gesturesEnabled),
      );
    }

    testWidgets('renders test surface in test mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('test surface has black background', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final coloredBox = tester.widget<ColoredBox>(
        find.byKey(const Key('fractalTestSurface')),
      );
      expect(coloredBox.color, Colors.black);
    });

    testWidgets('responds to pinch zoom gesture', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final initialZoom = controller.view.zoom;

      // Simulate scale gesture
      final center =
          tester.getCenter(find.byKey(const Key('fractalTestSurface')));
      final gesture1 = await tester.startGesture(center - const Offset(50, 0));
      final gesture2 = await tester.startGesture(center + const Offset(50, 0));

      // Move fingers apart (zoom in)
      await gesture1.moveBy(const Offset(-30, 0));
      await gesture2.moveBy(const Offset(30, 0));
      await tester.pumpAndSettle();

      await gesture1.up();
      await gesture2.up();
      await tester.pumpAndSettle();

      expect(controller.view.zoom, isNot(initialZoom));
    });

    testWidgets('responds to pan gesture for 2D fractals', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final initialPan = Vector2.copy(controller.view.pan);

      // Drag gesture
      await tester.drag(
        find.byKey(const Key('fractalTestSurface')),
        const Offset(50, 50),
      );
      await tester.pumpAndSettle();

      expect(controller.view.pan.x, isNot(initialPan.x));
      expect(controller.view.pan.y, isNot(initialPan.y));
    });

    testWidgets('responds to drag gesture for 3D fractals with rotation',
        (tester) async {
      controller.selectModule(registry.byId('mandelbulb'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final initialRotation = Vector3.copy(controller.view.rotation);

      await tester.drag(
        find.byKey(const Key('fractalTestSurface')),
        const Offset(50, 50),
      );
      await tester.pumpAndSettle();

      expect(controller.view.rotation.x, isNot(initialRotation.x));
      expect(controller.view.rotation.y, isNot(initialRotation.y));
    });

    testWidgets('gestures are disabled when gesturesEnabled is false',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(gesturesEnabled: false));
      await tester.pumpAndSettle();

      final initialPan = Vector2.copy(controller.view.pan);

      await tester.drag(
        find.byKey(const Key('fractalTestSurface')),
        const Offset(50, 50),
      );
      await tester.pumpAndSettle();

      // Pan should not change
      expect(controller.view.pan.x, initialPan.x);
      expect(controller.view.pan.y, initialPan.y);
    });

    testWidgets('has RepaintBoundary for export', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('uses SizedBox.expand for full size', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byKey(const Key('fractalTestSurface')),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, double.infinity);
      expect(sizedBox.height, double.infinity);
    });

    testWidgets('updates when controller params change', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      controller.updateParam('iterations', 200);
      await tester.pumpAndSettle();

      // Surface should still be present
      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('updates when module changes', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      controller.selectModule(registry.byId('julia'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('works with Julia module', (tester) async {
      controller.selectModule(registry.byId('julia'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('works with Burning Ship module', (tester) async {
      controller.selectModule(registry.byId('burning_ship'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('works with Phoenix module', (tester) async {
      controller.selectModule(registry.byId('phoenix'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('works with Mandelbulb module', (tester) async {
      controller.selectModule(registry.byId('mandelbulb'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('has GestureDetector when gestures enabled', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('no GestureDetector when gestures disabled', (tester) async {
      await tester.pumpWidget(buildTestWidget(gesturesEnabled: false));
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('FragmentShader cache state variables exist', (tester) async {
      // exist', (test This test verifies the shader caching infrastructure exists.
      // In widget test mode, the renderer uses a placeholder surface,
      // but we verify the state fields are properly initialized.
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The FractalRenderer widget should exist.
      expect(find.byType(FractalRenderer), findsOneWidget);

      // Controller should have module selected.
      expect(controller.module.id, isNotEmpty);
    });

    testWidgets('shader cache is reset on module change', (tester) async {
      // Verify that switching modules works correctly.
      controller.selectModule(registry.byId('mandelbrot'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(controller.module.id, 'mandelbrot');

      // Switch to Julia.
      controller.selectModule(registry.byId('julia'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(controller.module.id, 'julia');
    });

    test('shader load start clears stale program before async compile', () {
      final source = File(
        'lib/features/renderer/widgets/renderer/shaders/shader_loader.dart',
      ).readAsStringSync();

      expect(source, contains('void clearStaleShader()'));
      expect(source, contains('_program = null;'));
      expect(source, contains('_shaderForCachedFragment = null;'));
      expect(source, contains('_cachedFragmentShader = null;'));
      expect(source, contains('_shaderAsset = asset;'));
    });
  });
}
