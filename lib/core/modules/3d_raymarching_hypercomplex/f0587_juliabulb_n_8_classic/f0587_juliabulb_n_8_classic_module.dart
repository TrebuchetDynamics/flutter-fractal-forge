// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0587_juliabulb_n_8_classic_presets.dart';
import 'f0587_juliabulb_n_8_classic_variants.dart';
import 'f0587_juliabulb_n_8_classic_metadata.dart';

/// Juliabulb n=8 (classic) — 3D Raymarching & Hypercomplex.
class F0587JuliabulbN8Classic extends Raymarched3DModule {
  F0587JuliabulbN8Classic()
      : super(
          id: 'f0587_juliabulb_n_8_classic',
          shader: 'shaders/f0587_juliabulb_n_8_classic_gpu.frag',
        );

  @override
  F0587JuliabulbN8ClassicMetadata get metadata => F0587JuliabulbN8ClassicMetadata.instance;

  @override
  List<F0587JuliabulbN8ClassicPreset> get presets => F0587JuliabulbN8ClassicPresets.all;

  @override
  List<F0587JuliabulbN8ClassicVariant> get variants => F0587JuliabulbN8ClassicVariants.all;

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
