// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1021_cyclic_ca_n_4_presets.dart';
import 'f1021_cyclic_ca_n_4_variants.dart';
import 'f1021_cyclic_ca_n_4_metadata.dart';

/// Cyclic CA (n=4) — Cellular & Stochastic.
class F1021CyclicCaN4 extends CellularModule {
  F1021CyclicCaN4()
      : super(
          id: 'f1021_cyclic_ca_n_4',
          shader: 'shaders/f1021_cyclic_ca_n_4_gpu.frag',
        );

  @override
  F1021CyclicCaN4Metadata get metadata => F1021CyclicCaN4Metadata.instance;

  @override
  List<F1021CyclicCaN4Preset> get presets => F1021CyclicCaN4Presets.all;

  @override
  List<F1021CyclicCaN4Variant> get variants => F1021CyclicCaN4Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
