import 'dart:math' as math;

import 'package:vector_math/vector_math.dart' show Vector2;

/// Replayable viewport dimensions for CPU coordinate mapping.
///
/// Render requests should provide positive dimensions. When a direct mapping
/// caller passes invalid dimensions, fall back to a square viewport instead of
/// leaking zero/negative aspect ratios into fractal coordinates.
final class CpuViewportDimensions {
  const CpuViewportDimensions({required this.width, required this.height});

  final int width;
  final int height;

  factory CpuViewportDimensions.fromSize({
    required int width,
    required int height,
  }) {
    if (width <= 0 || height <= 0) {
      return const CpuViewportDimensions(width: 1, height: 1);
    }
    return CpuViewportDimensions(width: width, height: height);
  }

  double get aspect => width / height;
}

/// Explicit dimensions contract for CPU render work.
final class CpuRenderDimensions {
  const CpuRenderDimensions({required this.width, required this.height});

  final int width;
  final int height;

  void validate() {
    if (width <= 0 || height <= 0) {
      throw ArgumentError.value(
        (width, height),
        'full viewport',
        'must be positive',
      );
    }
  }
}

/// Explicit bounds contract for a CPU render tile inside a full viewport.
final class CpuRenderRect {
  const CpuRenderRect({
    required this.fullWidth,
    required this.fullHeight,
    required this.x0,
    required this.y0,
    required this.w,
    required this.h,
  });

  final int fullWidth;
  final int fullHeight;
  final int x0;
  final int y0;
  final int w;
  final int h;

  void validate() {
    CpuRenderDimensions(width: fullWidth, height: fullHeight).validate();
    if (w <= 0 || h <= 0) {
      throw ArgumentError.value((w, h), 'tile size', 'must be positive');
    }
    if (x0 < 0 || y0 < 0 || x0 + w > fullWidth || y0 + h > fullHeight) {
      throw ArgumentError.value(
        (x0, y0, w, h),
        'tile rect',
        'must be within the full viewport',
      );
    }
  }
}

/// Explicit point contract for a CPU pixel sample inside a full viewport.
final class CpuRenderSamplePoint {
  const CpuRenderSamplePoint({
    required this.fullWidth,
    required this.fullHeight,
    required this.x,
    required this.y,
  });

  final int fullWidth;
  final int fullHeight;
  final int x;
  final int y;

  void validate() {
    CpuRenderDimensions(width: fullWidth, height: fullHeight).validate();
    if (x < 0 || y < 0 || x >= fullWidth || y >= fullHeight) {
      throw ArgumentError.value(
        (x, y),
        'sample coordinate',
        'must be inside the full viewport',
      );
    }
  }
}

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
  }) : this.fromScalars(
          panX: viewPan.x,
          panY: viewPan.y,
          viewZoom: viewZoom,
          width: width,
          height: height,
        );

  CpuViewportMapping.fromScalars({
    required double panX,
    required double panY,
    required double viewZoom,
    required int width,
    required int height,
  })  : centerX = panX,
        centerY = panY,
        scale = 1.5 / normalizeZoom(viewZoom),
        aspect = CpuViewportDimensions.fromSize(
          width: width,
          height: height,
        ).aspect;

  static double normalizeZoom(double zoom) {
    if (!zoom.isFinite || zoom <= 0.0) return 1.0;
    return zoom;
  }

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
    final safeSamples = samplesPerAxis <= 0 ? 1 : samplesPerAxis;
    final safeSample = sample.clamp(0, safeSamples - 1).toInt();
    return normalizedSampleOffset(
      pixel: pixel,
      extent: extent,
      sampleOffset: (safeSample + 0.5) / safeSamples,
    );
  }

  double normalizedSampleOffset({
    required int pixel,
    required int extent,
    required double sampleOffset,
  }) {
    if (extent <= 1) return 0.0;
    final safePixel = pixel.clamp(0, extent - 1).toInt();
    final safeOffset =
        sampleOffset.isNaN ? 0.5 : sampleOffset.clamp(0.0, 1.0).toDouble();
    final subPixel = safePixel + safeOffset;
    return (subPixel / extent) * 2.0 - 1.0;
  }

  (double x, double y) coordinate({required double nx, required double ny}) {
    return (centerX + nx * scale * aspect, centerY + ny * scale);
  }
}

/// Replayable CPU anti-aliasing grid derived from a requested sample count.
///
/// The CPU renderer samples a square grid, so non-square requests are rounded up
/// to the next square grid instead of silently dropping requested samples.
final class CpuSampleGrid {
  CpuSampleGrid.fromRequestedCount(int requestedCount)
      : this._(
          requestedCount: requestedCount,
          samplesPerAxis: _samplesPerAxisFor(requestedCount),
        );

  const CpuSampleGrid._({
    required this.requestedCount,
    required this.samplesPerAxis,
  });

  final int requestedCount;
  final int samplesPerAxis;

  int get totalSamples => samplesPerAxis * samplesPerAxis;

  bool get wasRoundedUp => totalSamples > math.max(1, requestedCount);

  static int _samplesPerAxisFor(int requestedCount) {
    if (requestedCount <= 0) return 1;
    return math.max(1, math.sqrt(requestedCount).ceil());
  }
}
