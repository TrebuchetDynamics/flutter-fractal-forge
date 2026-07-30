import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/onboarding/splash_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';

void main() {
  group('FractalSplashScreen', () {
    testWidgets('shows title and finishes within three seconds',
        (tester) async {
      var finished = false;
      final splash = FractalSplashScreen(onFinished: () => finished = true);

      expect(splash.duration, lessThanOrEqualTo(const Duration(seconds: 3)));

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: splash,
      ));

      expect(find.text('FRACTAL FORGE'), findsOneWidget);
      await tester.pump(splash.duration);
      expect(finished, isTrue);
    });
  });
}
