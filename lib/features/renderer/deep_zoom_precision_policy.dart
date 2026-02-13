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
  /// Per-module thresholds. Fractals near the boundary (mandelbrot, julia)
  /// show float32 artifacts earlier than simpler fractals.
  static const Map<String, double> _cpuFallbackZoomThresholds = {
    'mandelbrot': 1e5,
    'julia': 5e4,
    'celtic': 5e4,
    'buffalo': 5e4,
    'burning_ship': 5e4,
    'tricorn': 5e4,
    'multibrot3': 5e4,
    'phoenix': 5e4,
  };

  /// Default threshold for any escape-time fractal not listed above.
  /// float32 has ~7 digits of mantissa; at 1080p a pixel spans ~3/zoom
  /// of the complex plane. Artifacts appear when that span drops below
  /// ~1e-7, i.e. zoom ~= 3e4 to 1e5 depending on center offset.
  static const double _defaultThreshold = 2e5;

  const DeepZoomPrecisionPolicy();

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
}
