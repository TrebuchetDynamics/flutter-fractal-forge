// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'metadata/f0560_mandelbulb_n_7_metadata.dart';
import 'presets/f0560_mandelbulb_n_7_presets.dart';
import 'variants/f0560_mandelbulb_n_7_variants.dart';

/// Mandelbulb n=7 — 3D Raymarching & Hypercomplex.
class F0560MandelbulbN7 extends Raymarched3DModule {
  F0560MandelbulbN7()
      : super(
          id: 'f0560_mandelbulb_n_7',
          shader: 'shaders/f0560_mandelbulb_n_7_gpu.frag',
        );

  @override
  F0560MandelbulbN7Metadata get metadata => F0560MandelbulbN7Metadata.instance;

  @override
  List<F0560MandelbulbN7Preset> get presets => F0560MandelbulbN7Presets.all;

  @override
  List<F0560MandelbulbN7Variant> get variants => F0560MandelbulbN7Variants.all;

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
