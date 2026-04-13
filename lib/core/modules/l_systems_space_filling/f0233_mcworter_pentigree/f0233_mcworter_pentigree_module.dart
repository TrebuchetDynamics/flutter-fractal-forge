// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0233_mcworter_pentigree_presets.dart';
import 'f0233_mcworter_pentigree_variants.dart';
import 'f0233_mcworter_pentigree_metadata.dart';

/// McWorter Pentigree — L-Systems & Space-Filling.
class F0233McworterPentigree extends LSystemModule {
  F0233McworterPentigree()
      : super(
          id: 'f0233_mcworter_pentigree',
          shader: 'shaders/f0233_mcworter_pentigree_gpu.frag',
        );

  @override
  F0233McworterPentigreeMetadata get metadata => F0233McworterPentigreeMetadata.instance;

  @override
  List<F0233McworterPentigreePreset> get presets => F0233McworterPentigreePresets.all;

  @override
  List<F0233McworterPentigreeVariant> get variants => F0233McworterPentigreeVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
