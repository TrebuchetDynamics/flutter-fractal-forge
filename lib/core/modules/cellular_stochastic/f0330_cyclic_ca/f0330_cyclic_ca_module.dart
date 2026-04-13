// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0330_cyclic_ca_presets.dart';
import 'f0330_cyclic_ca_variants.dart';
import 'f0330_cyclic_ca_metadata.dart';

/// Cyclic CA — Cellular & Stochastic.
class F0330CyclicCa extends CellularModule {
  F0330CyclicCa()
      : super(
          id: 'f0330_cyclic_ca',
          shader: 'shaders/f0330_cyclic_ca_gpu.frag',
        );

  @override
  F0330CyclicCaMetadata get metadata => F0330CyclicCaMetadata.instance;

  @override
  List<F0330CyclicCaPreset> get presets => F0330CyclicCaPresets.all;

  @override
  List<F0330CyclicCaVariant> get variants => F0330CyclicCaVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
