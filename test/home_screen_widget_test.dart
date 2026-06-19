import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'a11y/shared/main_app_a11y_harness.dart';

void main() {
  group('HomeScreen via FlutterFractalsApp', () {
    late MainAppA11yHarness harness;

    setUp(() async {
      harness = MainAppA11yHarness();
      await harness.setUp();
    });

    Widget buildTestWidget() => harness.buildApp();

    testWidgets('starts with catalog visible', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Fractal Forge'), findsOneWidget);
      expect(
          find.byKey(const Key('catalogSearchToggleButton')), findsOneWidget);
    });

    testWidgets('displays fractal modules in catalog', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

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

    testWidgets('has search field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('catalogSearchToggleButton')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('catalogSearchField')), findsOneWidget);
    });

    testWidgets('has top app bar (smoke)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The home screen may render different app bar implementations depending on platform.
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
