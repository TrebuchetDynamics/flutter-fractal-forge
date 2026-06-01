import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:vector_math/vector_math.dart';

/// Pure bounds for gesture/view input accepted by FractalController.
///
/// Dart's [double.clamp] treats NaN as the upper bound. Gesture telemetry and
/// replayed state can occasionally contain NaN, and promoting that to max zoom
/// or max pan makes failures hard to replay. Preserve the last known-good value
/// for NaN while still clamping infinities to the explicit viewport limits.
final class FractalViewInputBounds {
  static const double maxZoom = 1e12;
  static const double defaultMinZoom = 1e-9;
  static const double cantorSetMinZoom = 0.2;
  static const double minPan = -3.0;
  static const double maxPan = 3.0;

  const FractalViewInputBounds._();

  static double minZoomForModule(String moduleId) {
    switch (moduleId) {
      case 'cantor_set':
        // Prevent ultra-zoomed-out aliasing that appears as black vertical bands.
        return cantorSetMinZoom;
      default:
        return defaultMinZoom;
    }
  }

  static double normalizeZoom({
    required double candidate,
    required double currentZoom,
    required String moduleId,
  }) {
    final minZoom = minZoomForModule(moduleId);
    final fallback = currentZoom.isNaN ? minZoom : currentZoom;
    if (candidate.isNaN) return fallback.clamp(minZoom, maxZoom).toDouble();
    return candidate.clamp(minZoom, maxZoom).toDouble();
  }

  static double normalizePanComponent({
    required double candidate,
    required double current,
  }) {
    final fallback = current.isNaN ? 0.0 : current;
    if (candidate.isNaN) return fallback.clamp(minPan, maxPan).toDouble();
    return candidate.clamp(minPan, maxPan).toDouble();
  }

  /// Sanitizes externally supplied view snapshots before they become controller
  /// state. Finite values preserve existing behavior; NaN values fall back to
  /// the last known-good view while infinities clamp to explicit bounds.
  static FractalViewState normalizeView({
    required FractalViewState candidate,
    required FractalViewState current,
    required String moduleId,
  }) {
    return candidate.copyWith(
      pan: Vector2(
        normalizePanComponent(
            candidate: candidate.pan.x, current: current.pan.x),
        normalizePanComponent(
            candidate: candidate.pan.y, current: current.pan.y),
      ),
      zoom: normalizeZoom(
        candidate: candidate.zoom,
        currentZoom: current.zoom,
        moduleId: moduleId,
      ),
    );
  }
}
