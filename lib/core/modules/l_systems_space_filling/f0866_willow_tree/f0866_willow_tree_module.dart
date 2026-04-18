// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0866_willow_tree_presets.dart';
import 'f0866_willow_tree_variants.dart';
import 'f0866_willow_tree_metadata.dart';

/// Willow Tree — L-Systems & Space-Filling.
class F0866WillowTree extends LSystemModule {
  F0866WillowTree()
      : super(
          id: 'f0866_willow_tree',
          shader: 'shaders/f0866_willow_tree_gpu.frag',
        );

  @override
  F0866WillowTreeMetadata get metadata => F0866WillowTreeMetadata.instance;

  @override
  List<F0866WillowTreePreset> get presets => F0866WillowTreePresets.all;

  @override
  List<F0866WillowTreeVariant> get variants => F0866WillowTreeVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
