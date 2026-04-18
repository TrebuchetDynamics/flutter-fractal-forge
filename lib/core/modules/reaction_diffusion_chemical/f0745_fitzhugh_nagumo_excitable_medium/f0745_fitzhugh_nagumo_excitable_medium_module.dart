// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0745_fitzhugh_nagumo_excitable_medium_presets.dart';
import 'f0745_fitzhugh_nagumo_excitable_medium_variants.dart';
import 'f0745_fitzhugh_nagumo_excitable_medium_metadata.dart';

/// FitzHugh-Nagumo (Excitable Medium) — Reaction-Diffusion & Chemical.
class F0745FitzhughNagumoExcitableMedium extends CellularModule {
  F0745FitzhughNagumoExcitableMedium()
      : super(
          id: 'f0745_fitzhugh_nagumo_excitable_medium',
          shader: 'shaders/f0745_fitzhugh_nagumo_excitable_medium_gpu.frag',
        );

  @override
  F0745FitzhughNagumoExcitableMediumMetadata get metadata => F0745FitzhughNagumoExcitableMediumMetadata.instance;

  @override
  List<F0745FitzhughNagumoExcitableMediumPreset> get presets => F0745FitzhughNagumoExcitableMediumPresets.all;

  @override
  List<F0745FitzhughNagumoExcitableMediumVariant> get variants => F0745FitzhughNagumoExcitableMediumVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
