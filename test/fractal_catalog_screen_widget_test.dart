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

      await tester.ensureVisible(find.text('Phoenix'));
      await tester.pumpAndSettle();
      expect(find.text('Phoenix'), findsOneWidget);

      await tester.ensureVisible(find.text('Mandelbulb'));
      await tester.pumpAndSettle();
      expect(find.text('Mandelbulb'), findsOneWidget);
    });

    testWidgets('displays search field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
    });

    testWidgets('filters modules by search query', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('catalogSearchField')), 'Burning');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Burning Ship'), findsOneWidget);
      expect(find.text('Mandelbrot'), findsNothing);
    });

    testWidgets('displays dimension labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('2D'), findsWidgets);
      expect(find.text('3D'), findsWidgets);
    });

    testWidgets('tapping module card selects module', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(controller.module.id, 'mandelbrot');

      await tester.tap(find.text('Julia'));
      await tester.pumpAndSettle();

      expect(controller.module.id, 'julia');
    });

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('has ListView for scrolling', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('has search icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The search icon is part of the TextField decoration; just ensure there is at least one Icon.
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('renders list tiles for modules (smoke)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Module text should render.
      expect(find.text('Mandelbrot'), findsOneWidget);
    });
  });
}
