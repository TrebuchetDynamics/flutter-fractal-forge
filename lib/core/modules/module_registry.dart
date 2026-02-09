import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/gpu_gradient_module.dart';
import 'package:flutter_fractals/core/modules/gpu_sampler_diag_module.dart';
import 'package:flutter_fractals/core/modules/burning_ship_module.dart';
import 'package:flutter_fractals/core/modules/julia_module.dart';
import 'package:flutter_fractals/core/modules/mandelbrot_module.dart';
import 'package:flutter_fractals/core/modules/mandelbulb_module.dart';
import 'package:flutter_fractals/core/modules/phoenix_module.dart';

/// Registry of all available fractal modules.
///
/// [ModuleRegistry] is the central catalog of fractal types available in the app.
/// It is created at app startup and provided to [FractalController] instances.
///
/// To add a new fractal type:
/// 1. Create a module builder function (see `mandelbrot_module.dart`)
/// 2. Import it here
/// 3. Add it to the [modules] list
///
/// {@category Modules}
///
/// Example:
/// ```dart
/// final registry = ModuleRegistry();
///
/// // Get all modules
/// for (final module in registry.modules) {
///   print(module.id);
/// }
///
/// // Look up by ID
/// final mandelbrot = registry.byId('mandelbrot');
/// ```
class ModuleRegistry {
  /// All available fractal modules.
  ///
  /// The order here determines the display order in the catalog UI.
  final List<FractalModule> modules;

  /// Creates a new [ModuleRegistry] with all built-in fractal modules.
  ///
  /// Modules are instantiated in order:
  /// - Mandelbrot (2D, classic)
  /// - Julia (2D, parameter-based)
  /// - Burning Ship (2D, angular)
  /// - Phoenix (2D, recursive)
  /// - Mandelbulb (3D, spherical)
  ModuleRegistry() : modules = [
    buildMandelbrotModule(),
    buildJuliaModule(),
    buildBurningShipModule(),
    buildPhoenixModule(),
    buildMandelbulbModule(),
    // Keep diagnostics last so existing UI/tests keep their assumptions.
    buildGpuGradientModule(),
    buildGpuSamplerDiagModule(),
  ];

  /// Retrieves a module by its unique [id].
  ///
  /// Throws [StateError] if no module with the given ID exists.
  ///
  /// Example:
  /// ```dart
  /// final julia = registry.byId('julia');
  /// ```
  FractalModule byId(String id) {
    return modules.firstWhere((module) => module.id == id);
  }
}
