import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/renderer/fractal_renderer.dart';

Finder catalogSearchField() => find.byKey(const Key('catalogSearchField'));
Finder catalogModuleCard(String catalogId) =>
    find.byKey(ValueKey('catalogModuleCard_$catalogId'));

Finder catalogModuleCards() {
  return find.byWidgetPredicate((w) {
    final key = w.key;
    if (key is! ValueKey) return false;
    final value = key.value;
    if (value is! String) return false;
    return value.startsWith('catalogModuleCard_') ||
        value.startsWith('catalogGridTile_');
  });
}

Future<void> pumpForAppBoot(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> pumpForUiTransition(
  WidgetTester tester, {
  Duration settle = const Duration(milliseconds: 700),
}) async {
  await tester.pump();
  await tester.pump(settle);
}

void drainKnownShaderExceptions(WidgetTester tester) {
  while (true) {
    final error = tester.takeException();
    if (error == null) return;

    final message = error.toString();
    final isKnownSkSLError = message.contains('Invalid SkSL') ||
        message.contains("operator '%' is not allowed");
    if (!isKnownSkSLError) {
      fail('Unexpected Flutter exception: $error');
    }
  }
}

Future<void> openCatalogSearchField(
  WidgetTester tester, {
  Duration settle = const Duration(milliseconds: 700),
}) async {
  if (catalogSearchField().evaluate().isNotEmpty) {
    return;
  }

  final searchButton = find.byIcon(Icons.search_rounded);
  expect(
    searchButton,
    findsWidgets,
    reason: 'Catalog search toggle should be available before opening search',
  );

  await tester.tap(searchButton.first);
  await tester.pump();
  await tester.pump(settle);

  expect(
    catalogSearchField(),
    findsOneWidget,
    reason:
        'Catalog search field should appear after tapping the search toggle',
  );
}

Future<void> enterCatalogSearch(
  WidgetTester tester,
  String query, {
  Duration settle = const Duration(milliseconds: 700),
}) async {
  await openCatalogSearchField(tester, settle: settle);
  await tester.enterText(catalogSearchField(), query);
  await tester.pump();
  await tester.pump(settle);
}

Future<void> openViewerPresets(
  WidgetTester tester, {
  Duration settle = const Duration(milliseconds: 700),
}) async {
  final visiblePresetsButton = find.byIcon(Icons.bookmark_rounded);
  if (visiblePresetsButton.evaluate().isNotEmpty) {
    await tester.tap(visiblePresetsButton.first);
    await tester.pump();
    await tester.pump(settle);
    return;
  }

  final renderer = find.byType(FractalRenderer);
  expect(
    renderer,
    findsOneWidget,
    reason: 'Fractal renderer must be visible before opening presets',
  );

  await tester.longPress(renderer);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));

  final presetsMenuItem = find.byIcon(Icons.bookmark_rounded);
  expect(
    presetsMenuItem,
    findsWidgets,
    reason: 'Long-press context menu should expose a presets action',
  );

  await tester.tap(presetsMenuItem.last);
  await tester.pump();
  await tester.pump(settle);
}
