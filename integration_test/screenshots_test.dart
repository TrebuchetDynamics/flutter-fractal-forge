import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot walkthrough', () {
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
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
          // deepLinkService intentionally omitted for stability.
        ),
      );
      // Avoid indefinite pumpAndSettle: shader/animation frames may never fully settle.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
    }

    Future<void> prepareScreenshotSurfaceIfAvailable() async {
      try {
        await binding.convertFlutterSurfaceToImage();
      } on MissingPluginException {
        debugPrint(
            'Screenshot surface conversion unavailable on this platform');
      }
    }

    Future<void> takeScreenshotIfAvailable(String name) async {
      try {
        await binding.takeScreenshot(name);
      } on MissingPluginException {
        debugPrint('Screenshot plugin unavailable, skipping "$name"');
      }
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

    testWidgets(
      'capture key screens',
      (tester) async {
        await pumpApp(tester);

        // Required on Android for screenshot capture.
        await prepareScreenshotSurfaceIfAvailable();

        // If onboarding shows, try skip.
        final skip = find.text('Skip');
        if (skip.evaluate().isNotEmpty) {
          await takeScreenshotIfAvailable('00_onboarding');
          await tester.tap(skip);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 800));
        }

        await takeScreenshotIfAvailable('01_catalog');

        // Open first fractal viewer.
        final cards = moduleCards();
        expect(cards, findsWidgets);
        await tester.tap(cards.first);
        await tester.pump(const Duration(seconds: 2));

        await takeScreenshotIfAvailable('02_viewer');

        // Open tune panel if available.
        final tune = find.byIcon(Icons.tune_rounded);
        if (tune.evaluate().isNotEmpty) {
          await tester.tap(tune);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 800));
          await takeScreenshotIfAvailable('03_tune_panel');
        }

        // Return to catalog.
        final back = find.byIcon(Icons.arrow_back_rounded);
        if (back.evaluate().isNotEmpty) {
          await tester.tap(back);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 800));
        }

        await takeScreenshotIfAvailable('04_catalog_after_back');
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
