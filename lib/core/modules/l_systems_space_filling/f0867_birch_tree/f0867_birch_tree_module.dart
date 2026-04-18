// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0867_birch_tree_presets.dart';
import 'f0867_birch_tree_variants.dart';
import 'f0867_birch_tree_metadata.dart';

/// Birch Tree — L-Systems & Space-Filling.
class F0867BirchTree extends LSystemModule {
  F0867BirchTree()
      : super(
          id: 'f0867_birch_tree',
          shader: 'shaders/f0867_birch_tree_gpu.frag',
        );

  @override
  F0867BirchTreeMetadata get metadata => F0867BirchTreeMetadata.instance;

  @override
  List<F0867BirchTreePreset> get presets => F0867BirchTreePresets.all;

  @override
  List<F0867BirchTreeVariant> get variants => F0867BirchTreeVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
