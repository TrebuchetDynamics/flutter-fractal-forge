// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0591_juliabulb_n_6_symmetric_presets.dart';
import 'f0591_juliabulb_n_6_symmetric_variants.dart';
import 'f0591_juliabulb_n_6_symmetric_metadata.dart';

/// Juliabulb n=6 symmetric — 3D Raymarching & Hypercomplex.
class F0591JuliabulbN6Symmetric extends Raymarched3DModule {
  F0591JuliabulbN6Symmetric()
      : super(
          id: 'f0591_juliabulb_n_6_symmetric',
          shader: 'shaders/f0591_juliabulb_n_6_symmetric_gpu.frag',
        );

  @override
  F0591JuliabulbN6SymmetricMetadata get metadata => F0591JuliabulbN6SymmetricMetadata.instance;

  @override
  List<F0591JuliabulbN6SymmetricPreset> get presets => F0591JuliabulbN6SymmetricPresets.all;

  @override
  List<F0591JuliabulbN6SymmetricVariant> get variants => F0591JuliabulbN6SymmetricVariants.all;

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
