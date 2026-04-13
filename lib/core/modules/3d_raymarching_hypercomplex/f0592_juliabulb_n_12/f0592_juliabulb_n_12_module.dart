// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0592_juliabulb_n_12_presets.dart';
import 'f0592_juliabulb_n_12_variants.dart';
import 'f0592_juliabulb_n_12_metadata.dart';

/// Juliabulb n=12 — 3D Raymarching & Hypercomplex.
class F0592JuliabulbN12 extends Raymarched3DModule {
  F0592JuliabulbN12()
      : super(
          id: 'f0592_juliabulb_n_12',
          shader: 'shaders/f0592_juliabulb_n_12_gpu.frag',
        );

  @override
  F0592JuliabulbN12Metadata get metadata => F0592JuliabulbN12Metadata.instance;

  @override
  List<F0592JuliabulbN12Preset> get presets => F0592JuliabulbN12Presets.all;

  @override
  List<F0592JuliabulbN12Variant> get variants => F0592JuliabulbN12Variants.all;

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
