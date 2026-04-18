// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0850_christmas_tree_symmetric_presets.dart';
import 'f0850_christmas_tree_symmetric_variants.dart';
import 'f0850_christmas_tree_symmetric_metadata.dart';

/// Christmas Tree Symmetric — L-Systems & Space-Filling.
class F0850ChristmasTreeSymmetric extends LSystemModule {
  F0850ChristmasTreeSymmetric()
      : super(
          id: 'f0850_christmas_tree_symmetric',
          shader: 'shaders/f0850_christmas_tree_symmetric_gpu.frag',
        );

  @override
  F0850ChristmasTreeSymmetricMetadata get metadata => F0850ChristmasTreeSymmetricMetadata.instance;

  @override
  List<F0850ChristmasTreeSymmetricPreset> get presets => F0850ChristmasTreeSymmetricPresets.all;

  @override
  List<F0850ChristmasTreeSymmetricVariant> get variants => F0850ChristmasTreeSymmetricVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
