import 'dart:math' as math;

/// Replayable CPU render dimensions for preview/refine/slow-mode passes.
///
/// The CPU renderer uses reduced preview passes while gestures are active and a
/// high-resolution slow-mode pass after refinement. Keeping those dimensions in
/// a pure value object exposes the magic floors/caps and makes tiny viewport
/// edge cases testable without spinning up timers or isolates.
final class CpuRenderResolution {
  const CpuRenderResolution({required this.width, required this.height});

  static const int minInteractiveDimension = 200;
  static const int minSlowModeWidth = 400;
  static const int minSlowModeHeight = 400;
  static const int maxSlowModeWidth = 2160;
  static const int maxSlowModeHeight = 3840;

  final int width;
  final int height;

  factory CpuRenderResolution.forPass({
    required int targetWidth,
    required int targetHeight,
    required double resolutionScale,
  }) {
    return CpuRenderResolution(
      width: _interactiveDimension(
        targetDimension: targetWidth,
        resolutionScale: resolutionScale,
      ),
      height: _interactiveDimension(
        targetDimension: targetHeight,
        resolutionScale: resolutionScale,
      ),
    );
  }

  factory CpuRenderResolution.forSlowMode({
    required int targetWidth,
    required int targetHeight,
  }) {
    return CpuRenderResolution(
      width:
          (targetWidth * 2).clamp(minSlowModeWidth, maxSlowModeWidth).toInt(),
      height: (targetHeight * 2)
          .clamp(minSlowModeHeight, maxSlowModeHeight)
          .toInt(),
    );
  }

  static int _interactiveDimension({
    required int targetDimension,
    required double resolutionScale,
  }) {
    if (!resolutionScale.isFinite || resolutionScale >= 1.0) {
      return targetDimension;
    }
    if (targetDimension <= 0) return targetDimension;

    final lowerBound = math.min(minInteractiveDimension, targetDimension);
    return (targetDimension * resolutionScale)
        .round()
        .clamp(lowerBound, targetDimension)
        .toInt();
  }
}
