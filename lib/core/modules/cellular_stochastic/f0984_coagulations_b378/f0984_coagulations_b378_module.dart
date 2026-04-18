// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0984_coagulations_b378_presets.dart';
import 'f0984_coagulations_b378_variants.dart';
import 'f0984_coagulations_b378_metadata.dart';

/// Coagulations B378 — Cellular & Stochastic.
class F0984CoagulationsB378 extends CellularModule {
  F0984CoagulationsB378()
      : super(
          id: 'f0984_coagulations_b378',
          shader: 'shaders/f0984_coagulations_b378_gpu.frag',
        );

  @override
  F0984CoagulationsB378Metadata get metadata => F0984CoagulationsB378Metadata.instance;

  @override
  List<F0984CoagulationsB378Preset> get presets => F0984CoagulationsB378Presets.all;

  @override
  List<F0984CoagulationsB378Variant> get variants => F0984CoagulationsB378Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
