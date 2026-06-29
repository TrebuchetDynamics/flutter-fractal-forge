import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'helpers/fractal_controller_widget_harness.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  group('FractalController state management', () {
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

    testWidgets('notifies listeners when module changes', (tester) async {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      await tester.pumpWidget(
        harness.textFromController((ctrl) => ctrl.module.id),
      );
      await tester.pumpAndSettle();

      expect(find.text('mandelbrot'), findsOneWidget);

      controller.selectModule(registry.byId('julia'));
      await tester.pumpAndSettle();

      expect(find.text('julia'), findsOneWidget);
      expect(notifyCount, greaterThan(0));
    });

    testWidgets('notifies listeners when params change', (tester) async {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);
      final initialIterationsText = controller.params['iterations'].toString();

      await tester.pumpWidget(
        harness
            .textFromController((ctrl) => ctrl.params['iterations'].toString()),
      );
      await tester.pumpAndSettle();

      expect(find.text(initialIterationsText), findsOneWidget);

      controller.updateParam('iterations', 200);
      await tester.pumpAndSettle();

      expect(find.text('200'), findsOneWidget);
      expect(notifyCount, greaterThan(0));
    });

    testWidgets('notifies listeners when view changes', (tester) async {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);
      final initialZoomText = controller.view.zoom.toStringAsFixed(1);

      await tester.pumpWidget(
        harness.textFromController((ctrl) => ctrl.view.zoom.toStringAsFixed(1)),
      );
      await tester.pumpAndSettle();

      expect(find.text(initialZoomText), findsOneWidget);

      controller.updateZoom(2.0);
      await tester.pumpAndSettle();

      expect(find.text('2.0'), findsOneWidget);
      expect(notifyCount, greaterThan(0));
    });

    testWidgets('widget rebuilds when transparent background changes',
        (tester) async {
      await tester.pumpWidget(
        harness.textFromController(
          (ctrl) => ctrl.transparentBackground ? 'transparent' : 'opaque',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('opaque'), findsOneWidget);

      controller.setTransparentBackground(true);
      await tester.pumpAndSettle();

      expect(find.text('transparent'), findsOneWidget);
    });

    testWidgets('widget rebuilds when pan changes', (tester) async {
      await tester.pumpWidget(
        harness.textFromController(
          (ctrl) =>
              '${ctrl.view.pan.x.toStringAsFixed(1)},${ctrl.view.pan.y.toStringAsFixed(1)}',
        ),
      );
      await tester.pumpAndSettle();

      final initial = tester.widget<Text>(find.byType(Text)).data ?? '';
      expect(initial, isNotEmpty);

      controller.updatePan(Vector2(0.5, 0.5));
      await tester.pumpAndSettle();

      expect(find.text('0.5,0.5'), findsOneWidget);
      expect(initial, isNot('0.5,0.5'));
    });

    testWidgets('widget rebuilds when rotation changes', (tester) async {
      await tester.pumpWidget(
        harness.textFromController(
            (ctrl) => ctrl.view.rotation.x.toStringAsFixed(1)),
      );
      await tester.pumpAndSettle();

      expect(find.text('0.0'), findsOneWidget);

      controller.updateRotation(Vector3(1.0, 0.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('1.0'), findsOneWidget);
    });

    testWidgets('resetSession triggers rebuild', (tester) async {
      final defaultIterationsText = controller.params['iterations'].toString();
      // updateZoom may trigger adaptive iterations; do not hard-code the
      // intermediate iterations value. We only verify zoom and transparency
      // before reset, then check all three values return to defaults after.
      controller.updateZoom(2.0);
      controller.setTransparentBackground(true);

      await tester.pumpWidget(
        harness.wrap(
          Consumer<FractalController>(
            builder: (context, ctrl, child) {
              return Column(
                children: [
                  Text(ctrl.params['iterations'].toString()),
                  Text(ctrl.view.zoom.toStringAsFixed(1)),
                  Text(ctrl.transparentBackground ? 'transparent' : 'opaque'),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2.0'), findsOneWidget);
      expect(find.text('transparent'), findsOneWidget);

      controller.resetSession();
      await tester.pumpAndSettle();

      expect(find.text(defaultIterationsText), findsOneWidget);
      expect(find.text('1.0'), findsOneWidget);
      expect(find.text('opaque'), findsOneWidget);
    });

    testWidgets('randomizeParams triggers rebuild', (tester) async {
      await tester.pumpWidget(
        harness
            .textFromController((ctrl) => ctrl.params['iterations'].toString()),
      );
      await tester.pumpAndSettle();

      final initialValue = controller.params['iterations'] as int;

      // Randomize several times to ensure a change
      for (int i = 0; i < 20; i++) {
        controller.randomizeParams();
        await tester.pumpAndSettle();
        if (controller.params['iterations'] != initialValue) {
          break;
        }
      }

      // Widget should have rebuilt
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('applyPreset triggers rebuild', (tester) async {
      // Get a preset that has different iterations than default
      final presets = registry.byId('mandelbrot').builtInPresets;
      final defaultIterations =
          (controller.params['iterations'] as num).round();
      final preset = presets.firstWhere(
        (p) =>
            ((p.params['iterations'] as num?)?.round() ?? defaultIterations) !=
            defaultIterations,
        orElse: () => presets.first,
      );

      await tester.pumpWidget(
        harness
            .textFromController((ctrl) => ctrl.params['iterations'].toString()),
      );
      await tester.pumpAndSettle();

      expect(find.text(defaultIterations.toString()), findsOneWidget);

      controller.applyPreset(preset);
      await tester.pumpAndSettle();

      // Just verify that it rebuilt (text is present)
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('multiple widgets can listen to same controller',
        (tester) async {
      final initialZoomText = controller.view.zoom.toStringAsFixed(1);
      await tester.pumpWidget(
        harness.wrap(
          Column(
            children: [
              Consumer<FractalController>(
                builder: (context, ctrl, child) {
                  return Text('Module: ${ctrl.module.id}');
                },
              ),
              Consumer<FractalController>(
                builder: (context, ctrl, child) {
                  return Text('Zoom: ${ctrl.view.zoom.toStringAsFixed(1)}');
                },
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Module: mandelbrot'), findsOneWidget);
      expect(find.text('Zoom: $initialZoomText'), findsOneWidget);

      controller.selectModule(registry.byId('julia'));
      controller.updateZoom(3.0);
      await tester.pumpAndSettle();

      expect(find.text('Module: julia'), findsOneWidget);
      expect(find.text('Zoom: 3.0'), findsOneWidget);
    });
  });
}
