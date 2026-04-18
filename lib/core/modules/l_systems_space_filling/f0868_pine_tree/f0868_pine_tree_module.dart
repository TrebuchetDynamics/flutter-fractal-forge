// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0868_pine_tree_presets.dart';
import 'f0868_pine_tree_variants.dart';
import 'f0868_pine_tree_metadata.dart';

/// Pine Tree — L-Systems & Space-Filling.
class F0868PineTree extends LSystemModule {
  F0868PineTree()
      : super(
          id: 'f0868_pine_tree',
          shader: 'shaders/f0868_pine_tree_gpu.frag',
        );

  @override
  F0868PineTreeMetadata get metadata => F0868PineTreeMetadata.instance;

  @override
  List<F0868PineTreePreset> get presets => F0868PineTreePresets.all;

  @override
  List<F0868PineTreeVariant> get variants => F0868PineTreeVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
