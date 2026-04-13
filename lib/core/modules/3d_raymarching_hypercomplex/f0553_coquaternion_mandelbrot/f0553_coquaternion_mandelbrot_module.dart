// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0553_coquaternion_mandelbrot_presets.dart';
import 'f0553_coquaternion_mandelbrot_variants.dart';
import 'f0553_coquaternion_mandelbrot_metadata.dart';

/// Coquaternion Mandelbrot — 3D Raymarching & Hypercomplex.
class F0553CoquaternionMandelbrot extends Raymarched3DModule {
  F0553CoquaternionMandelbrot()
      : super(
          id: 'f0553_coquaternion_mandelbrot',
          shader: 'shaders/f0553_coquaternion_mandelbrot_gpu.frag',
        );

  @override
  F0553CoquaternionMandelbrotMetadata get metadata => F0553CoquaternionMandelbrotMetadata.instance;

  @override
  List<F0553CoquaternionMandelbrotPreset> get presets => F0553CoquaternionMandelbrotPresets.all;

  @override
  List<F0553CoquaternionMandelbrotVariant> get variants => F0553CoquaternionMandelbrotVariants.all;

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
