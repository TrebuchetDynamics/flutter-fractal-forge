import 'dart:math' as math;

/// Replayable CPU iteration budget policy for zoom-dependent refinement.
///
/// CPU rendering has preview/refine/slow-mode entry points that must agree on
/// how a zoom sample is sanitized before adding deep-zoom iteration headroom.
/// Keeping this pure avoids timer-driven render paths depending on Dart's
/// `log(...).round()` behavior for malformed zoom values.
final class CpuIterationBudget {
  static const int minimumIterations = 50;
  static const double zoomLog2IterationStep = 32.0;

  const CpuIterationBudget._();

  static double normalizeZoom(double zoom) {
    if (!zoom.isFinite || zoom <= 0.0) return 1.0;
    return zoom;
  }

  static int forZoom({
    required int baseIterations,
    required int maxIterations,
    required double zoom,
  }) {
    final safeMaxIterations = math.max(minimumIterations, maxIterations);
    final normalizedZoom = normalizeZoom(zoom);
    final extraIterations = normalizedZoom <= 1.0
        ? 0
        : (math.log(normalizedZoom) / math.ln2 * zoomLog2IterationStep).round();

    return (baseIterations + extraIterations).clamp(
      minimumIterations,
      safeMaxIterations,
    );
  }
}
