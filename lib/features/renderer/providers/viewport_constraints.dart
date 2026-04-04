/// Defines viewport constraints for different fractal modules.
///
/// Responsibilities:
/// - Provide module-specific zoom limits
/// - Define pan bounds for 2D fractals
///
/// Extracted from FractalController to follow Single Responsibility Principle.
class ViewportConstraints {
  /// Returns the minimum zoom level allowed for a given module.
  ///
  /// Some fractals have aliasing issues at extreme zoom-out levels.
  double minZoom(String moduleId) {
    switch (moduleId) {
      case 'cantor_set':
        // Prevent ultra-zoomed-out aliasing that appears as black vertical bands.
        return 0.2;
      default:
        return 1e-9;
    }
  }

  /// Returns the maximum zoom level allowed.
  ///
  /// Beyond this, precision fallback kicks in.
  double get maxZoom => 1e12;

  /// Clamps zoom to the valid range for a module.
  double clampZoom(String moduleId, double zoom) {
    return zoom.clamp(minZoom(moduleId), maxZoom);
  }

  /// The valid range for pan offsets in 2D fractals.
  static const double panMin = -3.0;
  static const double panMax = 3.0;
}
