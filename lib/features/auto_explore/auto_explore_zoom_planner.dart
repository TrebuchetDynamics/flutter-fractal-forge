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

  static const int sliderDivisions = 25;

  static double normalize(double speed) {
    if (!speed.isFinite) return neutral;
    return speed.clamp(min, max);
  }
}

/// Relative epsilon used to ignore tiny user zoom corrections.
///
/// Values at or above 1.0 invert the lower comparison bound and make zoom-out
/// corrections undetectable. Keep normalization explicit so correction replay
/// tests can distinguish real deadbands from malformed inputs.
class AutoExploreRelativeEpsilon {
  static const double defaultValue = 1e-4;

  const AutoExploreRelativeEpsilon._();

  static double normalize(double epsilon) {
    if (!epsilon.isFinite || epsilon < 0.0 || epsilon >= 1.0) {
      return defaultValue;
    }
    return epsilon;
  }
}

/// Direction inferred from a user zoom correction.
class AutoExploreCorrectionDecision {
  static const double defaultRelativeEpsilon =
      AutoExploreRelativeEpsilon.defaultValue;

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
    if (!_isUsableZoomSample(currentZoom) ||
        !_isUsableZoomSample(previousZoom)) {
      return const AutoExploreCorrectionDecision._(null);
    }

    final epsilon = AutoExploreRelativeEpsilon.normalize(relativeEpsilon);
    if (currentZoom > previousZoom * (1.0 + epsilon)) {
      return const AutoExploreCorrectionDecision._(true);
    }
    if (currentZoom < previousZoom * (1.0 - epsilon)) {
      return const AutoExploreCorrectionDecision._(false);
    }
    return const AutoExploreCorrectionDecision._(null);
  }

  static bool _isUsableZoomSample(double zoom) => zoom.isFinite && zoom > 0.0;
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

/// Converts a zoom span into a normalized duration scale.
///
/// A leg reaches the configured maximum duration scale after this many log10
/// decades. Keeping the threshold named makes the cinematic timing assumption
/// replayable instead of burying `1.6` in duration planning.
class AutoExploreZoomSpanScale {
  static const double maxScaleSpanDecades = 1.6;

  const AutoExploreZoomSpanScale._();

  static double normalized(double spanDecades) {
    if (!spanDecades.isFinite || spanDecades <= 0.0) return 0.0;
    return (spanDecades / maxScaleSpanDecades).clamp(0.0, 1.0);
  }
}

/// Converts zoom-span scaling into a positive, finite leg duration.
///
/// This keeps duration planning replayable even when a finite-but-huge config
/// value overflows during multiplication before [double.round].
class AutoExploreLegDuration {
  // Dart Duration stores microseconds in a signed 64-bit field. Millisecond
  // candidates above this can overflow into negative durations after the
  // milliseconds-to-microseconds conversion.
  static const int _maxSafeDurationMilliseconds = 9223372036854;

  const AutoExploreLegDuration._();

  static int milliseconds({
    required Duration baseDuration,
    required double scale,
    required double speed,
  }) {
    final safeBaseMs = _safeBaseMilliseconds(baseDuration.inMilliseconds);
    if (safeBaseMs <= 0) return 1;

    final scaledMs = _finitePositiveRoundOrFallback(
      safeBaseMs * scale,
      fallback: safeBaseMs,
    );
    return max(
      1,
      _finitePositiveRoundOrFallback(
        scaledMs / AutoExploreSpeed.normalize(speed),
        fallback: safeBaseMs,
      ),
    );
  }

  static int _safeBaseMilliseconds(int baseMs) {
    if (baseMs <= 0) return 1;
    return min(baseMs, _maxSafeDurationMilliseconds);
  }

  static int _finitePositiveRoundOrFallback(
    double value, {
    required int fallback,
  }) {
    if (!value.isFinite ||
        value <= 0.0 ||
        value > _maxSafeDurationMilliseconds) {
      return fallback;
    }
    return value.round();
  }
}

/// Replayable frame timing for one auto-explore zoom animation.
///
/// The service animates with a fixed frame cadence; exposing the sanitized
/// start/end zooms, duration, and frame count keeps timer-driven behavior
/// characterizable without relying on wall-clock order in service tests.
class AutoExploreFrameTiming {
  final Duration duration;
  final Duration frameInterval;

  const AutoExploreFrameTiming({
    required this.duration,
    required this.frameInterval,
  }) : assert(frameInterval > Duration.zero, 'frameInterval must be positive');

  int get totalFrames {
    final frameMicros = frameInterval.inMicroseconds;
    if (frameMicros <= 0) return 1;
    return max(1, (duration.inMicroseconds / frameMicros).round());
  }
}

/// Replayable frame timing and zoom endpoints for one auto-explore animation.
class AutoExploreZoomAnimationPlan {
  static const Duration defaultFrameInterval = Duration(milliseconds: 16);

  final double startZoom;
  final double endZoom;
  final Duration duration;
  final Duration frameInterval;

