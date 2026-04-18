// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1022_cyclic_ca_n_16_presets.dart';
import 'f1022_cyclic_ca_n_16_variants.dart';
import 'f1022_cyclic_ca_n_16_metadata.dart';

/// Cyclic CA (n=16) — Cellular & Stochastic.
class F1022CyclicCaN16 extends CellularModule {
  F1022CyclicCaN16()
      : super(
          id: 'f1022_cyclic_ca_n_16',
          shader: 'shaders/f1022_cyclic_ca_n_16_gpu.frag',
        );

  @override
  F1022CyclicCaN16Metadata get metadata => F1022CyclicCaN16Metadata.instance;

  @override
  List<F1022CyclicCaN16Preset> get presets => F1022CyclicCaN16Presets.all;

  @override
  List<F1022CyclicCaN16Variant> get variants => F1022CyclicCaN16Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
