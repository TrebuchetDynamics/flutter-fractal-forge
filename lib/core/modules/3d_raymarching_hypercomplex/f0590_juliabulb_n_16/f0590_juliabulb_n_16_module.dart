// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0590_juliabulb_n_16_presets.dart';
import 'f0590_juliabulb_n_16_variants.dart';
import 'f0590_juliabulb_n_16_metadata.dart';

/// Juliabulb n=16 — 3D Raymarching & Hypercomplex.
class F0590JuliabulbN16 extends Raymarched3DModule {
  F0590JuliabulbN16()
      : super(
          id: 'f0590_juliabulb_n_16',
          shader: 'shaders/f0590_juliabulb_n_16_gpu.frag',
        );

  @override
  F0590JuliabulbN16Metadata get metadata => F0590JuliabulbN16Metadata.instance;

  @override
  List<F0590JuliabulbN16Preset> get presets => F0590JuliabulbN16Presets.all;

  @override
  List<F0590JuliabulbN16Variant> get variants => F0590JuliabulbN16Variants.all;

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
