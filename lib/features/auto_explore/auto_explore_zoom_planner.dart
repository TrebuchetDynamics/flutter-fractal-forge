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

/// Direction inferred from a user zoom correction.
class AutoExploreCorrectionDecision {
  static const double defaultRelativeEpsilon = 1e-4;

  /// Null means the correction is inside the deadband and should preserve the
  /// current auto-explore direction.
  final bool? zoomingInOverride;

  const AutoExploreCorrectionDecision._(this.zoomingInOverride);

  bool get changedDirection => zoomingInOverride != null;

  bool resolve({required bool currentZoomingIn}) =>
      zoomingInOverride ?? currentZoomingIn;

  factory AutoExploreCorrectionDecision.fromZooms({
    required double currentZoom,
    required double previousZoom,
    double relativeEpsilon = defaultRelativeEpsilon,
  }) {
    final epsilon = relativeEpsilon.isFinite && relativeEpsilon >= 0.0
        ? relativeEpsilon
        : defaultRelativeEpsilon;
    if (currentZoom > previousZoom * (1.0 + epsilon)) {
      return const AutoExploreCorrectionDecision._(true);
    }
    if (currentZoom < previousZoom * (1.0 - epsilon)) {
      return const AutoExploreCorrectionDecision._(false);
    }
    return const AutoExploreCorrectionDecision._(null);
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

/// Cycle shape used by auto-explore target planning.
///
/// Invalid multipliers or span limits can otherwise turn zoom-out floors into
/// max zooms or collapse peak candidates into NaN/minimum zooms. Keeping the
/// cycle shape explicit makes candidate planning replayable from config alone.
class AutoExploreCycleShape {
  final double cycleMaxMultiplier;
  final double maxLegSpanDecades;

  const AutoExploreCycleShape({
    required this.cycleMaxMultiplier,
    required this.maxLegSpanDecades,
  });

  factory AutoExploreCycleShape.fromConfig(AutoExploreConfig config) {
    return AutoExploreCycleShape(
      cycleMaxMultiplier: _finiteAboveNeutralOrDefault(
        config.cycleMaxMultiplier,
        const AutoExploreConfig().cycleMaxMultiplier,
      ),
      maxLegSpanDecades: _finiteNonNegativeOrDefault(
        config.maxLegSpanDecades,
        const AutoExploreConfig().maxLegSpanDecades,
      ),
    );
  }

  static double _finiteAboveNeutralOrDefault(double value, double fallback) {
    return value.isFinite && value > 1.0 ? value : fallback;
  }

  static double _finiteNonNegativeOrDefault(double value, double fallback) {
    return value.isFinite && value >= 0.0 ? value : fallback;
  }
}

/// Duration scaling used by auto-explore zoom legs.
///
/// Invalid scale factors can otherwise flow into [double.round], where NaN or
/// infinity throws instead of producing a replayable fallback duration.
class AutoExploreDurationScale {
  static const double neutral = 1.0;

  const AutoExploreDurationScale._();

  static double normalize(double scale) {
    if (!scale.isFinite || scale < neutral) return neutral;
    return scale;
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

/// Replayable target-selection data for one auto-explore cycle step.
class AutoExploreZoomTargetPlan {
  static const double collapseEpsilon = 1e-9;

  final double currentZoom;
  final double baseZoom;
  final double peakZoom;
  final double floorZoom;
  final bool zoomingIn;

  const AutoExploreZoomTargetPlan({
    required this.currentZoom,
    required this.baseZoom,
    required this.peakZoom,
    required this.floorZoom,
    required this.zoomingIn,
  });

  bool get isCollapsed => (peakZoom - floorZoom).abs() < collapseEpsilon;

  double get targetZoom => isCollapsed
      ? baseZoom
      : zoomingIn
          ? peakZoom
          : floorZoom;
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
  AutoExploreCycleShape get _cycleShape =>
      AutoExploreCycleShape.fromConfig(config);

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
    final cycleShape = _cycleShape;
    final configuredPeak = clampZoom(base * cycleShape.cycleMaxMultiplier);

    final maxSpanRatio = pow(10.0, cycleShape.maxLegSpanDecades).toDouble();
    final spanLimitedPeak = clampZoom(base * maxSpanRatio);

    final desiredPeak = min(configuredPeak, spanLimitedPeak);
    final unclampedPeak = max(minPeak, min(desiredPeak, hardMax));
    return min(unclampedPeak, hardMax);
  }

  double computeFloorZoom(double baseZoom) {
    final bounds = _bounds;
    final base = bounds.clamp(baseZoom);
    final contextualFloor = base / _cycleShape.cycleMaxMultiplier;
    return bounds.clamp(max(bounds.minZoom, contextualFloor));
  }

  AutoExploreZoomTargetPlan planNextTarget({
    required double currentZoom,
    required double? cycleBaseZoom,
    required bool zoomingIn,
    required String moduleId,
  }) {
    final current = clampZoom(currentZoom);
    final baseZoom = clampZoom(cycleBaseZoom ?? current);
    return AutoExploreZoomTargetPlan(
      currentZoom: current,
      baseZoom: baseZoom,
      peakZoom: computePeakZoom(baseZoom: baseZoom, moduleId: moduleId),
      floorZoom: computeFloorZoom(baseZoom),
      zoomingIn: zoomingIn,
    );
  }

  double nextTargetZoom({
    required double currentZoom,
    required double? cycleBaseZoom,
    required bool zoomingIn,
    required String moduleId,
  }) {
    return planNextTarget(
      currentZoom: currentZoom,
      cycleBaseZoom: cycleBaseZoom,
      zoomingIn: zoomingIn,
      moduleId: moduleId,
    ).targetZoom;
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

    final durationScale = AutoExploreDurationScale.normalize(
      config.maxDurationScale,
    );
    final normalized = (leg.spanDecades / 1.6).clamp(0.0, 1.0);
    final scale = 1.0 + normalized * (durationScale - 1.0);

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
