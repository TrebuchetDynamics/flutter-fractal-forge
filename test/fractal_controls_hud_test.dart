import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/chrome/fractal_controls_hud.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

void main() {
  group('FractalControlsHud', () {
    late ModuleRegistry registry;
    late FractalController controller;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      registry = ModuleRegistry();
      controller = FractalController(registry);
    });

    Widget buildTestWidget() {
      return ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: FractalControlsHud()),
        ),
      );
    }

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

    testWidgets('sliders update controller params', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Find the iterations slider
      final slider = find.byType(Slider).first;
      expect(slider, findsOneWidget);

      // Get initial value
      final initialValue = controller.params['iterations'] as int;
      expect(initialValue, greaterThan(0));

      // Drag slider right to increase
      final sliderCenter = tester.getCenter(slider);
      await tester.timedDrag(
        slider,
        const Offset(100, 0), // drag right
        const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      // Value should have changed
      final newValue = controller.params['iterations'] as int;
      expect(newValue, isNot(equals(initialValue)));
    });

    testWidgets('close button triggers onClose callback', (tester) async {
      bool closed = false;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: FractalControlsHud(onClose: () => closed = true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closed, isTrue);
    });
  });
}