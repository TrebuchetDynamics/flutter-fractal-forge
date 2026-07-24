import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';

import '../helpers/fractal_controller_widget_harness.dart';

void main() {
  group('FractalControlsHud', () {
    late FractalControllerWidgetHarness harness;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      harness = FractalControllerWidgetHarness();
    });

    tearDown(() => harness.dispose());

    Widget buildTestWidget() =>
        harness.wrapScaffold(const FractalControlsHud());

    testWidgets('renders core param sliders', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Should show iterations slider
      expect(find.text('Iterations'), findsOneWidget);
      // Should show bailout slider
      expect(find.text('Bailout'), findsOneWidget);
      // Should show palette label
      expect(find.text('Palette'), findsOneWidget);
      // Should show close button
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('action buttons are present', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Should show action buttons
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Params'), findsOneWidget);
      expect(find.text('Randomize'), findsOneWidget);
    });

    testWidgets('fluid mode exposes intensity control when enabled',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Fluid mode'), findsOneWidget);
      expect(find.text('Fluid intensity'), findsNothing);

      await tester.tap(find.text('Fluid mode'));
      await tester.pumpAndSettle();

      expect(find.text('Fluid intensity'), findsOneWidget);
      expect(harness.controller.fluidModeEnabled, isTrue);
    });

    testWidgets('kaleidoscope section toggles', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Kaleidoscope section should show toggle
      expect(find.text('Kaleidoscope'), findsOneWidget);

      // Toggle on - sectors and rotation sliders should appear
      await tester.tap(find.text('Kaleidoscope'));
      await tester.pumpAndSettle();
      expect(find.text('Sectors'), findsOneWidget);
      expect(find.text('Rotation'), findsOneWidget);
    });

    testWidgets('randomize does not trigger celebration particles',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Randomize'));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 700));

      expect(harness.controller.isCelebrating, isFalse);
    });

    testWidgets('sliders update controller params', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find the iterations slider
      final slider = find.byType(Slider).first;
      expect(slider, findsOneWidget);

      // Get initial value
      final initialValue = harness.controller.params['iterations'] as int;
      expect(initialValue, greaterThan(0));

      // Drag slider right to increase
      await tester.timedDrag(
        slider,
        const Offset(100, 0), // drag right
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      // Value should have changed
      final newValue = harness.controller.params['iterations'] as int;
      expect(newValue, isNot(equals(initialValue)));
    });

    testWidgets('close button triggers onClose callback', (tester) async {
      bool closed = false;

      await tester.pumpWidget(
        harness.wrapScaffold(FractalControlsHud(onClose: () => closed = true)),
      );
      await tester.pumpAndSettle();

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closed, isTrue);
    });
  });
}
