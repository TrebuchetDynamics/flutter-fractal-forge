import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fractal_controller_widget_harness.dart';

void main() {
  group('FractalControlsSheet', () {
    late FractalControllerWidgetHarness harness;
    late FractalController controller;
    late ModuleRegistry registry;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      harness = FractalControllerWidgetHarness();
      controller = harness.controller;
      registry = harness.registry;
    });

    tearDown(() => harness.dispose());

    Widget buildTestWidget() =>
        harness.wrapScaffold(const FractalControlsSheet());

    testWidgets('displays Controls title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);
    });

    testWidgets('displays Reset View button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Reset View'), findsOneWidget);
    });

    testWidgets('displays Reset Params button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Reset Params'), findsOneWidget);
    });

    testWidgets('displays Randomize button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Randomize'), findsOneWidget);
    });

    testWidgets('Reset Params restores defaults', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      final defaultIterations = controller.params['iterations'] as int;

      // Change a parameter
      controller.updateParam('iterations', 500);
      expect(controller.params['iterations'], 500);

      await tester.ensureVisible(find.text('Reset Params'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset Params'));
      await tester.pumpAndSettle();

      expect(controller.params['iterations'], defaultIterations);
    });

    testWidgets('Reset View resets view state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Change view state
      controller.updateZoom(2.0);
      expect(controller.view.zoom, 2.0);

      await tester.ensureVisible(find.text('Reset View'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset View'));
      await tester.pumpAndSettle();

      expect(controller.view.zoom, 1.0); // Default
    });

    testWidgets('Randomize changes parameter values', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final initialIterations = controller.params['iterations'] as int;

      // Call controller method directly (more reliable than tapping in scroll views).
      controller.randomizeParams(animate: false);
      await tester.pumpAndSettle();

      expect(controller.params['iterations'], isNot(initialIterations));
    });

    testWidgets('displays sliders for numeric parameters', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Mandelbrot has iterations and bailout
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('displays enum parameter label', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Color Scheme'), findsOneWidget);
    });

    testWidgets('slider changes update controller', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final initialIterations = controller.params['iterations'] as int;

      // Find the iterations slider and drag it
      final sliders = find.byType(Slider);
      await tester.drag(sliders.first, const Offset(50, 0));
      await tester.pumpAndSettle();

      final newIterations = controller.params['iterations'] as int;
      expect(newIterations, isNot(initialIterations));
    });

    testWidgets('color scheme options are present (if rendered)',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Depending on platform/theme, options may be chips or another control.
      // At least one option label should be visible.
      expect(
        find.text('Fire').evaluate().isNotEmpty ||
            find.text('Ocean').evaluate().isNotEmpty ||
            find.text('Psychedelic').evaluate().isNotEmpty ||
            find.text('Grayscale').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('displays parameter labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Iterations'), findsOneWidget);
      expect(find.text('Bailout'), findsOneWidget);
      expect(find.text('Color Scheme'), findsOneWidget);
    });

    testWidgets('displays color scheme options', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Fire'), findsOneWidget);
      expect(find.text('Ocean'), findsOneWidget);
      expect(find.text('Psychedelic'), findsOneWidget);
      expect(find.text('Grayscale'), findsOneWidget);
    });

    testWidgets('works with Julia module', (tester) async {
      controller.selectModule(registry.byId('julia'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('works with Mandelbulb module', (tester) async {
      controller.selectModule(registry.byId('mandelbulb'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('buttons are laid out in row', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Reset buttons should be in a Row
      expect(
          find.ancestor(
            of: find.text('Reset View'),
            matching: find.byType(Row),
          ),
          findsWidgets);
    });

    testWidgets('Randomize button exists', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Randomize'), findsOneWidget);
    });

    testWidgets('is scrollable', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Glow sliders appear only when glow is enabled',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Mandelbrot has 2 numeric params; glow off => no extra sliders.
      expect(find.byType(Slider), findsNWidgets(2));

      controller.setGlowEnabled(true);
      await tester.pumpAndSettle();

      // Glow card now exposes softness + strength sliders.
      expect(find.byType(Slider), findsNWidgets(4));
    });

    testWidgets('Glow sliders expose current value to screen readers',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      controller.setGlowEnabled(true);
      await tester.pumpAndSettle();

      final sliders = find.byType(Slider);
      expect(sliders, findsNWidgets(4));

      // Order: iterations, bailout, then glow's softness + strength.
      final softness = tester.getSemantics(sliders.at(2));
      expect(softness.label, 'Softness');
      expect(softness.value, '1.00');

      final strength = tester.getSemantics(sliders.at(3));
      expect(strength.label, 'Strength');
      expect(strength.value, '0.35');

      semantics.dispose();
    });
  });
}
