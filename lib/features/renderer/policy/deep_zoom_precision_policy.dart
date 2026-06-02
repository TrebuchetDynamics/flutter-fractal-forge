import 'dart:math' as math;

import 'package:flutter/foundation.dart';

const double _mandelbrotDf2LowerThreshold = 5e6;
const double _mandelbrotDf2UpperThreshold = 1e12;
const double _escapeTimeCpuFallbackThreshold = 1e9;
const double _defaultCpuFallbackThreshold = 1e7;

/// Describes the precision boundaries for one fractal module.
@immutable
class DeepZoomThresholds {
  final double cpuFallbackZoom;
  final double? doubleFloatLowerZoom;
  final double? doubleFloatUpperZoom;

  const DeepZoomThresholds({
    required this.cpuFallbackZoom,
    this.doubleFloatLowerZoom,
    this.doubleFloatUpperZoom,
  })  : assert(
          (doubleFloatLowerZoom == null) == (doubleFloatUpperZoom == null),
          'double-float ranges must provide both lower and upper bounds',
        ),
        assert(
          (doubleFloatLowerZoom ?? double.negativeInfinity) <
              (doubleFloatUpperZoom ?? double.infinity),
          'double-float lower bound must be below upper bound',
        ),
        assert(
          (doubleFloatUpperZoom ?? double.negativeInfinity) <= cpuFallbackZoom,
          'double-float range must end no later than CPU fallback',
        );

  bool get supportsDoubleFloat => doubleFloatLowerZoom != null;

  bool shouldUseCpuFallback(double zoom) => zoom >= cpuFallbackZoom;

  bool shouldUseDoubleFloat(double zoom) {
    final lower = doubleFloatLowerZoom;
    final upper = doubleFloatUpperZoom;
    if (lower == null || upper == null) return false;
    return zoom >= lower && zoom < upper;
  }
}

/// Replayable precision routing decision for a module/zoom sample.
///
/// Renderer code needs CPU fallback and double-float eligibility to agree on
/// the same threshold snapshot. Keeping both booleans with their source
/// thresholds exposes that data-flow instead of recomputing partial decisions
/// at separate call sites.
@immutable
class DeepZoomPrecisionDecision {
  final String moduleId;
  final double zoom;
  final DeepZoomThresholds thresholds;

  const DeepZoomPrecisionDecision({
    required this.moduleId,
    required this.zoom,
    required this.thresholds,
  });

  bool get shouldUseCpuFallback => thresholds.shouldUseCpuFallback(zoom);
  bool get shouldUseDoubleFloat => thresholds.shouldUseDoubleFloat(zoom);
  double get cpuFallbackZoom => thresholds.cpuFallbackZoom;
}

/// Decides when GPU precision is likely insufficient at deep zoom.
///
/// ## Float32 precision analysis
///
/// GPU fragment shaders use float32 arithmetic (~7 significant digits,
/// mantissa ≈ 2^-24 ≈ 6e-8).
///
/// The coordinate span per pixel is: span_per_px = fractal_range / (zoom * resolution)
///   For a 1080p display and a fractal range of ~3 units:
///     span_per_px = 3 / (zoom * 1920) ≈ 1.6e-3 / zoom
///
/// Float32 artifacts appear when the per-pixel span drops below the
/// representable precision at the current center offset. In the worst case
/// (center near origin, no cancellation) this is roughly:
///     artifact threshold zoom ≈ 1.6e-3 / 6e-8 ≈ 2.7e4  ... but only at
///     an offset of ~1.0 unit from origin. Deep in the Mandelbrot boundary
///     where |c| ≈ 2, precision is consumed faster (≈ 1e4–1e5).
///     With the standard center at (0,0) or a well-normalized fractal,
///     artifacts are not visible until zoom ≈ 1e6–1e8.
///
/// Our shaders perform double-width emulation via paired float32 values
/// (see shader uniform layout) for a subset of fractals, extending usable
/// GPU range to ~1e12 before requiring CPU.
///
/// ## Conservative threshold policy
///
/// These thresholds are intentionally HIGH so GPU is used as long as
/// possible. The CPU fallback is a correctness escape hatch, not a
/// performance choice — it is significantly slower and disables GPU effects.
///
/// Raise these thresholds if you observe visible precision artifacts before
/// the switch; lower them only if tested on a low-DPI device where artifacts
/// appear earlier.
@immutable
class DeepZoomPrecisionPolicy {
  /// Maximum iterations we send to GPU shaders for real-time rendering.
  ///
  /// Most escape-time shaders clamp around this value already; keeping the
  /// cap centralized avoids overdriving slower devices at extreme zoom.
  static const int gpuMaxIterations = 2000;

