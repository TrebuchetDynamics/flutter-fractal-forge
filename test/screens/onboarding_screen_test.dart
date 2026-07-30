import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/storage/onboarding_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/onboarding/onboarding_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../a11y/semantics/interactive_name_audit.dart';
import '../helpers/overflow_guard.dart';

/// Renders [OnboardingScreen] directly.
///
/// It has to be constructed here rather than reached through the app:
/// FlutterFractalsApp imports only FractalSplashScreen from that library, so
/// nothing in lib/ ever builds this screen. test/a11y/screens/
/// onboarding_screen_a11y_test.dart pumps the whole app expecting to find it and
/// gets the home screen instead, which is why its three guideline tests have
/// never looked at any of this.
Future<void> _pumpOnboarding(
  WidgetTester tester, {
  double textScale = 1.0,
  Size? size,
  Locale locale = const Locale('en'),
}) async {
  if (size != null) {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }
  SharedPreferences.setMockInitialValues({});
  final service = await OnboardingService.create();

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: OnboardingScreen(
        onboardingService: service,
        onComplete: () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders and exposes its controls', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpOnboarding(tester);

      final root = semanticsRoot(tester);
      final names = operableControlNames(root);
      expect(names, isNotEmpty, reason: 'the screen never rendered');
      expect(findUnnamedControls(root).map((c) => '$c').toList(), isEmpty);
      expect(findStackedStops(root), isEmpty);
      handle.dispose();
    });

    testWidgets('meets contrast and tap target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpOnboarding(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    // Both orientations: the portrait and landscape branches lay out
    // differently and both pinned a header above a flexible list.
    for (final scale in const [1.0, 1.3, 2.0, 3.0]) {
      for (final size in const [
        Size(360, 640),
        Size(320, 568),
        Size(640, 360),
        Size(568, 320),
      ]) {
        testWidgets('no overflow at ${scale}x on $size', (tester) async {
          await expectNoOverflow(
            () => _pumpOnboarding(tester, textScale: scale, size: size),
            reason: '$scale x on $size',
          );
        });
      }
    }

    testWidgets('copy localizes', (tester) async {
      await _pumpOnboarding(tester, locale: const Locale('es'));
      expect(find.text('Omitir'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
      expect(find.text('Next'), findsNothing);
    });
  });
}
