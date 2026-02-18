import 'package:flutter/foundation.dart';

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
  /// Per-module GPU→CPU fallback thresholds.
  ///
  /// For mandelbrot, the CPU fallback threshold is pushed to [_df2UpperThreshold]
  /// (1e14) because the double-float shader [mandelbrot_df2.frag] covers the
  /// intermediate zoom range [_df2LowerThreshold, _df2UpperThreshold].
  ///
  /// Other escape-time fractals still use float32 GPU up to their threshold,
  /// then fall back to CPU (no df2 variant available yet).
  static const Map<String, double> _cpuFallbackZoomThresholds = {
    // Mandelbrot: df2 shader covers zoom [5e6, 1e14), so CPU fallback only
    // kicks in above 1e14 (the df2 upper bound).
    'mandelbrot': 1e14,
    'julia': 5e6,
    'celtic': 5e6,
    'buffalo': 5e6,
    'burning_ship': 5e6,
    'tricorn': 5e6,
    'multibrot3': 5e6,
    'phoenix': 5e6,
  };

  /// Default threshold for any fractal type not listed above.
  /// Simple orbit fractals and non-escape-time types lose precision more
  /// slowly; 1e8 is a safe upper bound for float32 at 1080p.
  static const double _defaultThreshold = 1e8;

  /// Zoom range where the double-float (DS) shader [mandelbrot_df2.frag]
  /// should be used instead of the standard float32 shader.
  ///
  /// Below [_df2LowerThreshold]: standard float32 GPU shader is fine.
  /// Between [_df2LowerThreshold] and [_df2UpperThreshold]: DS shader.
  /// Above [_df2UpperThreshold]: CPU fallback required.
  static const double _df2LowerThreshold = 5e6;
  static const double _df2UpperThreshold = 1e14;

  /// Number of consecutive evaluations above the zoom threshold required
  /// before committing to CPU fallback. Prevents rapid GPU↔CPU flicker
  /// when zooming near the boundary.
  static const int _hysteresisFrames = 6;

  const DeepZoomPrecisionPolicy();

  /// Returns true when GPU precision is insufficient at the given zoom.
  ///
  /// Pure, stateless evaluation — callers that want hysteresis should
  /// use [DeepZoomHysteresis] to track frame counts.
  bool shouldUseCpuFallback({
    required String moduleId,
    required double zoom,
  }) {
    final threshold =
        _cpuFallbackZoomThresholds[moduleId] ?? _defaultThreshold;
    return zoom >= threshold;
  }

  double thresholdFor(String moduleId) =>
      _cpuFallbackZoomThresholds[moduleId] ?? _defaultThreshold;

  /// Returns true when the double-float shader should be used for [moduleId].
  ///
  /// Currently only mandelbrot has a df2 variant. The range is
  /// [_df2LowerThreshold, _df2UpperThreshold] exclusive.
  bool shouldUseDoubleFloat({
    required String moduleId,
    required double zoom,
  }) {
    if (moduleId != 'mandelbrot') return false;
    return zoom >= _df2LowerThreshold && zoom < _df2UpperThreshold;
  }

  int get hysteresisFrames => _hysteresisFrames;
}

/// Stateful hysteresis filter for GPU→CPU deep-zoom transitions.
///
/// Wraps [DeepZoomPrecisionPolicy] and requires [policy.hysteresisFrames]
/// consecutive above-threshold evaluations before reporting CPU needed.
/// Drops back to GPU immediately when zoom falls below threshold.
class DeepZoomHysteresis {
  final DeepZoomPrecisionPolicy policy;
  int _aboveThresholdCount = 0;
  bool _cpuActive = false;

  DeepZoomHysteresis({this.policy = const DeepZoomPrecisionPolicy()});

  /// Call this on every zoom change. Returns true if CPU fallback is warranted.
  bool update({required String moduleId, required double zoom}) {
    final overThreshold = policy.shouldUseCpuFallback(
      moduleId: moduleId,
      zoom: zoom,
    );

    if (overThreshold) {
      _aboveThresholdCount++;
      if (_aboveThresholdCount >= policy.hysteresisFrames) {
        _cpuActive = true;
      }
    } else {
      // Immediately drop back to GPU on zoom-out — no delay needed.
      _aboveThresholdCount = 0;
      _cpuActive = false;
    }

    return _cpuActive;
  }

  void reset() {
    _aboveThresholdCount = 0;
    _cpuActive = false;
  }
}
