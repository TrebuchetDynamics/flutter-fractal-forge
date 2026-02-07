import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Catalog search filters fractal modules', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final presetStore = await PresetStore.create();
    final arQualityStore = await ArQualityStore.create();
    await tester.pumpWidget(
      FlutterFractalsApp(
        presetStore: presetStore,
        arQualityStore: arQualityStore,
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fractal Catalog'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('catalogSearchField')), 'Julia');
    await tester.pumpAndSettle();

    expect(find.text('Julia'), findsOneWidget);
    expect(find.text('Mandelbrot'), findsNothing);

    // Clear button should reset the list.
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(find.text('Mandelbrot'), findsOneWidget);

    // Searching for something nonexistent should show an empty state + clear-search button.
    await tester.enterText(find.byKey(const Key('catalogSearchField')), 'zzzz');
    await tester.pumpAndSettle();

    expect(find.text('No fractals match your search.'), findsOneWidget);
    expect(find.byKey(const Key('catalogClearSearchButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('catalogClearSearchButton')));
    await tester.pumpAndSettle();

    expect(find.text('Mandelbrot'), findsOneWidget);
  });
}