  /// Per-module GPU→CPU fallback thresholds.
  ///
  /// For mandelbrot, the CPU fallback threshold is pushed to the df2 upper
  /// bound because the double-float shader [mandelbrot_df2.frag] covers the
  /// intermediate zoom range before CPU fallback.
  ///
  /// Other escape-time fractals still use float32 GPU up to their threshold,
  /// then fall back to CPU (no df2 variant available yet).
  static const Map<String, DeepZoomThresholds> _moduleThresholds = {
    // Mandelbrot: df2 shader covers zoom [5e6, 1e12), so CPU fallback only
    // kicks in at 1e12 (the df2 upper bound).
    'mandelbrot': DeepZoomThresholds(
      cpuFallbackZoom: _mandelbrotDf2UpperThreshold,
      doubleFloatLowerZoom: _mandelbrotDf2LowerThreshold,
      doubleFloatUpperZoom: _mandelbrotDf2UpperThreshold,
    ),
    // Julia & related escape-time fractals: GPU precision degrades sooner,
    // so switch to CPU around ~1e9.
    'julia': DeepZoomThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'celtic': DeepZoomThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'buffalo': DeepZoomThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'burning_ship': DeepZoomThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'tricorn': DeepZoomThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'multibrot3': DeepZoomThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'multibrot4': DeepZoomThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'multibrot5': DeepZoomThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
    'phoenix': DeepZoomThresholds(
      cpuFallbackZoom: _escapeTimeCpuFallbackThreshold,
    ),
  };

  /// Default threshold for any fractal type not listed above.
  /// Simple orbit fractals and non-escape-time types lose precision more
  /// slowly; 1e7 is a conservative upper bound for float32 at 1080p.
  static const DeepZoomThresholds _defaultThresholds = DeepZoomThresholds(
    cpuFallbackZoom: _defaultCpuFallbackThreshold,
  );

  /// Number of consecutive evaluations above the zoom threshold required
  /// before committing to CPU fallback. Prevents rapid GPU↔CPU flicker
  /// when zooming near the boundary.
  static const int _hysteresisFrames = 2;

  const DeepZoomPrecisionPolicy();

  /// Returns true when GPU precision is insufficient at the given zoom.
  ///
  /// Pure, stateless evaluation — callers that want hysteresis should
  /// use [DeepZoomHysteresis] to track frame counts.
  bool shouldUseCpuFallback({
    required String moduleId,
    required double zoom,
  }) {
    return decisionFor(moduleId: moduleId, zoom: zoom).shouldUseCpuFallback;
  }

  DeepZoomThresholds thresholdsFor(String moduleId) =>
      _moduleThresholds[moduleId] ?? _defaultThresholds;

  DeepZoomPrecisionDecision decisionFor({
    required String moduleId,
    required double zoom,
  }) {
    return DeepZoomPrecisionDecision(
      moduleId: moduleId,
      zoom: zoom,
      thresholds: thresholdsFor(moduleId),
    );
  }

  double thresholdFor(String moduleId) =>
      thresholdsFor(moduleId).cpuFallbackZoom;

