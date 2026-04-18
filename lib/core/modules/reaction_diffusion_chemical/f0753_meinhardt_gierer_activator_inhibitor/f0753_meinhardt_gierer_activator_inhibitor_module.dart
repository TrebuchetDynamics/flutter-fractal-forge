// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0753_meinhardt_gierer_activator_inhibitor_presets.dart';
import 'f0753_meinhardt_gierer_activator_inhibitor_variants.dart';
import 'f0753_meinhardt_gierer_activator_inhibitor_metadata.dart';

/// Meinhardt-Gierer Activator-Inhibitor — Reaction-Diffusion & Chemical.
class F0753MeinhardtGiererActivatorInhibitor extends CellularModule {
  F0753MeinhardtGiererActivatorInhibitor()
      : super(
          id: 'f0753_meinhardt_gierer_activator_inhibitor',
          shader: 'shaders/f0753_meinhardt_gierer_activator_inhibitor_gpu.frag',
        );

  @override
  F0753MeinhardtGiererActivatorInhibitorMetadata get metadata => F0753MeinhardtGiererActivatorInhibitorMetadata.instance;

  @override
  List<F0753MeinhardtGiererActivatorInhibitorPreset> get presets => F0753MeinhardtGiererActivatorInhibitorPresets.all;

  @override
  List<F0753MeinhardtGiererActivatorInhibitorVariant> get variants => F0753MeinhardtGiererActivatorInhibitorVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
