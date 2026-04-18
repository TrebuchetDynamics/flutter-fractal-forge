// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0813_quadratic_map_mandelbrot_1d_presets.dart';
import 'f0813_quadratic_map_mandelbrot_1d_variants.dart';
import 'f0813_quadratic_map_mandelbrot_1d_metadata.dart';

/// Quadratic Map (Mandelbrot 1D) — Strange Attractors.
class F0813QuadraticMapMandelbrot1d extends AttractorModule {
  F0813QuadraticMapMandelbrot1d()
      : super(
          id: 'f0813_quadratic_map_mandelbrot_1d',
          shader: 'shaders/f0813_quadratic_map_mandelbrot_1d_gpu.frag',
        );

  @override
  F0813QuadraticMapMandelbrot1dMetadata get metadata => F0813QuadraticMapMandelbrot1dMetadata.instance;

  @override
  List<F0813QuadraticMapMandelbrot1dPreset> get presets => F0813QuadraticMapMandelbrot1dPresets.all;

  @override
  List<F0813QuadraticMapMandelbrot1dVariant> get variants => F0813QuadraticMapMandelbrot1dVariants.all;

  @override
  int get defaultIterations => 50000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
