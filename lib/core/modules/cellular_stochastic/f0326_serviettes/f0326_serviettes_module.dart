// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0326_serviettes_presets.dart';
import 'f0326_serviettes_variants.dart';
import 'f0326_serviettes_metadata.dart';

/// Serviettes — Cellular & Stochastic.
class F0326Serviettes extends CellularModule {
  F0326Serviettes()
      : super(
          id: 'f0326_serviettes',
          shader: 'shaders/f0326_serviettes_gpu.frag',
        );

  @override
  F0326ServiettesMetadata get metadata => F0326ServiettesMetadata.instance;

  @override
  List<F0326ServiettesPreset> get presets => F0326ServiettesPresets.all;

  @override
  List<F0326ServiettesVariant> get variants => F0326ServiettesVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
