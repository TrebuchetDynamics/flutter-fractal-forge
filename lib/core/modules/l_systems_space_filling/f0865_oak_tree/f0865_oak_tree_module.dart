// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0865_oak_tree_presets.dart';
import 'f0865_oak_tree_variants.dart';
import 'f0865_oak_tree_metadata.dart';

/// Oak Tree — L-Systems & Space-Filling.
class F0865OakTree extends LSystemModule {
  F0865OakTree()
      : super(
          id: 'f0865_oak_tree',
          shader: 'shaders/f0865_oak_tree_gpu.frag',
        );

  @override
  F0865OakTreeMetadata get metadata => F0865OakTreeMetadata.instance;

  @override
  List<F0865OakTreePreset> get presets => F0865OakTreePresets.all;

  @override
  List<F0865OakTreeVariant> get variants => F0865OakTreeVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
