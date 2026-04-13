// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0247_ternary_tree_presets.dart';
import 'f0247_ternary_tree_variants.dart';
import 'f0247_ternary_tree_metadata.dart';

/// Ternary Tree — L-Systems & Space-Filling.
class F0247TernaryTree extends LSystemModule {
  F0247TernaryTree()
      : super(
          id: 'f0247_ternary_tree',
          shader: 'shaders/f0247_ternary_tree_gpu.frag',
        );

  @override
  F0247TernaryTreeMetadata get metadata => F0247TernaryTreeMetadata.instance;

  @override
  List<F0247TernaryTreePreset> get presets => F0247TernaryTreePresets.all;

  @override
  List<F0247TernaryTreeVariant> get variants => F0247TernaryTreeVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
