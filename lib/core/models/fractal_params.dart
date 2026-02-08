import 'package:equatable/equatable.dart';
import 'package:vector_math/vector_math.dart';

/// Represents the complete rendering parameters for a fractal.
///
/// This class encapsulates all configurable options that affect how a fractal
/// is rendered, including mathematical parameters (power, iterations, bailout),
/// visual settings (color scheme, zoom), and spatial transformations (rotation).
///
/// {@category Models}
///
/// Example:
/// ```dart
/// final params = FractalParams(
///   power: 8.0,
///   iterations: 100,
///   zoom: 2.0,
///   rotation: Vector3(0.5, 0.3, 0.0),
///   mousePos: Vector2.zero(),
/// );
/// ```
class FractalParams extends Equatable {
  /// The mathematical power used in fractal calculations.
  ///
  /// Higher values create more intricate patterns. For Mandelbulb fractals,
  /// values of 8 produce the classic shape, while lower or higher values
  /// create interesting variations.
  ///
  /// Typical range: 2.0 to 12.0
  final double power;

  /// The maximum number of iterations for escape-time calculations.
  ///
  /// Higher iteration counts reveal more detail but require more computation.
  /// Values between 50-200 are typical for interactive rendering.
  final int iterations;

  /// The escape radius threshold for fractal calculations.
  ///
  /// Points that exceed this distance from the origin are considered to have
  /// escaped. Lower values create sharper boundaries.
  ///
  /// Typical range: 1.0 to 4.0
  final double bailout;

  /// The current zoom/magnification level.
  ///
  /// Values greater than 1.0 zoom in, values less than 1.0 zoom out.
  /// Range is typically clamped to 0.1x - 10x.
  final double zoom;

  /// The 3D rotation angles for the fractal view.
  ///
  /// Used for 3D fractals (like Mandelbulb) to control camera orientation.
  /// Each component represents rotation around the X, Y, and Z axes respectively.
  final Vector3 rotation;

  /// The active color scheme index.
  ///
  /// Maps to [AppColorScheme] enum values:
  /// - 0: Fire
  /// - 1: Ocean
  /// - 2: Psychedelic
  /// - 3: Grayscale
  final int colorScheme;

  /// The current mouse/touch position in normalized coordinates.
  ///
  /// Used for interactive effects where the fractal responds to pointer position.
  final Vector2 mousePos;

  /// The type of fractal being rendered.
  ///
  /// Determines which algorithm is used for fractal generation.
  final FractalType fractalType;
  
  /// Creates a new [FractalParams] instance with the specified values.
  ///
  /// The [rotation] and [mousePos] vectors are required as they have no
  /// sensible universal default.
  const FractalParams({
    this.power = 8.0,
    this.iterations = 50,
    this.bailout = 2.0,
    this.zoom = 1.0,
    required this.rotation,
    this.colorScheme = 0,
    required this.mousePos,
    this.fractalType = FractalType.mandelbulb,
  });

  /// Creates a [FractalParams] with sensible default values.
  ///
  /// Useful for initialization when no specific parameters are needed.
  FractalParams.withDefaults()
      : power = 8.0,
        iterations = 50,
        bailout = 2.0,
        zoom = 1.0,
        rotation = Vector3(0.0, 0.0, 0.0),
        colorScheme = 0,
        mousePos = Vector2(0.0, 0.0),
        fractalType = FractalType.mandelbulb;

  /// Creates a copy of this [FractalParams] with the given fields replaced.
  ///
  /// All parameters are optional; unspecified parameters retain their
  /// original values.
  FractalParams copyWith({
    double? power,
    int? iterations,
    double? bailout,
    double? zoom,
    Vector3? rotation,
    int? colorScheme,
    Vector2? mousePos,
    FractalType? fractalType,
  }) {
    return FractalParams(
      power: power ?? this.power,
      iterations: iterations ?? this.iterations,
      bailout: bailout ?? this.bailout,
      zoom: zoom ?? this.zoom,
      rotation: rotation ?? this.rotation,
      colorScheme: colorScheme ?? this.colorScheme,
      mousePos: mousePos ?? this.mousePos,
      fractalType: fractalType ?? this.fractalType,
    );
  }

  @override
  List<Object?> get props => [
        power,
        iterations,
        bailout,
        zoom,
        rotation,
        colorScheme,
        mousePos,
        fractalType,
      ];
}

/// Available color schemes for fractal rendering.
///
/// Each scheme provides a distinct visual aesthetic for the fractal output.
enum AppColorScheme {
  /// Warm orange-red-yellow gradient, reminiscent of flames.
  fire,

  /// Cool blue-teal gradient, evoking underwater themes.
  ocean,

  /// Vibrant multi-color gradient with high saturation.
  psychedelic,

  /// Black-to-white gradient for a classic mathematical look.
  grayscale;
}

/// Types of fractals available for rendering.
///
/// Each type uses a different mathematical algorithm to generate
/// its characteristic patterns.
enum FractalType {
  /// 3D extension of the Mandelbrot set.
  ///
  /// Creates a bulbous, organic-looking 3D shape through
  /// spherical coordinate mapping.
  mandelbulb,

  /// Box-folding fractal with recursive transformations.
  ///
  /// Creates geometric, box-like structures with infinite detail.
  mandelbox,

  /// Complex-number iteration fractal.
  ///
  /// Uses a constant complex parameter to create varied 2D patterns.
  julia,

  /// Recursive tetrahedron subdivision.
  ///
  /// A 3D fractal created by iteratively removing tetrahedra
  /// from a larger tetrahedron.
  sierpinski;
}
