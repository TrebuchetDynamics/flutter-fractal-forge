import 'package:flutter_fractals/features/renderer/providers/fractal_view_input_bounds.dart';

/// Shared gesture viewport bounds for the renderer input layer.
///
/// Gesture code applies a soft rubber band before handing values to
/// [FractalController]. Keep those soft limits tied to the controller's hard
/// input contract so wheel/pinch targets inside supported bounds are not
/// prematurely damped by stale magic constants.
final class RendererGestureViewBounds {
  static const double minZoom = FractalViewInputBounds.defaultMinZoom;
  static const double maxZoom = FractalViewInputBounds.maxZoom;
  static const double minPan = FractalViewInputBounds.minPan;
  static const double maxPan = FractalViewInputBounds.maxPan;
  static const double defaultRubberBandStrength = 0.5;

  const RendererGestureViewBounds._();

  static double rubberBand(
    double value,
    double min,
    double max, {
    double strength = defaultRubberBandStrength,
  }) {
    assert(min <= max, 'rubber-band bounds must be ordered');
    if (value < min) return min + (value - min) * strength;
    if (value > max) return max + (value - max) * strength;
    return value;
  }
}