  const AutoExploreZoomAnimationPlan({
    required this.startZoom,
    required this.endZoom,
    required this.duration,
    this.frameInterval = defaultFrameInterval,
  }) : assert(frameInterval > Duration.zero, 'frameInterval must be positive');

  AutoExploreFrameTiming get frameTiming => AutoExploreFrameTiming(
        duration: duration,
        frameInterval: frameInterval,
      );

  int get totalFrames => frameTiming.totalFrames;

  double interpolate(double t) {
    return AutoExploreZoomInterpolation.interpolate(
      startZoom: startZoom,
      endZoom: endZoom,
      t: t,
    );
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

/// Replayable zoom-span math for positive, finite zoom endpoints.
///
/// Computing the ratio before taking the logarithm can overflow for valid deep
/// zoom bounds (for example `1e308 / 0.2`). Use log-space subtraction so huge
/// but finite legs still scale duration instead of looking like malformed data.
class AutoExploreZoomSpan {
  const AutoExploreZoomSpan._();

  static double decades({
    required double startZoom,
    required double endZoom,
  }) {
    final low = min(startZoom, endZoom);
    final high = max(startZoom, endZoom);
    if (low <= 0.0 || high <= low) return 0.0;

    final span = (log(high) - log(low)) / ln10;
    return span.isFinite && span > 0.0 ? span : 0.0;
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

  double get spanDecades => AutoExploreZoomSpan.decades(
        startZoom: startZoom,
        endZoom: endZoom,
      );

  double interpolate(double t) {
    return AutoExploreZoomInterpolation.interpolate(
      startZoom: startZoom,
      endZoom: endZoom,
      t: t,
    );
  }
}

/// Numerically stable geometric interpolation for positive zoom legs.
class AutoExploreZoomInterpolation {
  const AutoExploreZoomInterpolation._();

  static double interpolate({
    required double startZoom,
    required double endZoom,
    required double t,
  }) {
    final progress = t.isNaN ? 0.0 : t.clamp(0.0, 1.0);
    if (progress <= 0.0) return startZoom;
    if (progress >= 1.0) return endZoom;

    final interpolated = exp(
      log(startZoom) + (log(endZoom) - log(startZoom)) * progress,
    );
    if (interpolated.isFinite) return interpolated;
    return progress < 0.5 ? startZoom : endZoom;
  }
}

/// Replayable peak candidate data for one auto-explore cycle step.
class AutoExplorePeakZoomCandidates {
  final double baseZoom;
  final double minProgressZoom;
  final double configuredPeakZoom;
  final double spanLimitedPeakZoom;
  final double hardMaxZoom;

  const AutoExplorePeakZoomCandidates({
    required this.baseZoom,
    required this.minProgressZoom,
    required this.configuredPeakZoom,
    required this.spanLimitedPeakZoom,
    required this.hardMaxZoom,
  });

  double get desiredPeakZoom => min(configuredPeakZoom, spanLimitedPeakZoom);

  /// The 1.25x progress nudge is a preference, not permission to violate the
  /// configured per-leg span cap or module precision hard maximum.
  double get cappedMinimumProgressZoom => min(minProgressZoom, desiredPeakZoom);

  double get resolvedPeakZoom => min(
        max(cappedMinimumProgressZoom, min(desiredPeakZoom, hardMaxZoom)),
        hardMaxZoom,
      );
}

/// Replayable target range for one auto-explore cycle step.
class AutoExploreZoomTargetRange {
  static const double collapseEpsilon = 1e-9;

  final double peakZoom;
  final double floorZoom;

  const AutoExploreZoomTargetRange({
    required this.peakZoom,
    required this.floorZoom,
  }) : assert(floorZoom <= peakZoom, 'floorZoom must not exceed peakZoom');

  /// Builds a target range that stays ordered after precision caps are applied.
  ///
  /// The floor candidate is derived from the cycle base, while the peak can be
  /// lowered by a module precision hard max. Without this normalization a base
  /// above the hard max makes zoom-in target a lower value than zoom-out.
  factory AutoExploreZoomTargetRange.fromCandidates({
    required double peakZoom,
    required double floorZoom,
  }) {
    return AutoExploreZoomTargetRange(
      peakZoom: peakZoom,
      floorZoom: min(floorZoom, peakZoom),
    );
  }

  bool get isCollapsed => (peakZoom - floorZoom).abs() < collapseEpsilon;

  double targetZoom({required bool zoomingIn}) {
    if (isCollapsed) {
      // Collapsed plans must remain inside the resolved target range. Returning
      // the cycle base can bypass a precision hard-max when floor and peak both
      // collapse below the current/base zoom.
      return min(peakZoom, floorZoom);
    }
    return zoomingIn ? peakZoom : floorZoom;
  }
}

/// Sanitized inputs used for one replayable auto-explore target decision.
///
/// This exposes the hidden fallback order used by the service: current zoom is
/// sanitized first, then a missing cycle base adopts that sanitized current
/// value. A malformed non-null cycle base is still sanitized independently.
class AutoExploreZoomPlanInputs {
  final double currentZoom;
  final double baseZoom;

  const AutoExploreZoomPlanInputs({
    required this.currentZoom,
    required this.baseZoom,
  });

  factory AutoExploreZoomPlanInputs.fromBounds({
    required AutoExploreZoomBounds bounds,
    required double currentZoom,
    required double? cycleBaseZoom,
  }) {
    final current = bounds.clamp(currentZoom);
    return AutoExploreZoomPlanInputs(
      currentZoom: current,
      baseZoom: bounds.clamp(cycleBaseZoom ?? current),
    );
  }
}

/// Replayable target-selection data for one auto-explore cycle step.
class AutoExploreZoomTargetPlan {
  final AutoExploreZoomPlanInputs inputs;
  final AutoExplorePeakZoomCandidates peakCandidates;
  final double peakZoom;
  final double floorZoom;
  final bool zoomingIn;

  const AutoExploreZoomTargetPlan({
    required this.inputs,
    required this.peakCandidates,
    required this.peakZoom,
    required this.floorZoom,
    required this.zoomingIn,
  }) : assert(floorZoom <= peakZoom, 'floorZoom must not exceed peakZoom');

  double get currentZoom => inputs.currentZoom;
  double get baseZoom => inputs.baseZoom;

  AutoExploreZoomTargetRange get targetRange =>
      AutoExploreZoomTargetRange.fromCandidates(
        peakZoom: peakZoom,
        floorZoom: floorZoom,
      );

  bool get isCollapsed => targetRange.isCollapsed;

  bool get respectsPrecisionHardMax => peakZoom <= peakCandidates.hardMaxZoom;

  double get targetZoom => targetRange.targetZoom(zoomingIn: zoomingIn);
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

  AutoExplorePeakZoomCandidates peakZoomCandidates({
    required double baseZoom,
    required String moduleId,
  }) {
    final base = clampZoom(baseZoom);
    final hardMax = hardMaxZoomFor(moduleId);
    final cycleShape = _cycleShape;
    final maxSpanRatio = pow(10.0, cycleShape.maxLegSpanDecades).toDouble();

    return AutoExplorePeakZoomCandidates(
      baseZoom: base,
      minProgressZoom: clampZoom(base * 1.25),
      configuredPeakZoom: clampZoom(base * cycleShape.cycleMaxMultiplier),
      spanLimitedPeakZoom: clampZoom(base * maxSpanRatio),
      hardMaxZoom: hardMax,
    );
  }

  double computePeakZoom({
    required double baseZoom,
    required String moduleId,
  }) {
    return peakZoomCandidates(
      baseZoom: baseZoom,
      moduleId: moduleId,
    ).resolvedPeakZoom;
  }

  double computeFloorZoom(double baseZoom) {
    final bounds = _bounds;
    final base = bounds.clamp(baseZoom);
    final contextualFloor = base / _cycleShape.cycleMaxMultiplier;
    return bounds.clamp(max(bounds.minZoom, contextualFloor));
  }

  AutoExploreZoomPlanInputs planInputs({
    required double currentZoom,
    required double? cycleBaseZoom,
  }) {
    return AutoExploreZoomPlanInputs.fromBounds(
      bounds: _bounds,
      currentZoom: currentZoom,
      cycleBaseZoom: cycleBaseZoom,
    );
  }

  AutoExploreZoomTargetPlan planNextTarget({
    required double currentZoom,
    required double? cycleBaseZoom,
    required bool zoomingIn,
    required String moduleId,
  }) {
    final inputs = planInputs(
      currentZoom: currentZoom,
      cycleBaseZoom: cycleBaseZoom,
    );
    final peakCandidates = peakZoomCandidates(
      baseZoom: inputs.baseZoom,
      moduleId: moduleId,
    );
    final targetRange = AutoExploreZoomTargetRange.fromCandidates(
      peakZoom: peakCandidates.resolvedPeakZoom,
      floorZoom: computeFloorZoom(inputs.baseZoom),
    );

    return AutoExploreZoomTargetPlan(
      inputs: inputs,
      peakCandidates: peakCandidates,
      peakZoom: targetRange.peakZoom,
      floorZoom: targetRange.floorZoom,
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

  AutoExploreZoomAnimationPlan animationPlanForZoomLeg({
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
    final normalized = AutoExploreZoomSpanScale.normalized(leg.spanDecades);
    final scale = 1.0 + normalized * (durationScale - 1.0);

    return AutoExploreZoomAnimationPlan(
      startZoom: leg.startZoom,
      endZoom: leg.endZoom,
      duration: Duration(
        milliseconds: AutoExploreLegDuration.milliseconds(
          baseDuration: config.travelDuration,
          scale: scale,
          speed: effectiveSpeed,
        ),
      ),
    );
  }

  Duration durationForZoomLeg({
    required double startZoom,
    required double endZoom,
    required double speed,
  }) {
    return animationPlanForZoomLeg(
      startZoom: startZoom,
      endZoom: endZoom,
      speed: speed,
    ).duration;
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
