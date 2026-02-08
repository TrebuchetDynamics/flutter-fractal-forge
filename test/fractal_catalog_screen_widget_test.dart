import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FractalCatalogScreen', () {
    late ModuleRegistry registry;
    late FractalController controller;
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();
    });

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: presetStore),
          Provider.value(value: arQualityStore),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: FractalCatalogScreen()),
        ),
      );
    }

    testWidgets('displays all fractal modules in list', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
      expect(find.text('Julia'), findsOneWidget);
      expect(find.text('Burning Ship'), findsOneWidget);
      expect(find.text('Phoenix'), findsOneWidget);
      expect(find.text('Mandelbulb'), findsOneWidget);
    });

    testWidgets('displays search field with hint', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
      expect(find.text('Search fractals…'), findsOneWidget);
    });

    testWidgets('filters modules by search query', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('catalogSearchField')), 'Burning');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Burning Ship'), findsOneWidget);
      expect(find.text('Mandelbrot'), findsNothing);
      expect(find.text('Julia'), findsNothing);
    });

    testWidgets('shows clear button when search has text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      await tester.enterText(find.byKey(const Key('catalogSearchField')), 'test');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears search when clear button is tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('catalogSearchField')), 'Julia');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsNothing);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
      expect(find.text('Julia'), findsOneWidget);
    });

    testWidgets('shows empty state for no matching search results', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('catalogSearchField')), 'xyz123');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('No fractals match your search.'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('shows clear search button in empty state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('catalogSearchField')), 'nonexistent');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogClearSearchButton')), findsOneWidget);
    });

    testWidgets('clear search button in empty state resets list', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('catalogSearchField')), 'nonexistent');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('catalogClearSearchButton')));
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
    });

    testWidgets('displays dimension label for each module', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 2D fractals
      expect(find.text('2D'), findsNWidgets(4)); // Mandelbrot, Julia, Burning Ship, Phoenix
      // 3D fractal
      expect(find.text('3D'), findsOneWidget); // Mandelbulb
    });

    testWidgets('module cards have chevron icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsNWidgets(5));
    });

    testWidgets('tapping module card selects module', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(controller.module.id, 'mandelbrot');

      await tester.tap(find.text('Julia'));
      await tester.pumpAndSettle();

      expect(controller.module.id, 'julia');
    });

    testWidgets('search is case-insensitive', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('catalogSearchField')), 'JULIA');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'Julia'), findsOneWidget);
    });

    testWidgets('search finds partial matches', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('catalogSearchField')), 'Mand');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsOneWidget);
      expect(find.text('Mandelbulb'), findsOneWidget);
      expect(find.text('Julia'), findsNothing);
    });

    testWidgets('debounces search input', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('catalogSearchField')), 'J');
      // Before debounce completes, all modules should still be visible
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Mandelbrot'), findsOneWidget);

      // After debounce
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      
      // Now J matches Julia
      expect(find.widgetWithText(ListTile, 'Julia'), findsOneWidget);
    });
  });
}
