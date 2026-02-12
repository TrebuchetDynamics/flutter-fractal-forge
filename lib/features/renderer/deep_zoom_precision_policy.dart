import 'package:flutter/foundation.dart';

/// Decides when GPU precision is likely insufficient at deep zoom.
///
/// Thresholds are per-fractal and intentionally conservative to avoid
/// unnecessary CPU fallback in normal exploration.
@immutable
class DeepZoomPrecisionPolicy {
  /// GPU float32 has ~7 significant digits of precision.
  /// Pixel-level artifacts appear when zoom causes the coordinate range
  /// per pixel to drop below ~1e-7.  For a 1080p display that's roughly
  /// zoom ≈ 1e5–1e6 depending on the fractal's center offset.
  ///
  /// We set thresholds conservatively HIGH so GPU is used as long as
  /// possible.  Only switch to CPU when artifacts are clearly visible.
  static const Map<String, double> _cpuFallbackZoomThresholds = {
    'mandelbrot': 1e6,
    'julia': 5e5,
    'celtic': 5e5,
    'buffalo': 5e5,
  };

  const DeepZoomPrecisionPolicy();

  bool shouldUseCpuFallback({
    required String moduleId,
    required double zoom,
  }) {
    final threshold = _cpuFallbackZoomThresholds[moduleId];
    if (threshold == null) {
      return false;
    }
    return zoom >= threshold;
  }

  double? thresholdFor(String moduleId) => _cpuFallbackZoomThresholds[moduleId];
}
