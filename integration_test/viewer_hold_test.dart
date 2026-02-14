import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Viewer hold', () {
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'onboarding_version': OnboardingService.currentVersion,
      });
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          arQualityStore: arQualityStore,
          accessibilityService: accessibilityService,
          rendererSettingsService: rendererSettingsService,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
    }

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

    testWidgets('open first module and hold on viewer for screenshot capture',
        (tester) async {
      await pumpApp(tester);

      final cards = moduleCards();
      expect(cards, findsWidgets);

      await tester.tap(cards.first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));

      // Viewer loaded.
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Hold so the outer runner can capture a screenshot.
      await tester.pump(const Duration(seconds: 6));
    }, timeout: const Timeout(Duration(minutes: 5)));
  });
}
