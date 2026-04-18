// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0747_fitzhugh_nagumo_turbulence_presets.dart';
import 'f0747_fitzhugh_nagumo_turbulence_variants.dart';
import 'f0747_fitzhugh_nagumo_turbulence_metadata.dart';

/// FitzHugh-Nagumo Turbulence — Reaction-Diffusion & Chemical.
class F0747FitzhughNagumoTurbulence extends CellularModule {
  F0747FitzhughNagumoTurbulence()
      : super(
          id: 'f0747_fitzhugh_nagumo_turbulence',
          shader: 'shaders/f0747_fitzhugh_nagumo_turbulence_gpu.frag',
        );

  @override
  F0747FitzhughNagumoTurbulenceMetadata get metadata => F0747FitzhughNagumoTurbulenceMetadata.instance;

  @override
  List<F0747FitzhughNagumoTurbulencePreset> get presets => F0747FitzhughNagumoTurbulencePresets.all;

  @override
  List<F0747FitzhughNagumoTurbulenceVariant> get variants => F0747FitzhughNagumoTurbulenceVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
