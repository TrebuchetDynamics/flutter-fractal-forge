// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0552_octonion_mandelbrot_presets.dart';
import 'f0552_octonion_mandelbrot_variants.dart';
import 'f0552_octonion_mandelbrot_metadata.dart';

/// Octonion Mandelbrot — 3D Raymarching & Hypercomplex.
class F0552OctonionMandelbrot extends Raymarched3DModule {
  F0552OctonionMandelbrot()
      : super(
          id: 'f0552_octonion_mandelbrot',
          shader: 'shaders/f0552_octonion_mandelbrot_gpu.frag',
        );

  @override
  F0552OctonionMandelbrotMetadata get metadata => F0552OctonionMandelbrotMetadata.instance;

  @override
  List<F0552OctonionMandelbrotPreset> get presets => F0552OctonionMandelbrotPresets.all;

  @override
  List<F0552OctonionMandelbrotVariant> get variants => F0552OctonionMandelbrotVariants.all;

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
