// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1008_honey_life_b38_s238_presets.dart';
import 'f1008_honey_life_b38_s238_variants.dart';
import 'f1008_honey_life_b38_s238_metadata.dart';

/// Honey Life (B38/S238) — Cellular & Stochastic.
class F1008HoneyLifeB38S238 extends CellularModule {
  F1008HoneyLifeB38S238()
      : super(
          id: 'f1008_honey_life_b38_s238',
          shader: 'shaders/f1008_honey_life_b38_s238_gpu.frag',
        );

  @override
  F1008HoneyLifeB38S238Metadata get metadata => F1008HoneyLifeB38S238Metadata.instance;

  @override
  List<F1008HoneyLifeB38S238Preset> get presets => F1008HoneyLifeB38S238Presets.all;

  @override
  List<F1008HoneyLifeB38S238Variant> get variants => F1008HoneyLifeB38S238Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
