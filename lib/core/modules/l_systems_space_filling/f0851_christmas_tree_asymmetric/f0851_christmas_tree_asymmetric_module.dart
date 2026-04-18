// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0851_christmas_tree_asymmetric_presets.dart';
import 'f0851_christmas_tree_asymmetric_variants.dart';
import 'f0851_christmas_tree_asymmetric_metadata.dart';

/// Christmas Tree Asymmetric — L-Systems & Space-Filling.
class F0851ChristmasTreeAsymmetric extends LSystemModule {
  F0851ChristmasTreeAsymmetric()
      : super(
          id: 'f0851_christmas_tree_asymmetric',
          shader: 'shaders/f0851_christmas_tree_asymmetric_gpu.frag',
        );

  @override
  F0851ChristmasTreeAsymmetricMetadata get metadata => F0851ChristmasTreeAsymmetricMetadata.instance;

  @override
  List<F0851ChristmasTreeAsymmetricPreset> get presets => F0851ChristmasTreeAsymmetricPresets.all;

  @override
  List<F0851ChristmasTreeAsymmetricVariant> get variants => F0851ChristmasTreeAsymmetricVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
