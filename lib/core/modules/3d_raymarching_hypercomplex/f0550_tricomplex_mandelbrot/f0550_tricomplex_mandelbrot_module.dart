// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0550_tricomplex_mandelbrot_presets.dart';
import 'f0550_tricomplex_mandelbrot_variants.dart';
import 'f0550_tricomplex_mandelbrot_metadata.dart';

/// Tricomplex Mandelbrot — 3D Raymarching & Hypercomplex.
class F0550TricomplexMandelbrot extends Raymarched3DModule {
  F0550TricomplexMandelbrot()
      : super(
          id: 'f0550_tricomplex_mandelbrot',
          shader: 'shaders/f0550_tricomplex_mandelbrot_gpu.frag',
        );

  @override
  F0550TricomplexMandelbrotMetadata get metadata => F0550TricomplexMandelbrotMetadata.instance;

  @override
  List<F0550TricomplexMandelbrotPreset> get presets => F0550TricomplexMandelbrotPresets.all;

  @override
  List<F0550TricomplexMandelbrotVariant> get variants => F0550TricomplexMandelbrotVariants.all;

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
