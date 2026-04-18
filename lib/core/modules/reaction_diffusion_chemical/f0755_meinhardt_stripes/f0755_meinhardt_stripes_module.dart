// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0755_meinhardt_stripes_presets.dart';
import 'f0755_meinhardt_stripes_variants.dart';
import 'f0755_meinhardt_stripes_metadata.dart';

/// Meinhardt Stripes — Reaction-Diffusion & Chemical.
class F0755MeinhardtStripes extends CellularModule {
  F0755MeinhardtStripes()
      : super(
          id: 'f0755_meinhardt_stripes',
          shader: 'shaders/f0755_meinhardt_stripes_gpu.frag',
        );

  @override
  F0755MeinhardtStripesMetadata get metadata => F0755MeinhardtStripesMetadata.instance;

  @override
  List<F0755MeinhardtStripesPreset> get presets => F0755MeinhardtStripesPresets.all;

  @override
  List<F0755MeinhardtStripesVariant> get variants => F0755MeinhardtStripesVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
