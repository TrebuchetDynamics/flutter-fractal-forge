import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
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
    late RendererSettingsService rendererSettings;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
      rendererSettings =
          RendererSettingsService(await SharedPreferences.getInstance());
    });

    Finder visibleModuleCards() => find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('catalogModuleCard_');
        });

    Finder moduleCard(String moduleId) =>
        find.byKey(Key('catalogModuleCard_core.$moduleId'));

    Future<void> showSearch(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('catalogSearchToggleButton')));
      await tester.pumpAndSettle();
    }

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          Provider.value(value: registry),
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: presetStore),
          ChangeNotifierProvider.value(value: rendererSettings),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: FractalCatalogScreen()),
        ),
      );
    }

    testWidgets('displays catalog modules in default grid view',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify registry has all expected modules by ID.
      final ids = registry.modules.map((m) => m.id).toList();
      expect(
          ids,
          containsAll([
            'mandelbrot',
            'julia',
            'burning_ship',
            'phoenix',
            'mandelbulb'
          ]));

      // Verify the lazy catalog renders module cards, and can scroll to key entries.
      expect(visibleModuleCards(), findsWidgets);
      expect(find.byKey(const Key('catalogViewToggleButton')), findsOneWidget);
      await tester.scrollUntilVisible(
        moduleCard('mandelbrot'),
        320,
        scrollable: find.byType(Scrollable).first,
      );
      expect(moduleCard('mandelbrot'), findsOneWidget);
    });

    testWidgets('displays search field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await showSearch(tester);
      expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
    });

    testWidgets('filters modules by search query', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await showSearch(tester);
      await tester.enterText(
          find.byKey(const Key('catalogSearchField')), 'Burning');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Burning Ship'), findsOneWidget);
      expect(find.text('Mandelbrot'), findsNothing);
    });

    testWidgets('displays dimension labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('2D'), findsWidgets);

      await showSearch(tester);
      await tester.enterText(
          find.byKey(const Key('catalogSearchField')), 'Mandelbulb');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('3D'), findsWidgets);
    });

    testWidgets('tapping module card selects module', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(controller.module.id, 'mandelbrot');

      await showSearch(tester);
      await tester.enterText(
          find.byKey(const Key('catalogSearchField')), 'julia_dual');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(moduleCard('julia_dual'), findsOneWidget);
      await tester.tap(moduleCard('julia_dual'));
      await tester.pumpAndSettle();

      expect(controller.module.id, 'julia_dual');
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

      expect(
          find.byKey(const Key('catalogSearchToggleButton')), findsOneWidget);
    });

    testWidgets('renders list tiles for modules (smoke)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // At least one lazily-built module card should render in the viewport.
      expect(visibleModuleCards(), findsWidgets);
    });

    testWidgets('search miss shows empty state and clear restores results',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await showSearch(tester);
      await tester.enterText(
          find.byKey(const Key('catalogSearchField')), 'zzzz-no-match');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.byKey(const Key('catalogClearSearchButton')), findsOneWidget);

      await tester.tap(find.byKey(const Key('catalogClearSearchButton')));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Catalog results reappear after clearing search.
      expect(visibleModuleCards(), findsWidgets);
    });

    testWidgets('respects saved list-view preference at startup',
        (tester) async {
      SharedPreferences.setMockInitialValues({'catalog_view_grid': false});

      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
      rendererSettings =
          RendererSettingsService(await SharedPreferences.getInstance());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // In list mode, toggle button should show "switch to grid" icon.
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      // And the opposite icon should not be the active toggle icon.
      expect(find.byIcon(Icons.view_list_rounded), findsNothing);
    });

    testWidgets('view toggle switches to list mode and persists preference',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Starts in grid mode, so icon indicates switch-to-list.
      expect(find.byIcon(Icons.view_list_rounded), findsOneWidget);

      await tester.tap(find.byKey(const Key('catalogViewToggleButton')));
      await tester.pumpAndSettle();

      // After toggle, icon indicates switch back to grid.
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      expect(find.byIcon(Icons.view_list_rounded), findsNothing);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('catalog_view_grid'), isFalse);
    });
  });
}
