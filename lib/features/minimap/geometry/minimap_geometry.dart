import 'dart:math' as math;
import 'dart:ui';

/// Replayable geometry for the 2D fractal minimap.
///
/// The widget paints a tiny overview and an indicator for the currently visible
/// renderer viewport. Keeping the coordinate math pure lets tests characterize
/// assumptions about zoom samples, minimap size, and renderer aspect ratio
/// without relying on a canvas paint pass.
final class MiniMapGeometry {
  static const double defaultZoom = 1.0;
  static const double minimumIndicatorDimension = 4.0;

  const MiniMapGeometry._();

  static double normalizeZoom(double zoom) {
    if (!zoom.isFinite || zoom <= 0.0) return defaultZoom;
    return zoom;
  }

  static Offset normalizePan(Offset pan) {
    return Offset(
      pan.dx.isFinite ? pan.dx : 0.0,
      pan.dy.isFinite ? pan.dy : 0.0,
    );
  }

  static Rect viewportRect({
    required Offset pan,
    required double zoom,
    required Size minimapSize,
    required Size viewportSize,
  }) {
    final width = _positiveFiniteOrZero(minimapSize.width);
    final height = _positiveFiniteOrZero(minimapSize.height);
    if (width <= 0.0 || height <= 0.0) return Rect.zero;

    final safePan = normalizePan(pan);
    final safeZoom = normalizeZoom(zoom);
    final safeViewportSize = _positiveFiniteViewportSize(viewportSize);
    final viewportShortSide = math.min(
      safeViewportSize.width,
      safeViewportSize.height,
    );
    final viewportWidthScale = safeViewportSize.width / viewportShortSide;
    final viewportHeightScale = safeViewportSize.height / viewportShortSide;

    final baseViewportWidth = (2.0 / safeZoom) * (width / 4.0);
    final baseViewportHeight = (2.0 / safeZoom) * (height / 4.0);
    final centerX = width / 2.0 + safePan.dx * width / 4.0;
    final centerY = height / 2.0 + safePan.dy * height / 4.0;

    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: _clampIndicatorDimension(
        baseViewportWidth * viewportWidthScale,
        width,
      ),
      height: _clampIndicatorDimension(
        baseViewportHeight * viewportHeightScale,
        height,
      ),
    );
  }

  static Offset panForTap({
    required Offset localPosition,
    required Size minimapSize,
    required double zoom,
  }) {
    final width = _positiveFiniteOrZero(minimapSize.width);
    final height = _positiveFiniteOrZero(minimapSize.height);
    if (width <= 0.0 || height <= 0.0) return Offset.zero;

    final normalizedX = (localPosition.dx / width) - 0.5;
    final normalizedY = (localPosition.dy / height) - 0.5;
    final scale = 2.0 / normalizeZoom(zoom);
    return Offset(normalizedX * scale, normalizedY * scale);
  }

  static double _positiveFiniteOrZero(double value) {
    return value.isFinite && value > 0.0 ? value : 0.0;
  }

  static Size _positiveFiniteViewportSize(Size size) {
    if (_positiveFiniteOrZero(size.width) == 0.0 ||
        _positiveFiniteOrZero(size.height) == 0.0) {
      return const Size(1, 1);
    }
    return size;
  }

  static double _clampIndicatorDimension(double value, double extent) {
    final lower = math.min(minimumIndicatorDimension, extent);
    if (!value.isFinite || value <= 0.0) return lower;
    return value.clamp(lower, extent).toDouble();
  }
}
