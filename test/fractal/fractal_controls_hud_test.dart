import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

      final initialStrength = harness.controller.fluidStrength;
      await tester.timedDrag(
        find.byType(Slider).last,
        const Offset(80, 0),
        const Duration(milliseconds: 150),
      );
      await tester.pumpAndSettle();
      expect(harness.controller.fluidStrength, isNot(initialStrength));

      await tester.tap(find.text('Fluid mode'));
      await tester.pumpAndSettle();
      expect(find.text('Fluid intensity'), findsNothing);
      expect(harness.controller.fluidModeEnabled, isFalse);
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

    for (final scale in const [1.0, 1.3, 2.0]) {
      testWidgets('HUD survives a ${scale}x text scale on a narrow screen',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 568));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: buildTestWidget(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'collapsed at $scale x');

        await tester.tap(find.text('Kaleidoscope'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'expanded at $scale x');
      });
    }

    testWidgets('the HUD close button keeps a 48px touch target',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The only way to dismiss the HUD; the visible circle stays smaller.
      final target = find.ancestor(
        of: find.byIcon(Icons.close_rounded),
        matching: find.byType(InkWell),
      );
      expect(target, findsOneWidget);
      final size = tester.getSize(target);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('every adjustable HUD control announces what it adjusts',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kaleidoscope'));
      await tester.pumpAndSettle();

      final bare = <String>[];
      void walk(SemanticsNode node) {
        if (!node.isMergedIntoParent) {
          final data = node.getSemanticsData();
          // Sliders carry increase/decrease; a scroll container legitimately
          // has no name, so only adjustable controls are checked here.
          final adjustable = data.flagsCollection.isSlider;
          if (adjustable && data.label.isEmpty) {
            bare.add('value="${data.value}"');
          }
        }
        node.visitChildren((child) {
          walk(child);
          return true;
        });
      }

      // ignore: deprecated_member_use
      walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);

      expect(
        bare,
        isEmpty,
        reason: 'slider thumbs surfaced without the parameter name',
      );
      for (final label in const [
        'Iterations',
        'Kaleidoscope sectors',
        'Kaleidoscope rotation',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
      }

      handle.dispose();
    });

    testWidgets('every sectors detent lands on a distinct sector count',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kaleidoscope'));
      await tester.pumpAndSettle();

      final sectorsSlider = find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Kaleidoscope sectors',
        ),
        matching: find.byType(Slider),
      );
      expect(sectorsSlider, findsOneWidget);

      final slider = tester.widget<Slider>(sectorsSlider);
      final divisions = slider.divisions!;
      final step = (slider.max - slider.min) / divisions;

      // setKaleidoscopeSectors snaps odd values down, so two adjacent detents
      // that differ by 1 collapse onto the same count and one of them is a
      // dead stop the user can drag to but never land on.
      final reachable = <int>{};
      for (var i = 0; i <= divisions; i++) {
        harness.controller
            .setKaleidoscopeSectors((slider.min + i * step).round());
        reachable.add(harness.controller.kaleidoscopeSectors);
      }

      expect(
        reachable.length,
        divisions + 1,
        reason: 'only ${reachable.length} of ${divisions + 1} detents are live',
      );
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
