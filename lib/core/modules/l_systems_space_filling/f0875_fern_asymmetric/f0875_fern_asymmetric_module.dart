// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0875_fern_asymmetric_presets.dart';
import 'f0875_fern_asymmetric_variants.dart';
import 'f0875_fern_asymmetric_metadata.dart';

/// Fern (Asymmetric) — L-Systems & Space-Filling.
class F0875FernAsymmetric extends LSystemModule {
  F0875FernAsymmetric()
      : super(
          id: 'f0875_fern_asymmetric',
          shader: 'shaders/f0875_fern_asymmetric_gpu.frag',
        );

  @override
  F0875FernAsymmetricMetadata get metadata => F0875FernAsymmetricMetadata.instance;

  @override
  List<F0875FernAsymmetricPreset> get presets => F0875FernAsymmetricPresets.all;

  @override
  List<F0875FernAsymmetricVariant> get variants => F0875FernAsymmetricVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
