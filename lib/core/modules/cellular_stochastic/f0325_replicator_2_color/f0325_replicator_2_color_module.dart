// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0325_replicator_2_color_presets.dart';
import 'f0325_replicator_2_color_variants.dart';
import 'f0325_replicator_2_color_metadata.dart';

/// Replicator (2-color) — Cellular & Stochastic.
class F0325Replicator2Color extends CellularModule {
  F0325Replicator2Color()
      : super(
          id: 'f0325_replicator_2_color',
          shader: 'shaders/f0325_replicator_2_color_gpu.frag',
        );

  @override
  F0325Replicator2ColorMetadata get metadata => F0325Replicator2ColorMetadata.instance;

  @override
  List<F0325Replicator2ColorPreset> get presets => F0325Replicator2ColorPresets.all;

  @override
  List<F0325Replicator2ColorVariant> get variants => F0325Replicator2ColorVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
