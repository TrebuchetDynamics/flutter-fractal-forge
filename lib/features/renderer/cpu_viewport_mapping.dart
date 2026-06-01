import 'package:vector_math/vector_math.dart' show Vector2;

/// Shared CPU-render viewport mapping.
///
/// Pixel coordinates are edge-inclusive for iteration buffers, preserving the
/// existing scalar-field/golden contract. Subpixel sample coordinates are
/// center-of-pixel positions and must stay inside the same [-1, 1] viewport.
final class CpuViewportMapping {
  final double centerX;
  final double centerY;
  final double scale;
  final double aspect;

  CpuViewportMapping({
    required Vector2 viewPan,
    required double viewZoom,
    required int width,
    required int height,
  })  : centerX = viewPan.x,
        centerY = viewPan.y,
        scale = 1.5 / (viewZoom <= 0 ? 1.0 : viewZoom),
        aspect = height == 0 ? 1.0 : width / height;

  double normalizedPixel(int pixel, int extent) {
    if (extent <= 1) return 0.0;
    return (pixel / (extent - 1)) * 2.0 - 1.0;
  }

  double normalizedSample({
    required int pixel,
    required int extent,
    required int sample,
    required int samplesPerAxis,
  }) {
    if (extent <= 1) return 0.0;
    final safeSamples = samplesPerAxis <= 0 ? 1 : samplesPerAxis;
    final subPixel = pixel + (sample + 0.5) / safeSamples;
    return (subPixel / extent) * 2.0 - 1.0;
  }

  (double x, double y) coordinate({required double nx, required double ny}) {
    return (centerX + nx * scale * aspect, centerY + ny * scale);
  }
}
