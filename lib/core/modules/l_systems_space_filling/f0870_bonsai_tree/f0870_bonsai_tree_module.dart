// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0870_bonsai_tree_presets.dart';
import 'f0870_bonsai_tree_variants.dart';
import 'f0870_bonsai_tree_metadata.dart';

/// Bonsai Tree — L-Systems & Space-Filling.
class F0870BonsaiTree extends LSystemModule {
  F0870BonsaiTree()
      : super(
          id: 'f0870_bonsai_tree',
          shader: 'shaders/f0870_bonsai_tree_gpu.frag',
        );

  @override
  F0870BonsaiTreeMetadata get metadata => F0870BonsaiTreeMetadata.instance;

  @override
  List<F0870BonsaiTreePreset> get presets => F0870BonsaiTreePresets.all;

  @override
  List<F0870BonsaiTreeVariant> get variants => F0870BonsaiTreeVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
