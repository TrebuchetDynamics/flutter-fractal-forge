// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0781_beta_expansion_fractal_phi_presets.dart';
import 'f0781_beta_expansion_fractal_phi_variants.dart';
import 'f0781_beta_expansion_fractal_phi_metadata.dart';

/// Beta-Expansion Fractal (phi) — Number-Theory Fractals.
class F0781BetaExpansionFractalPhi extends CellularModule {
  F0781BetaExpansionFractalPhi()
      : super(
          id: 'f0781_beta_expansion_fractal_phi',
          shader: 'shaders/f0781_beta_expansion_fractal_phi_gpu.frag',
        );

  @override
  F0781BetaExpansionFractalPhiMetadata get metadata => F0781BetaExpansionFractalPhiMetadata.instance;

  @override
  List<F0781BetaExpansionFractalPhiPreset> get presets => F0781BetaExpansionFractalPhiPresets.all;

  @override
  List<F0781BetaExpansionFractalPhiVariant> get variants => F0781BetaExpansionFractalPhiVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
