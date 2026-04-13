// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0279_binary_tree_ifs_presets.dart';
import 'f0279_binary_tree_ifs_variants.dart';
import 'f0279_binary_tree_ifs_metadata.dart';

/// Binary Tree IFS — IFS & Geometric Construction.
class F0279BinaryTreeIfs extends IFSModule {
  F0279BinaryTreeIfs()
      : super(
          id: 'f0279_binary_tree_ifs',
          shader: 'shaders/f0279_binary_tree_ifs_gpu.frag',
        );

  @override
  F0279BinaryTreeIfsMetadata get metadata => F0279BinaryTreeIfsMetadata.instance;

  @override
  List<F0279BinaryTreeIfsPreset> get presets => F0279BinaryTreeIfsPresets.all;

  @override
  List<F0279BinaryTreeIfsVariant> get variants => F0279BinaryTreeIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
