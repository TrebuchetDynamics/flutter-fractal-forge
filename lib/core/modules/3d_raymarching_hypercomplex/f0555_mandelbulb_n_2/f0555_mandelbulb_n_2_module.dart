// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0555_mandelbulb_n_2_presets.dart';
import 'f0555_mandelbulb_n_2_variants.dart';
import 'f0555_mandelbulb_n_2_metadata.dart';

/// Mandelbulb n=2 — 3D Raymarching & Hypercomplex.
class F0555MandelbulbN2 extends Raymarched3DModule {
  F0555MandelbulbN2()
      : super(
          id: 'f0555_mandelbulb_n_2',
          shader: 'shaders/f0555_mandelbulb_n_2_gpu.frag',
        );

  @override
  F0555MandelbulbN2Metadata get metadata => F0555MandelbulbN2Metadata.instance;

  @override
  List<F0555MandelbulbN2Preset> get presets => F0555MandelbulbN2Presets.all;

  @override
  List<F0555MandelbulbN2Variant> get variants => F0555MandelbulbN2Variants.all;

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
