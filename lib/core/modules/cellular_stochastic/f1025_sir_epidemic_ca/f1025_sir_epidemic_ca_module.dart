// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1025_sir_epidemic_ca_presets.dart';
import 'f1025_sir_epidemic_ca_variants.dart';
import 'f1025_sir_epidemic_ca_metadata.dart';

/// SIR Epidemic CA — Cellular & Stochastic.
class F1025SirEpidemicCa extends CellularModule {
  F1025SirEpidemicCa()
      : super(
          id: 'f1025_sir_epidemic_ca',
          shader: 'shaders/f1025_sir_epidemic_ca_gpu.frag',
        );

  @override
  F1025SirEpidemicCaMetadata get metadata => F1025SirEpidemicCaMetadata.instance;

  @override
  List<F1025SirEpidemicCaPreset> get presets => F1025SirEpidemicCaPresets.all;

  @override
  List<F1025SirEpidemicCaVariant> get variants => F1025SirEpidemicCaVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
