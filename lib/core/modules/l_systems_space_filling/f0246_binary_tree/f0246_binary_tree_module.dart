// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0246_binary_tree_presets.dart';
import 'f0246_binary_tree_variants.dart';
import 'f0246_binary_tree_metadata.dart';

/// Binary Tree — L-Systems & Space-Filling.
class F0246BinaryTree extends LSystemModule {
  F0246BinaryTree()
      : super(
          id: 'f0246_binary_tree',
          shader: 'shaders/f0246_binary_tree_gpu.frag',
        );

  @override
  F0246BinaryTreeMetadata get metadata => F0246BinaryTreeMetadata.instance;

  @override
  List<F0246BinaryTreePreset> get presets => F0246BinaryTreePresets.all;

  @override
  List<F0246BinaryTreeVariant> get variants => F0246BinaryTreeVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
