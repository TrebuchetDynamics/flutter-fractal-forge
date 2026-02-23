import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/services/preset_store.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';
import 'package:flutter_fractals/main.dart';

/// Basic desktop perf smoke test.
///
/// Goal: catch obvious frame-time regressions in the fractal viewer render loop.
/// This is intentionally lightweight (short run, coarse thresholds).
///
/// Run (examples):
///   flutter test integration_test/perf_smoke_test.dart -d linux
///   flutter test integration_test/perf_smoke_test.dart -d macos
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Ensure we collect real frame timings on desktop.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('perf', () {
    testWidgets('fractal viewer frame times stay within a loose budget',
        (tester) async {
      final collector = _FrameTimingCollector();
      collector.start();
      addTearDown(collector.stop);

      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'onboarding_version': OnboardingService.currentVersion,
      });
      final presetStore = await PresetStore.create();
      final arQualityStore = await ArQualityStore.create();
      final accessibilityService = await AccessibilityService.create();
      final rendererSettingsService = await RendererSettingsService.create();

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

      // Open the first module in the catalog (supports grid/list variants).
      await tester.pump(const Duration(milliseconds: 250));
      final firstModuleCard = find.byWidgetPredicate((w) {
        final k = w.key;
        if (k is! ValueKey) return false;
        final v = k.value;
        if (v is! String) return false;
        return v.startsWith('catalogModuleCard_') ||
            v.startsWith('catalogGridTile_');
      }).first;
      expect(firstModuleCard, findsOneWidget);
      await tester.tap(firstModuleCard);
      await tester.pump();

      // Wait for shader load (progress indicator disappears) while continuing
      // to pump, since the renderer animates continuously.
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (DateTime.now().isBefore(deadline) &&
          tester.any(find.byType(CircularProgressIndicator))) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Collect frame timings for a short window.
      collector.clear();
      const sampleWindow = Duration(seconds: 5);
      final end = DateTime.now().add(sampleWindow);
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      final stats = collector.summarize();
      // If we fail to collect enough frames, something is wrong with the test
      // environment or the render loop.
      expect(stats.count, greaterThanOrEqualTo(60), reason: stats.describe());

      // Very loose budgets to avoid flakiness across machines/CI.
      // We look at (build+raster) since that maps to "work per frame".
      expect(stats.p95Ms, lessThan(80), reason: stats.describe());
      expect(stats.meanMs, lessThan(40), reason: stats.describe());
    });
  });
}

class _FrameTimingCollector {
  final List<FrameTiming> _timings = <FrameTiming>[];
  bool _running = false;

  void start() {
    if (_running) return;
    _running = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  void stop() {
    if (!_running) return;
    _running = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
  }

  void clear() => _timings.clear();

  void _onTimings(List<FrameTiming> timings) {
    _timings.addAll(timings);
  }

  _FrameTimingStats summarize() {
    // Use build+raster as a simple proxy for total work.
    final samples = _timings
        .map((t) => t.buildDuration + t.rasterDuration)
        .map((d) => d.inMicroseconds / 1000.0)
        .toList(growable: false);

    if (samples.isEmpty) {
      return const _FrameTimingStats.empty();
    }

    final sorted = [...samples]..sort();
    final mean = samples.reduce((a, b) => a + b) / samples.length;
    final p95 = _percentile(sorted, 0.95);
    final p99 = _percentile(sorted, 0.99);
    final maxV = sorted.last;

    return _FrameTimingStats(
      count: samples.length,
      meanMs: mean,
      p95Ms: p95,
      p99Ms: p99,
      maxMs: maxV,
    );
  }
}

double _percentile(List<double> sorted, double p) {
  if (sorted.isEmpty) return double.nan;
  final clamped = p.clamp(0.0, 1.0);
  final idx = (clamped * (sorted.length - 1));
  final lo = idx.floor();
  final hi = idx.ceil();
  if (lo == hi) return sorted[lo];
  final t = idx - lo;
  return sorted[lo] * (1.0 - t) + sorted[hi] * t;
}

class _FrameTimingStats {
  final int count;
  final double meanMs;
  final double p95Ms;
  final double p99Ms;
  final double maxMs;

  const _FrameTimingStats({
    required this.count,
    required this.meanMs,
    required this.p95Ms,
    required this.p99Ms,
    required this.maxMs,
  });

  const _FrameTimingStats.empty()
      : count = 0,
        meanMs = double.nan,
        p95Ms = double.nan,
        p99Ms = double.nan,
        maxMs = double.nan;

  String describe() {
    if (count == 0) {
      return 'No frame timings collected.';
    }
    String fmt(double v) => v.toStringAsFixed(1);
    return 'Frame timings (build+raster) ms: '
        'n=$count mean=${fmt(meanMs)} p95=${fmt(p95Ms)} p99=${fmt(p99Ms)} max=${fmt(maxMs)}';
  }
}
