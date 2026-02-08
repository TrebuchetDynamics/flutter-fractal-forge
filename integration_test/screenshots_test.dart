import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;

  group('Screenshot walkthrough', () {
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;
    late AccessibilityService accessibilityService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();
      accessibilityService = await AccessibilityService.create();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          arQualityStore: arQualityStore,
          accessibilityService: accessibilityService,
          locale: const Locale('en'),
          // deepLinkService intentionally omitted for stability.
        ),
      );
      await tester.pumpAndSettle();
    }

    Finder moduleCards() {
      return find.byWidgetPredicate((w) {
        final k = w.key;
        if (k is! ValueKey) return false;
        final v = k.value;
        return v is String && v.startsWith('catalogModuleCard_');
      });
    }

    testWidgets('capture key screens', (tester) async {
      await pumpApp(tester);

      // If onboarding shows, try skip.
      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await binding.takeScreenshot('00_onboarding');
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await binding.takeScreenshot('01_catalog');

      // Open first fractal viewer.
      final cards = moduleCards();
      expect(cards, findsWidgets);
      await tester.tap(cards.first);
      await tester.pump(const Duration(seconds: 2));

      await binding.takeScreenshot('02_viewer');

      // Open tune panel if available.
      final tune = find.byIcon(Icons.tune_rounded);
      if (tune.evaluate().isNotEmpty) {
        await tester.tap(tune);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('03_tune_panel');
      }

      // Return to catalog.
      final back = find.byIcon(Icons.arrow_back_rounded);
      if (back.evaluate().isNotEmpty) {
        await tester.tap(back);
        await tester.pumpAndSettle();
      }

      await binding.takeScreenshot('04_catalog_after_back');
    });
  });
}
