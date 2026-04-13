// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0557_mandelbulb_n_4_presets.dart';
import 'f0557_mandelbulb_n_4_variants.dart';
import 'f0557_mandelbulb_n_4_metadata.dart';

/// Mandelbulb n=4 — 3D Raymarching & Hypercomplex.
class F0557MandelbulbN4 extends Raymarched3DModule {
  F0557MandelbulbN4()
      : super(
          id: 'f0557_mandelbulb_n_4',
          shader: 'shaders/f0557_mandelbulb_n_4_gpu.frag',
        );

  @override
  F0557MandelbulbN4Metadata get metadata => F0557MandelbulbN4Metadata.instance;

  @override
  List<F0557MandelbulbN4Preset> get presets => F0557MandelbulbN4Presets.all;

  @override
  List<F0557MandelbulbN4Variant> get variants => F0557MandelbulbN4Variants.all;

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
