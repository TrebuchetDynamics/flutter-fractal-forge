import 'package:vector_math/vector_math.dart';

/// Represents the view/camera state for fractal rendering.
///
/// This class captures the user's navigation state within a fractal:
/// - For 2D fractals: pan offset and zoom level
/// - For 3D fractals: rotation angles and zoom level
///
/// [FractalViewState] is designed to be stored in presets and serialized,
/// allowing users to save and restore specific viewpoints.
///
/// {@category Models}
///
/// Example:
/// ```dart
/// final view = FractalViewState(
///   pan: Vector2(-0.5, 0.2),  // Offset from center
///   zoom: 3.0,                 // 3x magnification
///   rotation: Vector3.zero(), // No rotation (for 2D)
/// );
/// ```
class FractalViewState {
  /// The 2D pan offset from the fractal center.
  ///
  /// For 2D fractals, this determines which part of the complex plane
  /// is visible. Positive X moves right, positive Y moves down.
  ///
  /// Typical range: -3.0 to 3.0 for each axis.
  final Vector2 pan;

  /// The current zoom/magnification level.
  ///
  /// - Values > 1.0 zoom in (magnify)
  /// - Values < 1.0 zoom out (shrink)
  /// - Value of 1.0 is the default view
  ///
  /// Clamped to range [0.05, 20.0] to prevent extreme zoom levels.
  final double zoom;

  /// The 3D rotation angles in radians.
  ///
  /// For 3D fractals like Mandelbulb, this controls the camera orientation:
  /// - x: Rotation around the X axis (pitch)
  /// - y: Rotation around the Y axis (yaw)
  /// - z: Rotation around the Z axis (roll)
  ///
  /// For 2D fractals, this is typically [Vector3.zero()].
  final Vector3 rotation;

  /// Creates a [FractalViewState] with specific view parameters.
  ///
  /// All parameters are required to define a complete view state.
  const FractalViewState({
    required this.pan,
    required this.zoom,
    required this.rotation,
  });

  /// Creates the initial/default view state.
  ///
  /// Centers the view with no pan offset, 1x zoom, and no rotation.
  /// This is the starting point when a fractal is first loaded.
  FractalViewState.initial()
      : pan = Vector2.zero(),
        zoom = 1.0,
        rotation = Vector3.zero();

  /// Creates a copy of this view state with the given fields replaced.
  ///
  /// Unspecified fields retain their original values.
  ///
  /// Example:
  /// ```dart
  /// final zoomed = view.copyWith(zoom: view.zoom * 2);
  /// ```
  FractalViewState copyWith({
    Vector2? pan,
    double? zoom,
    Vector3? rotation,
  }) {
    return FractalViewState(
      pan: pan ?? this.pan,
      zoom: zoom ?? this.zoom,
      rotation: rotation ?? this.rotation,
    );
  }
}
