// Base class for complex-plane escape-time fractals (Mandelbrot family, Julia, etc.).
import 'package:meta/meta.dart';
import 'shader_params.dart';

/// Base class for 2D escape-time fractals on the complex plane.
///
/// Subclasses define parameter defaults and wire them to shader uniforms in
/// [configureShader]. Pipeline-emitted modules follow the template in
/// `scripts/research/admit/templates/dart/escape_time_module.j2`.
@immutable
abstract class EscapeTimeModule {
  final String id;
  final String shader;

  const EscapeTimeModule({
    required this.id,
    required this.shader,
  });

  /// Metadata (name, category, aliases, references).
  Object get metadata;

  /// Named zoom regions known for this fractal (seahorse valley, elephant valley).
  List<Object> get presets;

  /// Formula variants (power differences, burning-ship twists, etc.).
  List<Object> get variants;

  /// Exponent d in z -> z^d + c. Default 2.0 for classic Mandelbrot.
  double get defaultPower => 2.0;

  /// Escape radius |z| > bailout triggers loop termination.
  double get defaultBailout => 2.0;

  /// Max iterations per pixel.
  int get defaultIterations => 500;

  /// Deep-zoom rendering strategy. Override for perturbation-capable fractals.
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.none;

  /// Bind defaults to shader uniforms. Override to add fractal-specific params.
  void configureShader(ShaderParams p);
}
