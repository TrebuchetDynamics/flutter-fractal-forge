// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0746_fitzhugh_nagumo_spirals_presets.dart';
import 'f0746_fitzhugh_nagumo_spirals_variants.dart';
import 'f0746_fitzhugh_nagumo_spirals_metadata.dart';

/// FitzHugh-Nagumo Spirals — Reaction-Diffusion & Chemical.
class F0746FitzhughNagumoSpirals extends CellularModule {
  F0746FitzhughNagumoSpirals()
      : super(
          id: 'f0746_fitzhugh_nagumo_spirals',
          shader: 'shaders/f0746_fitzhugh_nagumo_spirals_gpu.frag',
        );

  @override
  F0746FitzhughNagumoSpiralsMetadata get metadata => F0746FitzhughNagumoSpiralsMetadata.instance;

  @override
  List<F0746FitzhughNagumoSpiralsPreset> get presets => F0746FitzhughNagumoSpiralsPresets.all;

  @override
  List<F0746FitzhughNagumoSpiralsVariant> get variants => F0746FitzhughNagumoSpiralsVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
