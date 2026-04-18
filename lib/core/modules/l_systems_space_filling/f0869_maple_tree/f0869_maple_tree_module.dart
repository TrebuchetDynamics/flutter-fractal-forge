// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0869_maple_tree_presets.dart';
import 'f0869_maple_tree_variants.dart';
import 'f0869_maple_tree_metadata.dart';

/// Maple Tree — L-Systems & Space-Filling.
class F0869MapleTree extends LSystemModule {
  F0869MapleTree()
      : super(
          id: 'f0869_maple_tree',
          shader: 'shaders/f0869_maple_tree_gpu.frag',
        );

  @override
  F0869MapleTreeMetadata get metadata => F0869MapleTreeMetadata.instance;

  @override
  List<F0869MapleTreePreset> get presets => F0869MapleTreePresets.all;

  @override
  List<F0869MapleTreeVariant> get variants => F0869MapleTreeVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
