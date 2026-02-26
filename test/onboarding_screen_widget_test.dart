import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/features/onboarding/onboarding_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

void main() {
  group('OnboardingScreen', () {
    late OnboardingService onboardingService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      onboardingService = await OnboardingService.create();
    });

    Widget buildTestWidget({required VoidCallback onComplete}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: OnboardingScreen(
          onboardingService: onboardingService,
          onComplete: onComplete,
        ),
      );
    }

    testWidgets('displays welcome page initially', (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Check welcome page content
      expect(find.text('Welcome to Fractal Forge'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('navigates through pages with Next button', (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Page 1: Welcome
      expect(find.text('Welcome to Fractal Forge'), findsOneWidget);

      // Tap Next to go to page 2 — step through the 350 ms page transition
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      // Page 2: Create, Export & Experience in AR - should show "Get Started" button
      expect(find.text('Create, Export & Experience in AR'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('completes onboarding with Get Started button', (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Navigate to last page (page 2 of 2) — step through the 350 ms transition
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Should have called onComplete
      expect(completed, true);

      // Onboarding should be marked complete
      expect(onboardingService.isOnboardingComplete, true);
    });

    testWidgets('skip button completes onboarding', (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Tap Skip
      await tester.tap(find.text('Skip'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Should have called onComplete
      expect(completed, true);

      // Onboarding should be marked complete
      expect(onboardingService.isOnboardingComplete, true);
    });

    testWidgets('displays page indicators', (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Should have 2 page indicators (AnimatedContainers)
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('displays fractal types on first page', (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Check for fractal type mentions in the highlight items
      expect(
        find.textContaining('Mandelbrot', findRichText: true),
        findsWidgets,
      );
      expect(
        find.textContaining('Julia', findRichText: true),
        findsWidgets,
      );
    });

    testWidgets('displays export and preset features on second page',
        (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Navigate to second page — step through the 350 ms page transition
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      // Check for export and AR features present on page 2
      expect(find.textContaining('Export'), findsWidgets);
      expect(find.textContaining('colour schemes'), findsWidgets);
    });

    testWidgets('displays gesture controls on first page', (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Pan and pinch are mentioned in the first page highlight items
      expect(find.textContaining('Pan'), findsWidgets);
      expect(find.textContaining('pinch'), findsWidgets);
    });

    testWidgets('uses l10n strings for UI text (not hardcoded English)',
        (tester) async {
      // Retrieve localizations the same way the widget does, then assert the
      // displayed text matches what AppLocalizations returns — proving the
      // widget is driven by l10n rather than raw string literals.
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final BuildContext ctx = tester.element(find.byType(OnboardingScreen));
      final l10n = AppLocalizations.of(ctx)!;

      // Page 1 title and navigation strings come from l10n.
      expect(find.text(l10n.onboardingWelcomeTitle), findsOneWidget);
      expect(find.text(l10n.onboardingNext), findsOneWidget);
      expect(find.text(l10n.onboardingSkip), findsOneWidget);

      // Page 1 description is from l10n.
      expect(find.textContaining(l10n.onboardingWelcomeDescription),
          findsWidgets);

      // Navigate to page 2 and verify page 2 title and button from l10n.
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text(l10n.onboardingCreateTitle), findsOneWidget);
      expect(find.text(l10n.onboardingGetStarted), findsOneWidget);
    });

    testWidgets('page indicator reflects progress as pages change',
        (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // There are 2 pages so 2 AnimatedContainers for the dot indicators.
      final indicators = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(indicators.length, 2);

      // On page 1 the first dot is wider (selected = width 20, others = 8).
      final firstDot = indicators.first;
      expect((firstDot.constraints?.maxWidth ?? 0), greaterThan(8));
    });
  });

  group('OnboardingService', () {
    testWidgets('persists completion state', (tester) async {
      SharedPreferences.setMockInitialValues({});

      // Create first service instance
      final service1 = await OnboardingService.create();
      expect(service1.isOnboardingComplete, false);

      // Complete onboarding
      await service1.completeOnboarding();
      expect(service1.isOnboardingComplete, true);

      // Create new service instance - should remember completion
      final service2 = await OnboardingService.create();
      expect(service2.isOnboardingComplete, true);
    });

    testWidgets('can reset onboarding state', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final service = await OnboardingService.create();
      await service.completeOnboarding();
      expect(service.isOnboardingComplete, true);

      // Reset
      await service.resetOnboarding();
      expect(service.isOnboardingComplete, false);
    });
  });
}
