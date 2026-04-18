// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0751_lengyel_epstein_cima_presets.dart';
import 'f0751_lengyel_epstein_cima_variants.dart';
import 'f0751_lengyel_epstein_cima_metadata.dart';

/// Lengyel-Epstein CIMA — Reaction-Diffusion & Chemical.
class F0751LengyelEpsteinCima extends CellularModule {
  F0751LengyelEpsteinCima()
      : super(
          id: 'f0751_lengyel_epstein_cima',
          shader: 'shaders/f0751_lengyel_epstein_cima_gpu.frag',
        );

  @override
  F0751LengyelEpsteinCimaMetadata get metadata => F0751LengyelEpsteinCimaMetadata.instance;

  @override
  List<F0751LengyelEpsteinCimaPreset> get presets => F0751LengyelEpsteinCimaPresets.all;

  @override
  List<F0751LengyelEpsteinCimaVariant> get variants => F0751LengyelEpsteinCimaVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
