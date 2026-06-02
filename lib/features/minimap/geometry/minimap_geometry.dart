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

  /// Fractal-plane span represented by the minimap overview on each axis.
  static const double overviewWorldSpan = 4.0;

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

  /// Maps an absolute fractal-plane pan center to minimap pixels.
  static Offset centerForPan({
    required Offset pan,
    required Size minimapSize,
  }) {
    final width = _positiveFiniteOrZero(minimapSize.width);
    final height = _positiveFiniteOrZero(minimapSize.height);
    if (width <= 0.0 || height <= 0.0) return Offset.zero;

    final safePan = normalizePan(pan);
    return Offset(
      width / 2.0 + safePan.dx * width / overviewWorldSpan,
      height / 2.0 + safePan.dy * height / overviewWorldSpan,
    );
  }

  /// Inverse of [centerForPan] for tap-to-pan jumps.
  static Offset panForCenter({
    required Offset center,
    required Size minimapSize,
  }) {
    final width = _positiveFiniteOrZero(minimapSize.width);
    final height = _positiveFiniteOrZero(minimapSize.height);
    if (width <= 0.0 || height <= 0.0) return Offset.zero;

    final safeCenter = Offset(
      center.dx.isFinite ? center.dx : width / 2.0,
      center.dy.isFinite ? center.dy : height / 2.0,
    );
    return Offset(
      (safeCenter.dx / width - 0.5) * overviewWorldSpan,
      (safeCenter.dy / height - 0.5) * overviewWorldSpan,
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

    final baseViewportWidth = (2.0 / safeZoom) * (width / overviewWorldSpan);
    final baseViewportHeight = (2.0 / safeZoom) * (height / overviewWorldSpan);
    final center = centerForPan(pan: safePan, minimapSize: minimapSize);

    return Rect.fromCenter(
      center: center,
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

    // Pan is an absolute fractal-plane center; zoom changes the viewport
    // indicator size, not which overview coordinate a tap selects.
    return panForCenter(center: localPosition, minimapSize: minimapSize);
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
