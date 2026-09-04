import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpCatalog(WidgetTester tester) async {
    final registry = ModuleRegistry();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ModuleRegistry>.value(value: registry),
          ChangeNotifierProvider<FractalController>(
            create: (_) => FractalController(registry),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FractalCatalogScreen(),
          ),
        ),
      ),
    );

    // Bounded pumps instead of pumpAndSettle: catalog shimmer animations repeat.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> showSearch(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('catalogSearchToggleButton')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
  }

  testWidgets('Catalog search filters fractal modules', (tester) async {
    await pumpCatalog(tester);
    await showSearch(tester);

    await tester.enterText(
      find.byKey(const Key('catalogSearchField')),
      'Julia',
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Julia'), findsWidgets);
    expect(find.text('Mandelbrot'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Catalog restores persisted search and filter state',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'catalog_browse_query': 'Mandelbrot',
      'catalog_browse_category': 'Escape-Time',
    });

    await pumpCatalog(tester);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('catalogSearchField')))
          .controller!
          .text,
      'Mandelbrot',
    );
    expect(find.text('Mandelbrot'), findsWidgets);
    expect(find.text('Barnsley Fern'), findsNothing);
  });

  testWidgets('Catalog searches dimension and name together', (tester) async {
    await pumpCatalog(tester);
    await showSearch(tester);
    await tester.enterText(
      find.byKey(const Key('catalogSearchField')),
      '3d mandelbulb',
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mandelbulb'), findsWidgets);
    expect(find.text('Mandelbrot'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Catalog persists category and scroll position', (tester) async {
    await pumpCatalog(tester);

    await tester.tap(find.byKey(const Key('catalogCategoryChip_escape_time')));
    await tester.pump();
    final scrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    tester.state<ScrollableState>(scrollable).position.jumpTo(600);
    await tester.pump(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('catalog_browse_category'), 'Escape-Time');
    expect(prefs.getDouble('catalog_browse_scroll_offset'), closeTo(600, 0.1));
  });

  testWidgets('Catalog favorites persist and filter the grid', (tester) async {
    await pumpCatalog(tester);
    await showSearch(tester);
    await tester.enterText(
      find.byKey(const Key('catalogSearchField')),
      'Mandelbrot',
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(
      find.byKey(const Key('catalogFavorite_core.mandelbrot')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('catalogSearchToggleButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('catalogCategoryChip_favorites')));
    await tester.pump();

    expect(find.text('Mandelbrot'), findsWidgets);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('catalog_favorite_ids'), ['core.mandelbrot']);
  });

  testWidgets('Opening a module records it in the recent filter',
      (tester) async {
    await pumpCatalog(tester);
    await showSearch(tester);
    await tester.enterText(
      find.byKey(const Key('catalogSearchField')),
      'Mandelbrot',
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester
        .tap(find.byKey(const Key('catalogModuleCard_core.mandelbrot')));
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('catalog_recent_ids'), ['core.mandelbrot']);
  });

  testWidgets('Catalog renders category chips in a separate rail',
      (tester) async {
    await pumpCatalog(tester);

    expect(find.byKey(const Key('catalogCategoryChip_all')), findsOneWidget);
    expect(find.byKey(const Key('catalogCategoryScroll')), findsOneWidget);
    expect(find.byKey(const Key('catalogDimensionChip_all')), findsNothing);
    expect(find.byKey(const Key('catalogDimensionChip_2d')), findsNothing);
    expect(find.byKey(const Key('catalogDimensionChip_3d')), findsNothing);
    expect(find.byKey(const Key('catalogDimensionChip_kaleidoscope')),
        findsNothing);
    expect(find.text('All categories'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });

  test('runtime thumbnail previews keep ready state for scroll reuse', () {
    CatalogRuntimeThumbnailCache.clearForTesting();
    expect(CatalogRuntimeThumbnailCache.isReady('core.mandelbrot'), isFalse);

    CatalogRuntimeThumbnailCache.markReady('core.mandelbrot');

    expect(CatalogRuntimeThumbnailCache.isReady('core.mandelbrot'), isTrue);
    expect(CatalogRuntimeThumbnailCache.isReady('core.julia'), isFalse);
  });

  testWidgets('recycled thumbnails reuse the loaded manifest immediately',
      (tester) async {
    await pumpCatalog(tester);
    CatalogRuntimeThumbnailCache.setManifestForTesting(const <String>{});

    final scrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    tester.state<ScrollableState>(scrollable).position.jumpTo(2000);
    await tester.pump();

    expect(find.byType(ShaderMask), findsNothing);
  });

  testWidgets(
    'runtime thumbnails stay ready after scroll recycling',
    (tester) async {
      CatalogRuntimeThumbnailCache.clearForTesting();
      await pumpCatalog(tester);
      await tester.pump(const Duration(seconds: 3));

      final readyBeforeScroll =
          CatalogRuntimeThumbnailCache.readyCountForTesting;
      expect(readyBeforeScroll, greaterThan(0));

      await tester.fling(
          find.byType(Scrollable).first, const Offset(0, -1200), 1000);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.fling(
          find.byType(Scrollable).first, const Offset(0, 1200), 1000);
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        CatalogRuntimeThumbnailCache.readyCountForTesting,
        greaterThanOrEqualTo(readyBeforeScroll),
      );
    },
    skip: !const bool.fromEnvironment('FORCE_RUNTIME_CATALOG_THUMBNAILS'),
  );

  testWidgets('Catalog search field uses the focused visual state',
      (tester) async {
    await pumpCatalog(tester);
    await showSearch(tester);

    final searchField = tester.widget<TextField>(
      find.byKey(const Key('catalogSearchField')),
    );
    expect(searchField.focusNode?.hasFocus, isTrue);

    final decoration = searchField.decoration!;
    final focusedBorder = decoration.focusedBorder! as OutlineInputBorder;

    expect(focusedBorder.borderSide.color,
        AppColors.primary.withValues(alpha: 0.6));
    expect(focusedBorder.borderSide.width, 1.5);

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Catalog search debounce waits for the latest edit',
      (tester) async {
    await pumpCatalog(tester);
    await showSearch(tester);

    final searchField = find.byKey(const Key('catalogSearchField'));
    await tester.enterText(searchField, 'J');
    await tester.pump(const Duration(milliseconds: 150));
    await tester.enterText(searchField, 'Julia');

    // More than 300ms after the first edit, but less than 300ms after the
    // latest edit. The filtered result should wait for the latest edit.
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const Key('catalogActiveSearchChip')), findsNothing);

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Julia'), findsWidgets);
    expect(find.byKey(const Key('catalogActiveSearchChip')), findsNothing);

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Catalog search clear icon resets the applied query immediately',
      (tester) async {
    await pumpCatalog(tester);
    await showSearch(tester);

    final searchField = find.byKey(const Key('catalogSearchField'));

    await tester.enterText(searchField, 'Julia');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Julia'), findsWidgets);
    expect(find.byKey(const Key('catalogActiveSearchChip')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('clear')));
    await tester.pump();

    expect(find.byKey(const Key('catalogActiveSearchChip')), findsNothing);
    expect(
      tester.widget<TextField>(searchField).controller?.text,
      isEmpty,
    );

    await tester.pump(const Duration(seconds: 3));
  });
}
