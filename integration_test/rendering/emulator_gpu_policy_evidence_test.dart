import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/storage/onboarding_service.dart';
import 'package:flutter_fractals/main.dart' as app;

import '../helpers/ui_test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder moduleCards() {
    return find.byWidgetPredicate((w) {
      final k = w.key;
      if (k is! ValueKey) return false;
      final v = k.value;
      if (v is! String) return false;
      return v.startsWith('catalogModuleCard_') ||
          v.startsWith('catalogGridTile_');
    });
  }

  testWidgets('emulator auto policy probes three representative 2D fractals',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'onboarding_version': OnboardingService.currentVersion,
    });

    await app.main();
    await pumpForAppBoot(tester);

    for (int i = 0; i < 3; i++) {
      final cards = moduleCards();
      expect(cards, findsWidgets);

      final target = cards.at(i);
      final widget = tester.widget(target);
      debugPrint('[integration] opening_card_index=$i key=${widget.key}');

      await tester.tap(target);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget,
          reason: 'Viewer did not open for card index $i');

      // Wait long enough for the 2s GPU health probe timer + sampling work.
      await tester.pump(const Duration(seconds: 6));

      final backButton = find.byIcon(Icons.arrow_back_rounded);
      await tester.tap(backButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
