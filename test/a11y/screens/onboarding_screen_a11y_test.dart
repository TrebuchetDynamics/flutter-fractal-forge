import 'package:flutter_fractals/features/onboarding/onboarding_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shared/a11y_test_helpers.dart';
import '../shared/main_app_a11y_harness.dart';

/// These three cases do not reach OnboardingScreen, despite the group name.
///
/// FlutterFractalsApp imports only FractalSplashScreen from that library and
/// never builds OnboardingScreen, so `forceOnboarding: true` supplies an
/// OnboardingService that nothing consumes and the app settles on the home
/// screen. The guidelines below therefore measure home a second time.
///
/// Kept, with the first test now asserting what is actually on screen so the
/// group stops claiming coverage it does not have. The real screen is exercised
/// directly in test/screens/onboarding_screen_test.dart.
void main() {
  group('OnboardingScreen accessibility', () {
    late MainAppA11yHarness harness;

    setUp(() async {
      harness = MainAppA11yHarness();
      // Intended to force onboarding; see the note above on why it does not.
      await harness.setUp(forceOnboarding: true);
    });

    testWidgets('the app does not route to OnboardingScreen', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await pumpAccessibilityTestFrames(tester);

      // If this ever starts failing, onboarding has been wired into the app and
      // the guidelines below become real — move them to the direct harness in
      // test/screens/onboarding_screen_test.dart and delete this case.
      expect(
        find.byType(OnboardingScreen),
        findsNothing,
        reason: 'onboarding is now reachable; these guideline tests were only '
            'ever measuring the home screen',
      );
      await disposeAccessibilityTestWidget(tester);
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
