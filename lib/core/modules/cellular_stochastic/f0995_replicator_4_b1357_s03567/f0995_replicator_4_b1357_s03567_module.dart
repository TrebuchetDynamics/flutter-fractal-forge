// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0995_replicator_4_b1357_s03567_presets.dart';
import 'f0995_replicator_4_b1357_s03567_variants.dart';
import 'f0995_replicator_4_b1357_s03567_metadata.dart';

/// Replicator 4 (B1357/S03567) — Cellular & Stochastic.
class F0995Replicator4B1357S03567 extends CellularModule {
  F0995Replicator4B1357S03567()
      : super(
          id: 'f0995_replicator_4_b1357_s03567',
          shader: 'shaders/f0995_replicator_4_b1357_s03567_gpu.frag',
        );

  @override
  F0995Replicator4B1357S03567Metadata get metadata => F0995Replicator4B1357S03567Metadata.instance;

  @override
  List<F0995Replicator4B1357S03567Preset> get presets => F0995Replicator4B1357S03567Presets.all;

  @override
  List<F0995Replicator4B1357S03567Variant> get variants => F0995Replicator4B1357S03567Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
