import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FractalViewerScreen', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late PresetStore presetStore;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
    });

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: presetStore),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FractalViewerScreen(),
        ),
      );
    }

    testWidgets('displays current module name in app bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
    });

    testWidgets('displays app bar with action buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.tune), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('tune button opens controls bottom sheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);
      expect(find.text('Reset View'), findsOneWidget);
      expect(find.text('Reset Params'), findsOneWidget);
    });

    testWidgets('bookmark button opens presets bottom sheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pumpAndSettle();

      expect(find.text('Presets'), findsOneWidget);
      expect(find.text('Save Preset'), findsWidgets);
    });

    testWidgets('download button opens export bottom sheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();

      expect(find.text('Export PNG'), findsOneWidget);
      expect(find.text('Export Transparent PNG'), findsOneWidget);
    });

    testWidgets('displays fractal renderer surface', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Test surface is rendered in test mode
      expect(find.byKey(const Key('fractalTestSurface')), findsOneWidget);
    });

    testWidgets('updates title when module changes', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);

      controller.selectModule(registry.byId('julia'));
      await tester.pumpAndSettle();

      expect(find.text('Julia'), findsOneWidget);
    });

    testWidgets('can close controls sheet by tapping outside', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);

      // Tap outside the sheet to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsNothing);
    });

    testWidgets('can close presets sheet by tapping outside', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pumpAndSettle();

      expect(find.text('Presets'), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Presets'), findsNothing);
    });

    testWidgets('can close export sheet by tapping outside', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();

      expect(find.text('Export PNG'), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Export PNG'), findsNothing);
    });

    testWidgets('displays Julia module correctly', (tester) async {
      controller.selectModule(registry.byId('julia'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Julia'), findsOneWidget);
    });

    testWidgets('displays Burning Ship module correctly', (tester) async {
      controller.selectModule(registry.byId('burning_ship'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Burning Ship'), findsOneWidget);
    });

    testWidgets('displays Phoenix module correctly', (tester) async {
      controller.selectModule(registry.byId('phoenix'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Phoenix'), findsOneWidget);
    });

    testWidgets('displays Mandelbulb module correctly', (tester) async {
      controller.selectModule(registry.byId('mandelbulb'));
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbulb'), findsOneWidget);
    });

    testWidgets('controls sheet shows sliders for numeric params', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      // Mandelbrot has iterations and bailout sliders
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('controls sheet shows choice chips for enum params', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      // Mandelbrot has color scheme with 4 options
      expect(find.byType(ChoiceChip), findsNWidgets(4));
    });

    testWidgets('presets sheet shows built-in presets', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pumpAndSettle();

      expect(find.text('Built-in Presets'), findsOneWidget);
      expect(find.byType(ActionChip), findsWidgets);
    });

    testWidgets('has tooltips for app bar buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final tuneButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.tune));
      final bookmarkButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.bookmark));
      final downloadButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.download));

      expect(tuneButton.tooltip, isNotNull);
      expect(bookmarkButton.tooltip, isNotNull);
      expect(downloadButton.tooltip, isNotNull);
    });
  });
}
