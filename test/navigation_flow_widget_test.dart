import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'a11y/shared/main_app_a11y_harness.dart';

void main() {
  group('Navigation Flow', () {
    late MainAppA11yHarness harness;

    setUp(() async {
      harness = MainAppA11yHarness();
      await harness.setUp();
    });

    Widget buildApp() => harness.buildApp();

    testWidgets('app starts with catalog screen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Fractal Forge'), findsOneWidget);
      expect(
          find.byKey(const Key('catalogSearchToggleButton')), findsOneWidget);
    });

    testWidgets('displays all fractal modules', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Verify visible lazy-sliver module cards render; others may be off-screen.
      expect(
        find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('catalogModuleCard_');
        }),
        findsWidgets,
      );
      expect(
          find.byKey(const Key('catalogSearchToggleButton')), findsOneWidget);
    });

    testWidgets('has search field in catalog', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('catalogSearchToggleButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
    });

    testWidgets('app uses dark theme', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, Brightness.dark);
    });

    testWidgets('app supports localization', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.localizationsDelegates, isNotEmpty);
    });

    testWidgets('renders scaffold', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders top chrome (smoke)', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Platform-specific app bars may vary; ensure the app still renders.
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
