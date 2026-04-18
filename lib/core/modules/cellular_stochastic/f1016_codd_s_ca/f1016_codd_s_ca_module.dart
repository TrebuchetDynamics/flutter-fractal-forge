// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1016_codd_s_ca_presets.dart';
import 'f1016_codd_s_ca_variants.dart';
import 'f1016_codd_s_ca_metadata.dart';

/// Codd's CA — Cellular & Stochastic.
class F1016CoddSCa extends CellularModule {
  F1016CoddSCa()
      : super(
          id: 'f1016_codd_s_ca',
          shader: 'shaders/f1016_codd_s_ca_gpu.frag',
        );

  @override
  F1016CoddSCaMetadata get metadata => F1016CoddSCaMetadata.instance;

  @override
  List<F1016CoddSCaPreset> get presets => F1016CoddSCaPresets.all;

  @override
  List<F1016CoddSCaVariant> get variants => F1016CoddSCaVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
