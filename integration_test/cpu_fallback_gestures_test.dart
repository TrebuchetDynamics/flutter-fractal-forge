import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // This test is meant to be run with:
  //   flutter test integration_test/cpu_fallback_gestures_test.dart \
  //     --dart-define=FORCE_CPU_FALLBACK=true
  const bool forceCpuFallback =
      bool.fromEnvironment('FORCE_CPU_FALLBACK', defaultValue: false);

  group('CPU fallback + gestures', () {
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
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
    }

    Finder moduleCards() {
      return find.byWidgetPredicate((w) {
        final k = w.key;
        if (k is! ValueKey) return false;
        final v = k.value;
        return v is String && v.startsWith('catalogModuleCard_');
      });
    }

    testWidgets(
      'forced fallback renders and accepts pan gesture without crashing',
      (tester) async {
        if (!forceCpuFallback) {
          return;
        }

        await pumpApp(tester);

        // Enter a 2D fractal viewer.
        await tester.tap(moduleCards().first);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));

        // Banner indicates CPU fallback is active.
        expect(
          find.text('CPU fallback enabled (GPU shader output appeared black).'),
          findsOneWidget,
        );

        // CPU renderer should be visible.
        final cpu = find.byType(CpuFractalRenderer);
        expect(cpu, findsOneWidget);

        // Pan gesture (one-finger drag).
        await tester.drag(cpu, const Offset(80, 0));
        await tester.pump(const Duration(milliseconds: 300));

        // Still on viewer screen.
        expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      },
      // If you run without FORCE_CPU_FALLBACK, this test becomes a no-op.
      // Keep it in the suite so CI can opt-in.
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
