// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0980_replicator_b1357_s1357_presets.dart';
import 'f0980_replicator_b1357_s1357_variants.dart';
import 'f0980_replicator_b1357_s1357_metadata.dart';

/// Replicator (B1357/S1357) — Cellular & Stochastic.
class F0980ReplicatorB1357S1357 extends CellularModule {
  F0980ReplicatorB1357S1357()
      : super(
          id: 'f0980_replicator_b1357_s1357',
          shader: 'shaders/f0980_replicator_b1357_s1357_gpu.frag',
        );

  @override
  F0980ReplicatorB1357S1357Metadata get metadata => F0980ReplicatorB1357S1357Metadata.instance;

  @override
  List<F0980ReplicatorB1357S1357Preset> get presets => F0980ReplicatorB1357S1357Presets.all;

  @override
  List<F0980ReplicatorB1357S1357Variant> get variants => F0980ReplicatorB1357S1357Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
