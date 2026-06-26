import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/platform/accessibility_service.dart';
import 'package:flutter_fractals/core/services/storage/onboarding_service.dart';
import 'package:flutter_fractals/core/services/storage/preset_store.dart';
import 'package:flutter_fractals/core/services/storage/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Required on Android for IntegrationTest screenshot capture.
    // Not all runners provide this plugin; degrade gracefully.
    try {
      await binding.convertFlutterSurfaceToImage();
    } on MissingPluginException {
      debugPrint('Screenshot surface conversion unavailable on this platform');
    }
  });

  group('Backend screenshots', () {
    late PresetStore presetStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'onboarding_version': OnboardingService.currentVersion,
      });
      presetStore = await PresetStore.create();
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          accessibilityService: accessibilityService,
          rendererSettingsService: rendererSettingsService,
          locale: const Locale('en'),
        ),
      );
      // Avoid pumpAndSettle (continuous animations).
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
    }

    Finder moduleCards() {
      // Catalog supports list + grid view.
      return find.byWidgetPredicate((w) {
        final k = w.key;
        if (k is! ValueKey) return false;
        final v = k.value;
        if (v is! String) return false;
        return v.startsWith('catalogModuleCard_') ||
            v.startsWith('catalogGridTile_');
      });
    }

    Future<void> snapViewer(WidgetTester tester, String name) async {
      // Give the renderer time to produce a few frames.
      await tester.pump(const Duration(seconds: 3));
      try {
        await binding.takeScreenshot(name);
      } on MissingPluginException {
        debugPrint('Screenshot plugin unavailable, skipping "$name"');
      }
    }

    testWidgets('capture viewer screenshots (first visible modules)',
        (tester) async {
      await pumpApp(tester);

      final cards = moduleCards();
      expect(cards, findsWidgets);

      // Grab the first few visible cards; this avoids brittle scrolling by id.
      final count = cards.evaluate().length;
      final take = count >= 4 ? 4 : count;
      expect(take, greaterThanOrEqualTo(1));

      for (int i = 0; i < take; i++) {
        // Tap module card.
        await tester.tap(cards.at(i));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));

        // Viewer should be present.
        expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
        await snapViewer(tester, 'viewer_$i');

        // Back to catalog.
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
      }
    }, timeout: const Timeout(Duration(minutes: 12)));
  });
}
