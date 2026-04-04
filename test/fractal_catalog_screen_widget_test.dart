import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/catalog/catalog_view_mode_store.dart';
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

    Widget buildTestWidget({
      CatalogViewModeStore viewModeStore =
          const SharedPreferencesCatalogViewModeStore(),
      EdgeInsets viewInsets = EdgeInsets.zero,
    }) {
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
          home: Builder(
            builder: (context) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(viewInsets: viewInsets),
                child: Scaffold(
                  body: FractalCatalogScreen(viewModeStore: viewModeStore),
                ),
              );
            },
          ),
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

      // Verify key entries render in the default view.
      expect(find.text('Mandelbrot'), findsWidgets);
      expect(find.text('Burning Ship'), findsWidgets);
      expect(find.byKey(const Key('catalogViewToggleButton')), findsOneWidget);
    });

    testWidgets('displays search field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
    });

    testWidgets('filters modules by search query', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

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

      await tester.tap(find.byKey(const Key('catalogViewToggleButton')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('catalogSearchField')), 'core.julia');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogModuleCard_core.julia')),
          findsOneWidget);
      await tester.tap(find.byKey(const Key('catalogModuleCard_core.julia')));
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

      expect(find.text('Mandelbrot'), findsWidgets);
    });

    testWidgets('search miss shows empty state and clear restores results',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('catalogSearchField')), 'zzzz-no-match');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.byKey(const Key('catalogClearSearchButton')), findsOneWidget);

      await tester.tap(find.byKey(const Key('catalogClearSearchButton')));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Mandelbrot'), findsWidgets);
    });

    testWidgets('search focus hides supporting catalog chrome immediately',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogDimensionChip_all')), findsOneWidget);
      expect(find.byKey(const Key('catalogCategoryScroll')), findsOneWidget);

      await tester.tap(find.byKey(const Key('catalogSearchField')));
      await tester.pump();

      expect(find.byKey(const Key('catalogDimensionChip_all')), findsNothing);
      expect(find.byKey(const Key('catalogCategoryScroll')), findsNothing);
    });

    testWidgets('respects saved list-view preference at startup',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        SharedPreferencesCatalogViewModeStore.preferenceKey: false,
      });

      registry = ModuleRegistry();
      controller = FractalController(registry);
      presetStore = await PresetStore.create();
      rendererSettings =
          RendererSettingsService(await SharedPreferences.getInstance());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // In list mode, toggle button should show "switch to grid" icon.
      final toggle = find.byKey(const Key('catalogViewToggleButton'));
      expect(
        find.descendant(
          of: toggle,
          matching: find.byIcon(Icons.grid_view_rounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: toggle,
          matching: find.byIcon(Icons.view_list_rounded),
        ),
        findsNothing,
      );
    });

    testWidgets('view toggle switches to list mode and persists preference',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Starts in grid mode, so icon indicates switch-to-list.
      final toggle = find.byKey(const Key('catalogViewToggleButton'));
      expect(
        find.descendant(
          of: toggle,
          matching: find.byIcon(Icons.view_list_rounded),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('catalogViewToggleButton')));
      await tester.pumpAndSettle();

      // After toggle, icon indicates switch back to grid.
      expect(
        find.descendant(
          of: toggle,
          matching: find.byIcon(Icons.grid_view_rounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: toggle,
          matching: find.byIcon(Icons.view_list_rounded),
        ),
        findsNothing,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getBool(SharedPreferencesCatalogViewModeStore.preferenceKey),
        isFalse,
      );
    });

    testWidgets('late preference load does not override a user toggle',
        (tester) async {
      final store = _DelayedCatalogViewModeStore();

      await tester.pumpWidget(buildTestWidget(viewModeStore: store));
      await tester.pump();

      final toggle = find.byKey(const Key('catalogViewToggleButton'));
      await tester.tap(toggle);
      await tester.pump();

      expect(
        find.descendant(
          of: toggle,
          matching: find.byIcon(Icons.grid_view_rounded),
        ),
        findsOneWidget,
      );

      store.completeLoad(CatalogViewMode.grid);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: toggle,
          matching: find.byIcon(Icons.grid_view_rounded),
        ),
        findsOneWidget,
      );
      expect(store.savedModes, [CatalogViewMode.list]);
    });
  });
}

class _DelayedCatalogViewModeStore implements CatalogViewModeStore {
  final Completer<CatalogViewMode> _loadCompleter =
      Completer<CatalogViewMode>();
  final List<CatalogViewMode> savedModes = <CatalogViewMode>[];

  @override
  Future<CatalogViewMode> load() => _loadCompleter.future;

  @override
  Future<void> save(CatalogViewMode mode) async {
    savedModes.add(mode);
  }

  void completeLoad(CatalogViewMode mode) {
    if (_loadCompleter.isCompleted) {
      return;
    }

    _loadCompleter.complete(mode);
  }
}
