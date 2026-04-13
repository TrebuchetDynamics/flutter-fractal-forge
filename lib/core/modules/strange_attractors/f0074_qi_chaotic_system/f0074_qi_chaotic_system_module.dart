// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0074_qi_chaotic_system_presets.dart';
import 'f0074_qi_chaotic_system_variants.dart';
import 'f0074_qi_chaotic_system_metadata.dart';

/// Qi Chaotic System — Strange Attractors.
class F0074QiChaoticSystem extends AttractorModule {
  F0074QiChaoticSystem()
      : super(
          id: 'f0074_qi_chaotic_system',
          shader: 'shaders/f0074_qi_chaotic_system_gpu.frag',
        );

  @override
  F0074QiChaoticSystemMetadata get metadata => F0074QiChaoticSystemMetadata.instance;

  @override
  List<F0074QiChaoticSystemPreset> get presets => F0074QiChaoticSystemPresets.all;

  @override
  List<F0074QiChaoticSystemVariant> get variants => F0074QiChaoticSystemVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
