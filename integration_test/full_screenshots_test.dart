import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/main.dart';

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
    late ArQualityStore arQualityStore;
    late AccessibilityService accessibilityService;
    bool androidScreenshotMode = false;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();
      accessibilityService = await AccessibilityService.create();
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
            arQualityStore: arQualityStore,
            accessibilityService: accessibilityService,
            locale: const Locale('en'),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> snap(WidgetTester tester, String name) async {
      await tester.pump(const Duration(milliseconds: 200));

      final safeName = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\-_.]+'), '_')
          .replaceAll(RegExp(r'_+'), '_');

      // Try desktop fallback first (works on Linux desktop)
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
        // ignore: avoid_print
        print('SCREENSHOT (repaint boundary): $safeName');
        return;
      } catch (e) {
        // Fall through to integration test screenshot
        debugPrint('Repaint boundary failed: $e, trying integration screenshot');
      }

      // For Android, need to convert surface first
      try {
        if (!androidScreenshotMode) {
          await binding.convertFlutterSurfaceToImage();
          androidScreenshotMode = true;
        }
        await binding.takeScreenshot(safeName);
        // ignore: avoid_print
        print('SCREENSHOT (integration): $safeName');
      } on MissingPluginException {
        // ignore: avoid_print
        print('SCREENSHOT SKIPPED (no plugin): $safeName');
      } catch (e) {
        // ignore: avoid_print
        print('SCREENSHOT FAILED: $safeName - $e');
      }
    }

    // Helper to find module cards by text
    Finder findModuleCard(String name) {
      return find.ancestor(
        of: find.text(name),
        matching: find.byType(GestureDetector),
      ).first;
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
      // Find Mandelbulb card by text
      final mandelbulbCard = findModuleCard('Mandelbulb');
      await tester.tap(mandelbulbCard);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byIcon(Icons.tune), findsOneWidget);
      await snap(tester, '02_viewer_mandelbulb');
    });

    testWidgets('03_viewer_mandelbrot', (tester) async {
      await pumpApp(tester);
      final card = findModuleCard('Mandelbrot');
      await tester.tap(card);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byIcon(Icons.tune), findsOneWidget);
      await snap(tester, '03_viewer_mandelbrot');
    });

    testWidgets('04_viewer_julia', (tester) async {
      await pumpApp(tester);
      final card = findModuleCard('Julia');
      await tester.tap(card);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byIcon(Icons.tune), findsOneWidget);
      await snap(tester, '04_viewer_julia');
    });

    testWidgets('05_viewer_burning_ship', (tester) async {
      await pumpApp(tester);
      final card = findModuleCard('Burning Ship');
      await tester.tap(card);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byIcon(Icons.tune), findsOneWidget);
      await snap(tester, '05_viewer_burning_ship');
    });

    testWidgets('06_viewer_phoenix', (tester) async {
      await pumpApp(tester);
      final card = findModuleCard('Phoenix');
      await tester.tap(card);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byIcon(Icons.tune), findsOneWidget);
      await snap(tester, '06_viewer_phoenix');
    });

    testWidgets('07_controls_panel', (tester) async {
      await pumpApp(tester);
      // Open Mandelbulb (3D fractal for more interesting controls)
      final mandelbulbCard = findModuleCard('Mandelbulb');
      await tester.tap(mandelbulbCard);
      await tester.pump(const Duration(seconds: 3));

      // Open controls panel (Icons.tune)
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      await snap(tester, '07_controls_panel');
    });

    testWidgets('08_presets_panel', (tester) async {
      await pumpApp(tester);
      // Open Julia set (has nice presets)
      final juliaCard = findModuleCard('Julia');
      await tester.tap(juliaCard);
      await tester.pump(const Duration(seconds: 3));

      // Open presets panel (Icons.bookmark)
      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      await snap(tester, '08_presets_panel');
    });
  });
}
