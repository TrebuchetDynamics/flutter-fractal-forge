import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/main.dart';

/// Integration-test driven screenshots that work on desktop (Linux/macOS/Windows)
/// without requiring an Android emulator.
///
/// Run (Linux):
///   flutter test integration_test/screenshots_test.dart -d linux --reporter expanded
///
/// Headless (Linux/CI):
///   xvfb-run -a -s "-screen 0 1080x1920x24" \
///     flutter test integration_test/screenshots_test.dart -d linux --reporter expanded
///
/// Output:
///   Flutter writes PNGs under build/ (location varies slightly by Flutter version),
///   commonly:
///     build/integration_test/screenshots/
///
/// Tip: keep this test deterministic: fixed surface size, avoid "pumpAndSettle" on
/// continuously animating shader scenes.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;

  group('Desktop screenshots', () {
    late PresetStore presetStore;
    late ArQualityStore arQualityStore;

    setUp(() async {
      // Ensure first-run flows don't pollute screenshots.
      SharedPreferences.setMockInitialValues({});
      presetStore = await PresetStore.create();
      arQualityStore = await ArQualityStore.create();

      // Stable screenshot resolution across machines.
      await binding.setSurfaceSize(const Size(1080, 1920));
    });

    tearDown(() async {
      await binding.setSurfaceSize(null);
    });

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        FlutterFractalsApp(
          presetStore: presetStore,
          arQualityStore: arQualityStore,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> snap(WidgetTester tester, String name) async {
      // Give the raster thread a moment.
      await tester.pump(const Duration(milliseconds: 200));

      // Sanitize names so they map cleanly to files on all OSes.
      final safeName = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\-_.]+'), '_')
          .replaceAll(RegExp(r'_+'), '_');

      // On desktop this will write a PNG into build/…
      await binding.takeScreenshot(safeName);

      // Helps when running with --reporter expanded
      // so logs show what was captured.
      // ignore: avoid_print
      print('SCREENSHOT: $safeName');
    }

    testWidgets('01_catalog', (tester) async {
      await pumpApp(tester);
      expect(find.byType(ListTile), findsWidgets);
      await snap(tester, '01_catalog');
    });

    testWidgets('02_viewer_mandelbulb', (tester) async {
      await pumpApp(tester);

      // Tap first module.
      await tester.tap(find.byType(ListTile).first);

      // Shader-driven views may never fully settle; use a fixed delay.
      await tester.pump(const Duration(seconds: 2));

      // Verify we reached viewer.
      expect(find.byIcon(Icons.tune), findsOneWidget);

      // Optional: hide mouse cursor artifacts on some WMs by moving pointer.
      if (!Platform.isWindows) {
        await binding
            .handlePointerEvent(const PointerHoverEvent(position: Offset(5, 5)));
      }

      await snap(tester, '02_viewer_mandelbulb');
    });

    testWidgets('03_viewer_mandelbrot', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byType(ListTile).at(1));
      await tester.pump(const Duration(seconds: 2));
      expect(find.byIcon(Icons.tune), findsOneWidget);
      await snap(tester, '03_viewer_mandelbrot');
    });

    testWidgets('04_viewer_julia', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byType(ListTile).at(2));
      await tester.pump(const Duration(seconds: 2));
      expect(find.byIcon(Icons.tune), findsOneWidget);
      await snap(tester, '04_viewer_julia');
    });

    testWidgets('05_viewer_burning_ship', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byType(ListTile).at(3));
      await tester.pump(const Duration(seconds: 2));
      expect(find.byIcon(Icons.tune), findsOneWidget);
      await snap(tester, '05_viewer_burning_ship');
    });
  });
}
