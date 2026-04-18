// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0988_pseudo_life_b357_s238_presets.dart';
import 'f0988_pseudo_life_b357_s238_variants.dart';
import 'f0988_pseudo_life_b357_s238_metadata.dart';

/// Pseudo Life (B357/S238) — Cellular & Stochastic.
class F0988PseudoLifeB357S238 extends CellularModule {
  F0988PseudoLifeB357S238()
      : super(
          id: 'f0988_pseudo_life_b357_s238',
          shader: 'shaders/f0988_pseudo_life_b357_s238_gpu.frag',
        );

  @override
  F0988PseudoLifeB357S238Metadata get metadata => F0988PseudoLifeB357S238Metadata.instance;

  @override
  List<F0988PseudoLifeB357S238Preset> get presets => F0988PseudoLifeB357S238Presets.all;

  @override
  List<F0988PseudoLifeB357S238Variant> get variants => F0988PseudoLifeB357S238Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
