// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0864_cypress_tree_presets.dart';
import 'f0864_cypress_tree_variants.dart';
import 'f0864_cypress_tree_metadata.dart';

/// Cypress Tree — L-Systems & Space-Filling.
class F0864CypressTree extends LSystemModule {
  F0864CypressTree()
      : super(
          id: 'f0864_cypress_tree',
          shader: 'shaders/f0864_cypress_tree_gpu.frag',
        );

  @override
  F0864CypressTreeMetadata get metadata => F0864CypressTreeMetadata.instance;

  @override
  List<F0864CypressTreePreset> get presets => F0864CypressTreePresets.all;

  @override
  List<F0864CypressTreeVariant> get variants => F0864CypressTreeVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
