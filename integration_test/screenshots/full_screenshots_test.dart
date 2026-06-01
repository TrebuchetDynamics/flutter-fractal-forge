import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';

import '../helpers/ui_test_helpers.dart';

/// Full screenshot suite for Flutter Fractal Forge.
/// Captures:
/// - Catalog view
/// - All 5 fractal types (Mandelbulb, Mandelbrot, Julia, Burning Ship, Phoenix)
/// - Controls panel
/// - Presets panel
///
/// Run (Linux):
///   flutter test integration_test/full_screenshots_test.dart -d linux --reporter expanded
///
/// Run (Android):
///   flutter test integration_test/full_screenshots_test.dart -d emulator-5554 --reporter expanded
///
/// Headless (Linux/CI):
///   xvfb-run -a -s "-screen 0 1080x1920x24" \
///     flutter test integration_test/full_screenshots_test.dart -d linux --reporter expanded
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full Desktop Screenshots', () {
    final boundaryKey = GlobalKey();
    late PresetStore presetStore;
    late AccessibilityService accessibilityService;
    late RendererSettingsService rendererSettingsService;
    bool androidScreenshotMode = false;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      presetStore = await PresetStore.create();
      accessibilityService = await AccessibilityService.create();
      rendererSettingsService = await RendererSettingsService.create();
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() async {
        await binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: FlutterFractalsApp(
            presetStore: presetStore,
            accessibilityService: accessibilityService,
            rendererSettingsService: rendererSettingsService,
            locale: const Locale('en'),
          ),
        ),
      );
      // Avoid indefinite pumpAndSettle: shaders/animations can keep scheduling frames.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
    }

    Future<void> snap(WidgetTester tester, String name) async {
      await tester.pump(const Duration(milliseconds: 200));

      final safeName = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\-_.]+'), '_')
          .replaceAll(RegExp(r'_+'), '_');

      // Try desktop fallback first (works on Linux desktop).
      // On Android, prefer the integration_test screenshot path for stability.
      if (!Platform.isAndroid) {
        try {
          final dir = Directory('screenshots');
          if (!dir.existsSync()) {
            dir.createSync(recursive: true);
          }
          final ctx = boundaryKey.currentContext;
          if (ctx == null) {
            throw Exception('Screenshot boundary not mounted');
          }
          final boundary = ctx.findRenderObject() as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2.0);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          if (data == null) {
            throw Exception('Failed to encode screenshot PNG');
          }
          final file = File('screenshots/$safeName.png');
          await file.writeAsBytes(data.buffer.asUint8List());
          debugPrint('SCREENSHOT (repaint boundary): $safeName');
          return;
        } catch (e) {
          // Fall through to integration test screenshot
          debugPrint(
              'Repaint boundary failed: $e, trying integration screenshot');
        }
      }

      // For Android, need to convert surface first
      try {
        if (!androidScreenshotMode) {
          await binding.convertFlutterSurfaceToImage();
          androidScreenshotMode = true;
        }
        await binding.takeScreenshot(safeName);
        debugPrint('SCREENSHOT (integration): $safeName');
      } on MissingPluginException {
        debugPrint('SCREENSHOT SKIPPED (no plugin): $safeName');
      } catch (e) {
        debugPrint('SCREENSHOT FAILED: $safeName - $e');
      }
    }

    Future<void> tapModuleBySearch(
      WidgetTester tester, {
      required String query,
    }) async {
      await enterCatalogSearch(
        tester,
        query,
        settle: const Duration(milliseconds: 600),
      );

      final cards = catalogModuleCards();
      expect(cards, findsWidgets);
      await tester.tap(cards.first);
      await tester.pump();
    }

    void expectViewerOpened() {
      expect(catalogSearchField(), findsNothing);
    }

    testWidgets('01_catalog', (tester) async {
      await pumpApp(tester);
      // Verify we have module cards by finding dimension labels
      expect(find.text('3D'), findsWidgets);
      expect(find.text('2D'), findsWidgets);
      await snap(tester, '01_catalog');
    });

    // Catalog order (by dimension grouping):
    // 3D section: Mandelbulb (index 0 in group)
    // 2D section: Mandelbrot, Julia, Burning Ship, Phoenix

    testWidgets('02_viewer_mandelbulb', (tester) async {
      await pumpApp(tester);
      await tapModuleBySearch(
        tester,
        query: 'Mandelbulb',
      );
      await tester.pump(const Duration(seconds: 3));
      expectViewerOpened();
      await snap(tester, '02_viewer_mandelbulb');
    });

    testWidgets('03_viewer_mandelbrot', (tester) async {
      await pumpApp(tester);
      await tapModuleBySearch(
        tester,
        query: 'Mandelbrot',
      );
      await tester.pump(const Duration(seconds: 3));
      expectViewerOpened();
      await snap(tester, '03_viewer_mandelbrot');
    });

    testWidgets('04_viewer_julia', (tester) async {
      await pumpApp(tester);
      await tapModuleBySearch(tester, query: 'Julia');
      await tester.pump(const Duration(seconds: 3));
      expectViewerOpened();
      await snap(tester, '04_viewer_julia');
    });

    testWidgets('05_viewer_burning_ship', (tester) async {
      await pumpApp(tester);
      await tapModuleBySearch(
        tester,
        query: 'Burning',
      );
      await tester.pump(const Duration(seconds: 3));
      expectViewerOpened();
      await snap(tester, '05_viewer_burning_ship');
    });

    testWidgets('06_viewer_phoenix', (tester) async {
      await pumpApp(tester);
      await tapModuleBySearch(tester, query: 'Phoenix');
      await tester.pump(const Duration(seconds: 3));
      expectViewerOpened();
      await snap(tester, '06_viewer_phoenix');
    });

    testWidgets('07_controls_panel', (tester) async {
      await pumpApp(tester);
      // Open a 2D fractal to ensure controls affordances are present.
      await tapModuleBySearch(
        tester,
        query: 'Mandelbrot',
      );
      await tester.pump(const Duration(seconds: 3));
      expectViewerOpened();

      // Open controls panel (Icons.tune_rounded)
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      await snap(tester, '07_controls_panel');
    });

    testWidgets('08_presets_panel', (tester) async {
      await pumpApp(tester);
      // Open Julia set (has nice presets)
      await tapModuleBySearch(tester, query: 'Julia');
      await tester.pump(const Duration(seconds: 3));
      expectViewerOpened();

      // Open presets panel (Icons.bookmark_rounded)
      await openViewerPresets(
        tester,
        settle: const Duration(milliseconds: 800),
      );

      await snap(tester, '08_presets_panel');
    });
  });
}
