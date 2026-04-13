// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0277_twin_christmas_tree_presets.dart';
import 'f0277_twin_christmas_tree_variants.dart';
import 'f0277_twin_christmas_tree_metadata.dart';

/// Twin Christmas Tree — IFS & Geometric Construction.
class F0277TwinChristmasTree extends IFSModule {
  F0277TwinChristmasTree()
      : super(
          id: 'f0277_twin_christmas_tree',
          shader: 'shaders/f0277_twin_christmas_tree_gpu.frag',
        );

  @override
  F0277TwinChristmasTreeMetadata get metadata => F0277TwinChristmasTreeMetadata.instance;

  @override
  List<F0277TwinChristmasTreePreset> get presets => F0277TwinChristmasTreePresets.all;

  @override
  List<F0277TwinChristmasTreeVariant> get variants => F0277TwinChristmasTreeVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
