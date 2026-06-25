import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
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

  int allDimensionCount(WidgetTester tester) {
    final countTexts = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('catalogDimensionChip_all')),
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data)
        .whereType<String>()
        .toList();
    return int.parse(countTexts.last);
  }

  testWidgets('Catalog search filters fractal modules', (tester) async {
    await pumpCatalog(tester);
    final initialCount = allDimensionCount(tester);
    await showSearch(tester);

    await tester.enterText(
      find.byKey(const Key('catalogSearchField')),
      'Julia',
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Julia'), findsWidgets);
    expect(allDimensionCount(tester), lessThan(initialCount));

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Catalog renders category chips in the single filter row',
      (tester) async {
    await pumpCatalog(tester);

    expect(find.byKey(const Key('catalogCategoryChip_all')), findsOneWidget);
    expect(find.byKey(const Key('catalogCategoryScroll')), findsNothing);

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Catalog search field uses the focused visual state',
      (tester) async {
    await pumpCatalog(tester);
    await showSearch(tester);

    final searchField = tester.widget<TextField>(
      find.byKey(const Key('catalogSearchField')),
    );
    expect(searchField.focusNode?.hasFocus, isTrue);

    final container = tester.widget<AnimatedContainer>(
      find.byKey(const Key('catalogSearchContainer')),
    );
    final decoration = container.decoration! as BoxDecoration;
    final border = decoration.border! as Border;

    expect(border.top.color, AppColors.primary.withValues(alpha: 0.6));
    expect(border.top.width, 1.5);

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Catalog search debounce waits for the latest edit',
      (tester) async {
    await pumpCatalog(tester);
    await showSearch(tester);

    final initialCount = allDimensionCount(tester);
    final searchField = find.byKey(const Key('catalogSearchField'));
    await tester.enterText(searchField, 'J');
    await tester.pump(const Duration(milliseconds: 150));
    await tester.enterText(searchField, 'Julia');

    // More than 300ms after the first edit, but less than 300ms after the
    // latest edit. Search results should still show the unfiltered catalog.
    await tester.pump(const Duration(milliseconds: 200));
    expect(allDimensionCount(tester), initialCount);

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Julia'), findsWidgets);
    expect(allDimensionCount(tester), lessThan(initialCount));

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Catalog search clear icon resets the applied query immediately',
      (tester) async {
    await pumpCatalog(tester);
    await showSearch(tester);

    final initialCount = allDimensionCount(tester);
    final searchField = find.byKey(const Key('catalogSearchField'));

    await tester.enterText(searchField, 'Julia');
    await tester.pump(const Duration(milliseconds: 300));
    expect(allDimensionCount(tester), lessThan(initialCount));

    await tester.tap(find.byKey(const ValueKey('clear')));
    await tester.pump();

    expect(allDimensionCount(tester), initialCount);

    await tester.pump(const Duration(seconds: 3));
  });
}
