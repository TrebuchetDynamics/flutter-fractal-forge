import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/onboarding/splash_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _mountSplash(
  WidgetTester tester,
  FractalSplashScreen splash, {
  bool disableAnimations = false,
  AccessibilityService? accessibility,
}) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: disableAnimations);
  addTearDown(() async {
    try {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 3));
    } finally {
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      accessibility?.dispose();
    }
  });
  Widget app = MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.dark,
    home: splash,
  );
  if (accessibility != null) {
    app = ChangeNotifierProvider<AccessibilityService>.value(
      value: accessibility,
      child: app,
    );
  }
  await tester.pumpWidget(app);
}

double _decorationAngle(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(find.byType(DecoratedBox))
    .map((box) => box.decoration)
    .whereType<BoxDecoration>()
    .map((decoration) => decoration.gradient)
    .whereType<SweepGradient>()
    .single
    .startAngle;

Future<void> _expectMotion(WidgetTester tester, bool animated) async {
  final angle = _decorationAngle(tester);
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.binding.transientCallbackCount, animated ? 1 : 0);
  expect(_decorationAngle(tester), animated ? isNot(angle) : angle);
  expect(find.text('FRACTAL FORGE'), findsOneWidget);
}

void main() {
  group('FractalSplashScreen', () {
    testWidgets('shows title and finishes within three seconds',
        (tester) async {
      var finished = false;
      final splash = FractalSplashScreen(onFinished: () => finished = true);

      expect(splash.duration, lessThanOrEqualTo(const Duration(seconds: 3)));

      await _mountSplash(tester, splash);

      expect(find.text('FRACTAL FORGE'), findsOneWidget);
      await tester.pump(splash.duration);
      expect(finished, isTrue);
    });

    for (final mode in ['OS reduced', 'ordinary', 'saved reduced']) {
      testWidgets('$mode motion preserves decoration and completion',
          (tester) async {
        AccessibilityService? accessibility;
        if (mode == 'saved reduced') {
          SharedPreferences.setMockInitialValues({
            'accessibility_reduced_motion': true,
          });
          accessibility = AccessibilityService(
            await SharedPreferences.getInstance(),
          );
        }
        var completions = 0;
        final splash = FractalSplashScreen(onFinished: () => completions++);
        await _mountSplash(
          tester,
          splash,
          disableAnimations: mode == 'OS reduced',
          accessibility: accessibility,
        );
        expect(_decorationAngle(tester), 0);
        await tester.pump(const Duration(milliseconds: 250));
        await _expectMotion(tester, mode == 'ordinary');
        await tester.pump(const Duration(milliseconds: 2049));
        expect(completions, 0);
        await tester.pump(const Duration(milliseconds: 1));
        expect(completions, 1);
        await tester.pump(const Duration(milliseconds: 100));
        expect(completions, 1);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('live preferences gate motion before and after delayed start',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final accessibility = AccessibilityService(
        await SharedPreferences.getInstance(),
      );
      var completions = 0;
      final splash = FractalSplashScreen(onFinished: () => completions++);
      await _mountSplash(tester, splash, accessibility: accessibility);
      final deadline = tester.binding.clock.now().add(splash.duration);

      await tester.pump(const Duration(milliseconds: 100));
      await accessibility.setReducedMotion(true);
      await tester.pump();
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      await tester.pump();
      await accessibility.setReducedMotion(false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await _expectMotion(tester, false); // Delayed start must respect OS.

      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: false);
      await tester.pump();
      await _expectMotion(tester, true);
      await accessibility.setReducedMotion(true);
      await tester.pump();
      await _expectMotion(tester, false);
      await accessibility.setReducedMotion(false);
      await tester.pump();
      await _expectMotion(tester, true);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      await tester.pump();
      await _expectMotion(tester, false);
      await accessibility.setReducedMotion(true);
      await tester.pump();
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: false);
      await tester.pump();
      await _expectMotion(tester, false); // OS false must respect saved flag.
      await accessibility.setReducedMotion(false);
      await tester.pump();
      await _expectMotion(tester, true);

      await tester.pump(deadline.difference(tester.binding.clock.now()) -
          const Duration(milliseconds: 1));
      expect(completions, 0);
      await tester.pump(const Duration(milliseconds: 1));
      expect(completions, 1);
      await tester.pump(const Duration(milliseconds: 100));
      expect(completions, 1);
      expect(tester.takeException(), isNull);
    });

    for (final unmountAt in [100, 300]) {
      testWidgets('unmount at $unmountAt ms leaves no ticker or callback',
          (tester) async {
        var completions = 0;
        await _mountSplash(
          tester,
          FractalSplashScreen(onFinished: () => completions++),
        );
        await tester.pump(Duration(milliseconds: unmountAt));
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 3));
        expect(completions, 0);
        expect(tester.binding.transientCallbackCount, 0);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
