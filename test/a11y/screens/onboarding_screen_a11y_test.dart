import 'package:flutter_test/flutter_test.dart';

import '../shared/a11y_test_helpers.dart';
import '../shared/main_app_a11y_harness.dart';

void main() {
  group('OnboardingScreen accessibility', () {
    late MainAppA11yHarness harness;

    setUp(() async {
      harness = MainAppA11yHarness();
      // Force onboarding to show by NOT setting the completion flag.
      await harness.setUp(forceOnboarding: true);
    });

    testWidgets('meets Android tap target guideline', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, androidTapTargetGuideline);
    });

    testWidgets('meets labeled tap target guideline', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await expectMeetsAccessibilityGuideline(
          tester, labeledTapTargetGuideline);
    });

    testWidgets('meets text contrast guideline', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await expectMeetsAccessibilityGuideline(tester, textContrastGuideline);
    });
  });
}
