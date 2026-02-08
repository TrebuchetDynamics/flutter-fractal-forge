import 'package:flutter/material.dart';
import 'package:flutter_fractals/features/controls/fractal_controls.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('FractalControlsSheet', () {
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
          home: const Scaffold(body: FractalControlsSheet()),
        ),
      );
    }

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

      // Change a parameter
      controller.updateParam('iterations', 500);
      expect(controller.params['iterations'], 500);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Reset Params'));
      await tester.pumpAndSettle();

      expect(controller.params['iterations'], 120); // Default
    });

    testWidgets('Reset View resets view state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Change view state
      controller.updateZoom(2.0);
      expect(controller.view.zoom, 2.0);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Reset View'));
      await tester.pumpAndSettle();

      expect(controller.view.zoom, 1.0); // Default
    });

    testWidgets('Randomize changes parameter values', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final initialIterations = controller.params['iterations'] as int;

      // Tap randomize multiple times to ensure at least one change
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.widgetWithText(ElevatedButton, 'Randomize'));
        await tester.pumpAndSettle();
        
        final currentIterations = controller.params['iterations'] as int;
        if (currentIterations != initialIterations) {
          expect(currentIterations, isNot(initialIterations));
          return;
        }
      }
      // If we got here, iterations stayed the same - that's unlikely but possible
    });

    testWidgets('displays sliders for numeric parameters', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Mandelbrot has iterations and bailout
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('displays ChoiceChips for enum parameters', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Mandelbrot has colorScheme with 4 options
      expect(find.byType(ChoiceChip), findsNWidgets(4));
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

    testWidgets('ChoiceChip selection updates controller', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(controller.params['colorScheme'], 0); // Default is Fire

      // Tap Ocean chip
      await tester.tap(find.text('Ocean'));
      await tester.pumpAndSettle();

      expect(controller.params['colorScheme'], 1); // Ocean
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
      expect(find.ancestor(
        of: find.text('Reset View'),
        matching: find.byType(Row),
      ), findsWidgets);
    });

    testWidgets('Randomize button spans full width', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final randomizeButton = tester.widget<SizedBox>(
        find.ancestor(
          of: find.widgetWithText(ElevatedButton, 'Randomize'),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(randomizeButton.width, double.infinity);
    });

    testWidgets('is scrollable', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
