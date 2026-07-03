import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
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

      // Verify the lazy catalog renders module cards without forcing a scroll
      // through thousands of generated entries to a specific module.
      expect(visibleModuleCards(), findsWidgets);
      expect(find.byKey(const Key('catalogViewToggleButton')), findsOneWidget);
      expect(find.byKey(const Key('catalogPinnedFilterBar')), findsOneWidget);
    });

    testWidgets('defaults to all categories', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp(r'All categories filter, selected')),
        findsOneWidget,
      );
    });

    testWidgets('category section headers collapse their cards',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogSectionGrid_escape_time_0')),
          findsOneWidget);

      await tester
          .tap(find.byKey(const Key('catalogSectionHeader_escape_time')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogSectionGrid_escape_time_0')),
          findsNothing);
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
      expect(find.byKey(const Key('catalogActiveSearchChip')), findsNothing);
    });

    testWidgets('omits duplicate active category summary row', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('catalogCategoryChip_all')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogActiveCategoryChip')), findsNothing);
      expect(find.byKey(const Key('catalogClearFiltersButton')), findsNothing);
    });

    testWidgets('horizontal swipe changes category selection', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('catalogCategoryChip_all')));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp(r'All categories filter, selected')),
        findsOneWidget,
      );

      await tester.fling(
        find.byKey(const Key('catalogCategorySwipeArea')),
        const Offset(-500, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp(r'All categories filter, selected')),
        findsNothing,
      );

      await tester.fling(
        find.byKey(const Key('catalogCategorySwipeArea')),
        const Offset(500, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp(r'All categories filter, selected')),
        findsOneWidget,
      );
    });

    testWidgets('category rail omits cramped step buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('catalogPreviousCategoryButton')), findsNothing);
      expect(find.byKey(const Key('catalogNextCategoryButton')), findsNothing);
      expect(find.byKey(const Key('catalogCategoryChip_all')), findsOneWidget);
    });

    testWidgets('omits dimension filter chips', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogDimensionChip_all')), findsNothing);
      expect(find.byKey(const Key('catalogDimensionChip_2d')), findsNothing);
      expect(find.byKey(const Key('catalogDimensionChip_3d')), findsNothing);
      expect(find.byKey(const Key('catalogDimensionChip_kaleidoscope')),
          findsNothing);
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

    testWidgets('has scroll view for scrolling', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('has search icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('catalogSearchToggleButton')), findsOneWidget);
    });

    testWidgets('grid cards keep a portrait layout on phone width',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final box = tester.renderObject<RenderBox>(visibleModuleCards().first);
      expect(box.size.height, greaterThan(box.size.width));
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

      // In list mode, toggle button should show "switch to miniatures" icon.
      expect(find.byIcon(Icons.view_module_rounded), findsOneWidget);
      // And the grid-to-list icon should not be the active toggle icon.
      expect(find.byIcon(Icons.view_list_rounded), findsNothing);
      expect(find.textContaining(RegExp(r'\d+ params:')), findsWidgets);
    });

    testWidgets('view toggle switches to list mode and persists preference',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Starts in grid mode, so icon indicates switch-to-list.
      expect(find.byIcon(Icons.view_list_rounded), findsOneWidget);

      await tester.tap(find.byKey(const Key('catalogViewToggleButton')));
      await tester.pumpAndSettle();

      // After toggle, icon indicates switch to miniatures.
      expect(find.byIcon(Icons.view_module_rounded), findsOneWidget);
      expect(find.byIcon(Icons.view_list_rounded), findsNothing);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('catalog_view_grid'), isFalse);
    });

    testWidgets('miniatures view shows four thumbnails per row on phones',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('catalogViewToggleButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('catalogViewToggleButton')));
      await tester.pumpAndSettle();

      final cards = visibleModuleCards();
      expect(cards, findsAtLeastNWidgets(5));
      final firstRowY = tester.getTopLeft(cards.at(0)).dy;
      for (var i = 1; i < 4; i++) {
        expect(tester.getTopLeft(cards.at(i)).dy, firstRowY);
      }
      expect(tester.getTopLeft(cards.at(4)).dy, greaterThan(firstRowY));

      final prefs = await SharedPreferences.getInstance();
      expect(
          prefs.getInt('catalog_view_mode'), CatalogViewMode.miniatures.index);
    });
  });
}
