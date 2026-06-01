import 'dart:math';

import 'package:flutter_fractals/features/renderer/deep_zoom_precision_policy.dart';

/// Auto-zoom configuration.
class AutoExploreConfig {
  static const double defaultMinZoom = 0.2;
  static const double defaultMaxZoom = 1e12;

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
    this.minZoom = defaultMinZoom,
    this.maxZoom = defaultMaxZoom,
    this.cycleMaxMultiplier = 120.0,
    this.maxLegSpanDecades = 3.2,
    this.precisionHeadroom = 0.92,
    this.travelDuration = const Duration(milliseconds: 9000),
    this.maxDurationScale = 4.0,
  });
}

/// Speed bounds used by auto-explore playback.
///
/// Dart's [double.clamp] treats NaN as the upper bound. For playback speed,
/// invalid telemetry or UI state should fall back to neutral 1.0x instead of
/// silently selecting the fastest supported speed.
class AutoExploreSpeed {
  static const double min = 0.5;
  static const double neutral = 1.0;
  static const double max = 3.0;

  const AutoExploreSpeed._();

  static double normalize(double speed) {
    if (speed.isNaN) return neutral;
    return speed.clamp(min, max);
  }
}

/// Precision headroom used to keep auto-explore below renderer fallback edges.
///
/// Values above 1.0 would push candidates past the module precision threshold;
/// non-finite values must not rely on [double.clamp] because NaN clamps to the
/// upper bound and would silently promote targets to max zoom.
class AutoExplorePrecisionHeadroom {
  static const double neutral = 1.0;

  const AutoExplorePrecisionHeadroom._();

  static double normalize(double headroom) {
    if (!headroom.isFinite || headroom <= 0.0) return neutral;
    return headroom.clamp(0.0, neutral);
  }
}

/// Zoom bounds used by auto-explore planning.
///
/// Dart's [double.clamp] treats NaN as the upper bound, which would turn a
/// corrupted/uninitialized zoom reading into an extreme deep-zoom target.
/// Keep sanitization explicit so candidate planning remains replayable.
class AutoExploreZoomBounds {
  final double minZoom;
  final double maxZoom;

  const AutoExploreZoomBounds({
    required this.minZoom,
    required this.maxZoom,
  });

  factory AutoExploreZoomBounds.fromConfig(AutoExploreConfig config) {
    final configuredMin = _positiveFiniteOrDefault(
      config.minZoom,
      AutoExploreConfig.defaultMinZoom,
    );
    final configuredMax = _positiveFiniteOrDefault(
      config.maxZoom,
      AutoExploreConfig.defaultMaxZoom,
    );

    return AutoExploreZoomBounds(
      minZoom: min(configuredMin, configuredMax),
      maxZoom: max(configuredMin, configuredMax),
    );
  }

  static double _positiveFiniteOrDefault(double value, double fallback) {
    return value.isFinite && value > 0.0 ? value : fallback;
  }

  double clamp(double zoom) {
    if (zoom.isNaN) return minZoom;
    return zoom.clamp(minZoom, maxZoom);
  }
}

/// Sanitized zoom leg used for replayable duration/interpolation math.
class AutoExploreZoomLeg {
  final double startZoom;
  final double endZoom;

  const AutoExploreZoomLeg({
    required this.startZoom,
    required this.endZoom,
  });

  factory AutoExploreZoomLeg.fromBounds({
    required AutoExploreZoomBounds bounds,
    required double startZoom,
    required double endZoom,
  }) {
    return AutoExploreZoomLeg(
      startZoom: bounds.clamp(startZoom),
      endZoom: bounds.clamp(endZoom),
    );
  }

  double get spanDecades {
    final ratio = max(startZoom, endZoom) / min(startZoom, endZoom);
    return ratio <= 1.0 ? 0.0 : (log(ratio) / ln10);
  }

  double interpolate(double t) {
    final progress = t.isNaN ? 0.0 : t.clamp(0.0, 1.0);
    return startZoom * pow(endZoom / startZoom, progress).toDouble();
  }
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

  AutoExploreZoomBounds get _bounds => AutoExploreZoomBounds.fromConfig(config);

  double clampZoom(double zoom) => _bounds.clamp(zoom);

  double hardMaxZoomFor(String moduleId) {
    final headroom = AutoExplorePrecisionHeadroom.normalize(
      config.precisionHeadroom,
    );
    final safeThreshold = precisionPolicy.thresholdFor(moduleId) * headroom;
    return _bounds.clamp(safeThreshold);
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
    final bounds = _bounds;
    final base = bounds.clamp(baseZoom);
    final contextualFloor = base / config.cycleMaxMultiplier;
    return bounds.clamp(max(bounds.minZoom, contextualFloor));
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
    final leg = AutoExploreZoomLeg.fromBounds(
      bounds: _bounds,
      startZoom: startZoom,
      endZoom: endZoom,
    );
    final effectiveSpeed = _effectiveSpeed(speed);

    final normalized = (leg.spanDecades / 1.6).clamp(0.0, 1.0);
    final scale = 1.0 + normalized * (config.maxDurationScale - 1.0);

    final ms = (config.travelDuration.inMilliseconds * scale).round();
    final scaledMs = (ms / effectiveSpeed).round();
    return Duration(milliseconds: max(1, scaledMs));
  }

  double _effectiveSpeed(double speed) => AutoExploreSpeed.normalize(speed);

  double interpolateZoom(double start, double end, double t) {
    final leg = AutoExploreZoomLeg.fromBounds(
      bounds: _bounds,
      startZoom: start,
      endZoom: end,
    );
    return leg.interpolate(t);
  }
}
