// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0567_mandelbulb_n_16_presets.dart';
import 'f0567_mandelbulb_n_16_variants.dart';
import 'f0567_mandelbulb_n_16_metadata.dart';

/// Mandelbulb n=16 — 3D Raymarching & Hypercomplex.
class F0567MandelbulbN16 extends Raymarched3DModule {
  F0567MandelbulbN16()
      : super(
          id: 'f0567_mandelbulb_n_16',
          shader: 'shaders/f0567_mandelbulb_n_16_gpu.frag',
        );

  @override
  F0567MandelbulbN16Metadata get metadata => F0567MandelbulbN16Metadata.instance;

  @override
  List<F0567MandelbulbN16Preset> get presets => F0567MandelbulbN16Presets.all;

  @override
  List<F0567MandelbulbN16Variant> get variants => F0567MandelbulbN16Variants.all;

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
