// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0551_bicomplex_mandelbrot_presets.dart';
import 'f0551_bicomplex_mandelbrot_variants.dart';
import 'f0551_bicomplex_mandelbrot_metadata.dart';

/// Bicomplex Mandelbrot — 3D Raymarching & Hypercomplex.
class F0551BicomplexMandelbrot extends Raymarched3DModule {
  F0551BicomplexMandelbrot()
      : super(
          id: 'f0551_bicomplex_mandelbrot',
          shader: 'shaders/f0551_bicomplex_mandelbrot_gpu.frag',
        );

  @override
  F0551BicomplexMandelbrotMetadata get metadata => F0551BicomplexMandelbrotMetadata.instance;

  @override
  List<F0551BicomplexMandelbrotPreset> get presets => F0551BicomplexMandelbrotPresets.all;

  @override
  List<F0551BicomplexMandelbrotVariant> get variants => F0551BicomplexMandelbrotVariants.all;

  @override
  double get defaultPower => 8.0;

  @override
  int get defaultSteps => 200;

  @override
  int get defaultIterations => 20;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setInt('steps', defaultSteps);
    p.setInt('iterations', defaultIterations);
  }
}
