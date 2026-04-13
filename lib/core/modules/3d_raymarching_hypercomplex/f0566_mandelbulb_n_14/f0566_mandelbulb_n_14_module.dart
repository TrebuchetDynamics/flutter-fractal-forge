// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0566_mandelbulb_n_14_presets.dart';
import 'f0566_mandelbulb_n_14_variants.dart';
import 'f0566_mandelbulb_n_14_metadata.dart';

/// Mandelbulb n=14 — 3D Raymarching & Hypercomplex.
class F0566MandelbulbN14 extends Raymarched3DModule {
  F0566MandelbulbN14()
      : super(
          id: 'f0566_mandelbulb_n_14',
          shader: 'shaders/f0566_mandelbulb_n_14_gpu.frag',
        );

  @override
  F0566MandelbulbN14Metadata get metadata => F0566MandelbulbN14Metadata.instance;

  @override
  List<F0566MandelbulbN14Preset> get presets => F0566MandelbulbN14Presets.all;

  @override
  List<F0566MandelbulbN14Variant> get variants => F0566MandelbulbN14Variants.all;

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
