import 'package:flutter_test/flutter_test.dart';

import '../shared/a11y_test_helpers.dart';
import '../shared/main_app_a11y_harness.dart';

void main() {
  group('FractalCatalogScreen accessibility', () {
    late MainAppA11yHarness harness;

    setUp(() async {
      harness = MainAppA11yHarness();
      await harness.setUp();
    });

    testWidgets('catalog meets Android tap target guideline', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      // Home screen shows the catalog embedded.
      await expectMeetsAccessibilityGuideline(
          tester, androidTapTargetGuideline);
    });

    testWidgets('catalog meets labeled tap target guideline', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, labeledTapTargetGuideline);
    });

    testWidgets('catalog meets text contrast guideline', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await expectMeetsAccessibilityGuideline(tester, textContrastGuideline);
    });
  });
}
