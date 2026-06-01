import 'dart:math';

import 'package:flutter_fractals/features/renderer/deep_zoom_precision_policy.dart';

/// Auto-zoom configuration.
class AutoExploreConfig {
  /// Minimum and maximum zoom targets for the auto cycle.
  final double minZoom;
  final double maxZoom;

  /// Peak zoom target starts from: baseZoom * [cycleMaxMultiplier], then gets
  /// clamped by smart precision limits per fractal module.
  final double cycleMaxMultiplier;

  /// Maximum zoom span per leg in log10 decades (e.g. 3.0 => up to 1000x).
  final double maxLegSpanDecades;

  /// Precision headroom under policy threshold to avoid probing unstable edges.
  final double precisionHeadroom;

  /// Duration for each zoom leg (in or out).
  final Duration travelDuration;

  /// Maximum multiplier for duration scaling on very large zoom spans.
  final double maxDurationScale;

  const AutoExploreConfig({
    this.minZoom = 0.2,
    this.maxZoom = 1e12,
    this.cycleMaxMultiplier = 120.0,
    this.maxLegSpanDecades = 3.2,
    this.precisionHeadroom = 0.92,
    this.travelDuration = const Duration(milliseconds: 9000),
    this.maxDurationScale = 4.0,
  });
}

/// Pure zoom-planning logic for [AutoExploreService].
///
/// Keeping target selection side-effect free makes the precision assumptions
/// replayable in tests without constructing timers or a renderer controller.
class AutoExploreZoomPlanner {
  final AutoExploreConfig config;
  final DeepZoomPrecisionPolicy precisionPolicy;

  const AutoExploreZoomPlanner({
    required this.config,
    this.precisionPolicy = const DeepZoomPrecisionPolicy(),
  });

  double clampZoom(double zoom) => zoom.clamp(config.minZoom, config.maxZoom);

  double hardMaxZoomFor(String moduleId) {
    final safeThreshold =
        (precisionPolicy.thresholdFor(moduleId) * config.precisionHeadroom)
            .clamp(config.minZoom, config.maxZoom);
    return clampZoom(safeThreshold);
  }

  double computePeakZoom({
    required double baseZoom,
    required String moduleId,
  }) {
    final base = clampZoom(baseZoom);
    final hardMax = hardMaxZoomFor(moduleId);
    final minPeak = clampZoom(base * 1.25);
    final configuredPeak = clampZoom(base * config.cycleMaxMultiplier);

    final maxSpanRatio = pow(10.0, config.maxLegSpanDecades).toDouble();
    final spanLimitedPeak = clampZoom(base * maxSpanRatio);

    final desiredPeak = min(configuredPeak, spanLimitedPeak);
    final unclampedPeak = max(minPeak, min(desiredPeak, hardMax));
    return min(unclampedPeak, hardMax);
  }

  double computeFloorZoom(double baseZoom) {
    final base = clampZoom(baseZoom);
    final contextualFloor = base / config.cycleMaxMultiplier;
    return clampZoom(max(config.minZoom, contextualFloor));
  }

  double nextTargetZoom({
    required double currentZoom,
    required double? cycleBaseZoom,
    required bool zoomingIn,
    required String moduleId,
  }) {
    final current = clampZoom(currentZoom);
    final baseZoom = clampZoom(cycleBaseZoom ?? current);
    final peakZoom = computePeakZoom(baseZoom: baseZoom, moduleId: moduleId);
    final floorZoom = computeFloorZoom(baseZoom);

    if ((peakZoom - floorZoom).abs() < 1e-9) {
      return baseZoom;
    }

    return zoomingIn ? peakZoom : floorZoom;
  }

  Duration durationForZoomLeg({
    required double startZoom,
    required double endZoom,
    required double speed,
  }) {
    final safeStart = max(1e-9, startZoom);
    final safeEnd = max(1e-9, endZoom);
    final ratio = max(safeStart, safeEnd) / min(safeStart, safeEnd);
    final decades = ratio <= 1.0 ? 0.0 : (log(ratio) / ln10);

    final normalized = (decades / 1.6).clamp(0.0, 1.0);
    final scale = 1.0 + normalized * (config.maxDurationScale - 1.0);

    final ms = (config.travelDuration.inMilliseconds * scale).round();
    final scaledMs = (ms / speed).round();
    return Duration(milliseconds: max(1, scaledMs));
  }

  double interpolateZoom(double start, double end, double t) {
    final safeStart = max(1e-9, start);
    final safeEnd = max(1e-9, end);
    return safeStart * pow(safeEnd / safeStart, t).toDouble();
  }
}
