// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0589_juliabulb_n_3_presets.dart';
import 'f0589_juliabulb_n_3_variants.dart';
import 'f0589_juliabulb_n_3_metadata.dart';

/// Juliabulb n=3 — 3D Raymarching & Hypercomplex.
class F0589JuliabulbN3 extends Raymarched3DModule {
  F0589JuliabulbN3()
      : super(
          id: 'f0589_juliabulb_n_3',
          shader: 'shaders/f0589_juliabulb_n_3_gpu.frag',
        );

  @override
  F0589JuliabulbN3Metadata get metadata => F0589JuliabulbN3Metadata.instance;

  @override
  List<F0589JuliabulbN3Preset> get presets => F0589JuliabulbN3Presets.all;

  @override
  List<F0589JuliabulbN3Variant> get variants => F0589JuliabulbN3Variants.all;

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