  /// Returns true when the double-float shader should be used for [moduleId].
  ///
  /// Currently only mandelbrot has a df2 variant. The range is exclusive of
  /// the CPU fallback threshold.
  bool shouldUseDoubleFloat({
    required String moduleId,
    required double zoom,
  }) {
    return decisionFor(moduleId: moduleId, zoom: zoom).shouldUseDoubleFloat;
  }

  int get hysteresisFrames => _hysteresisFrames;

  /// Auto-scales iteration count with zoom depth for GPU rendering.
  ///
  /// Keeps shallow zoom responsive while increasing detail as zoom grows,
  /// reducing under-iteration artifacts in deep zoom.
  ///
  /// Scaling curve:
  /// - zoom <= 1: unchanged
  /// - zoom > 1: base * (1 + 0.35 * log10(zoom))
  /// - clamped to [4, gpuMaxIterations]
  int scaledGpuIterations({
    required int baseIterations,
    required double zoom,
  }) {
    final safeBase = baseIterations.clamp(4, gpuMaxIterations);
    final depth = _zoomDepthLog10(zoom);
    if (depth == 0.0) return safeBase;

    final factor = 1.0 + 0.35 * depth;
    final scaled = (safeBase * factor).round();
    return scaled.clamp(4, gpuMaxIterations);
  }
}

double _zoomDepthLog10(double zoom) {
  if (zoom.isNaN || zoom <= 1.0) return 0.0;
  if (zoom.isInfinite) return 30.0;
  return (math.log(zoom) / math.ln10).clamp(0.0, 30.0);
}

/// Replayable state for one GPU→CPU deep-zoom hysteresis streak.
///
/// Keeping the transition pure makes the hidden state/order dependence visible:
/// streaks are scoped to one module, below-threshold samples reset immediately,
/// and CPU fallback activates only after enough consecutive above-threshold
/// samples for the same module.
@immutable
class DeepZoomHysteresisState {
  final String? moduleId;
  final int aboveThresholdCount;
  final bool cpuActive;

  const DeepZoomHysteresisState({
    required this.moduleId,
    required this.aboveThresholdCount,
    required this.cpuActive,
  });

  const DeepZoomHysteresisState.initial()
      : moduleId = null,
        aboveThresholdCount = 0,
        cpuActive = false;

  DeepZoomHysteresisState next({
    required String nextModuleId,
    required bool overThreshold,
    required int activationFrames,
  }) {
    assert(activationFrames > 0, 'activationFrames must be positive');
    final sameModule = moduleId == nextModuleId;
    final currentCount = sameModule ? aboveThresholdCount : 0;

    if (!overThreshold) {
      return DeepZoomHysteresisState(
        moduleId: nextModuleId,
        aboveThresholdCount: 0,
        cpuActive: false,
      );
    }

    final nextCount = currentCount + 1;
    return DeepZoomHysteresisState(
      moduleId: nextModuleId,
      aboveThresholdCount: nextCount,
      cpuActive: nextCount >= activationFrames,
    );
  }
}

/// Stateful hysteresis filter for GPU→CPU deep-zoom transitions.
///
/// Wraps [DeepZoomPrecisionPolicy] and requires [policy.hysteresisFrames]
/// consecutive above-threshold evaluations before reporting CPU needed.
/// Drops back to GPU immediately when zoom falls below threshold.
class DeepZoomHysteresis {
  final DeepZoomPrecisionPolicy policy;
  DeepZoomHysteresisState _state = const DeepZoomHysteresisState.initial();

  DeepZoomHysteresis({this.policy = const DeepZoomPrecisionPolicy()});

  DeepZoomHysteresisState get state => _state;

  /// Call this on every zoom change. Returns true if CPU fallback is warranted.
  bool update({required String moduleId, required double zoom}) {
    final overThreshold = policy.shouldUseCpuFallback(
      moduleId: moduleId,
      zoom: zoom,
    );

    _state = _state.next(
      nextModuleId: moduleId,
      overThreshold: overThreshold,
      activationFrames: policy.hysteresisFrames,
    );
    return _state.cpuActive;
  }

  void reset() {
    _state = const DeepZoomHysteresisState.initial();
  }
}
