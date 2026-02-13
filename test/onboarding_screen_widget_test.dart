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
      expect(find.text('Welcome to Flutter Fractals'), findsOneWidget);
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
      expect(find.text('Welcome to Flutter Fractals'), findsOneWidget);

      // Tap Next to go to page 2
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Page 2: Fractal Types
      expect(find.text('Discover Fractal Types'), findsOneWidget);

      // Tap Next to go to page 3
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Page 3: Gestures
      expect(find.text('Intuitive Controls'), findsOneWidget);

      // Tap Next to go to page 4
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Page 4: Features - should show "Get Started" button
      expect(find.text('Powerful Features'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('completes onboarding with Get Started button', (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Navigate to last page
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

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

      // Should have 4 page indicators (AnimatedContainers)
      // This is a basic check - more detailed checks would require finding specific widgets
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('displays fractal types on second page', (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Navigate to fractal types page
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Check for fractal names
      expect(find.text('Mandelbrot'), findsOneWidget);
      expect(find.text('Julia'), findsOneWidget);
    });

    testWidgets('displays gesture controls on third page', (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Navigate to gestures page
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Check for gesture names
      expect(find.text('Pan'), findsOneWidget);
      expect(find.text('Zoom'), findsOneWidget);
      // Rotate/Double Tap are optional depending on the onboarding copy.
    });

    testWidgets('displays features on fourth page', (tester) async {
      bool completed = false; // ignore: unused_local_variable
      await tester.pumpWidget(buildTestWidget(
        onComplete: () => completed = true,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Navigate to features page
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Check for feature names
      expect(find.text('Presets'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('AR Mode'), findsOneWidget);
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
