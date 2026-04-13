// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0258_dragon_tree_hybrid_presets.dart';
import 'f0258_dragon_tree_hybrid_variants.dart';
import 'f0258_dragon_tree_hybrid_metadata.dart';

/// Dragon-Tree Hybrid — L-Systems & Space-Filling.
class F0258DragonTreeHybrid extends LSystemModule {
  F0258DragonTreeHybrid()
      : super(
          id: 'f0258_dragon_tree_hybrid',
          shader: 'shaders/f0258_dragon_tree_hybrid_gpu.frag',
        );

  @override
  F0258DragonTreeHybridMetadata get metadata => F0258DragonTreeHybridMetadata.instance;

  @override
  List<F0258DragonTreeHybridPreset> get presets => F0258DragonTreeHybridPresets.all;

  @override
  List<F0258DragonTreeHybridVariant> get variants => F0258DragonTreeHybridVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
