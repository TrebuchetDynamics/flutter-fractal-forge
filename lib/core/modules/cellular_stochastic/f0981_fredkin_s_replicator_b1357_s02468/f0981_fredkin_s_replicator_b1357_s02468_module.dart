// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0981_fredkin_s_replicator_b1357_s02468_presets.dart';
import 'f0981_fredkin_s_replicator_b1357_s02468_variants.dart';
import 'f0981_fredkin_s_replicator_b1357_s02468_metadata.dart';

/// Fredkin's Replicator (B1357/S02468) — Cellular & Stochastic.
class F0981FredkinSReplicatorB1357S02468 extends CellularModule {
  F0981FredkinSReplicatorB1357S02468()
      : super(
          id: 'f0981_fredkin_s_replicator_b1357_s02468',
          shader: 'shaders/f0981_fredkin_s_replicator_b1357_s02468_gpu.frag',
        );

  @override
  F0981FredkinSReplicatorB1357S02468Metadata get metadata => F0981FredkinSReplicatorB1357S02468Metadata.instance;

  @override
  List<F0981FredkinSReplicatorB1357S02468Preset> get presets => F0981FredkinSReplicatorB1357S02468Presets.all;

  @override
  List<F0981FredkinSReplicatorB1357S02468Variant> get variants => F0981FredkinSReplicatorB1357S02468Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
