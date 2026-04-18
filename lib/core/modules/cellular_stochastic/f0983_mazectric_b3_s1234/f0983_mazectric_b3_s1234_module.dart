// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0983_mazectric_b3_s1234_presets.dart';
import 'f0983_mazectric_b3_s1234_variants.dart';
import 'f0983_mazectric_b3_s1234_metadata.dart';

/// Mazectric (B3/S1234) — Cellular & Stochastic.
class F0983MazectricB3S1234 extends CellularModule {
  F0983MazectricB3S1234()
      : super(
          id: 'f0983_mazectric_b3_s1234',
          shader: 'shaders/f0983_mazectric_b3_s1234_gpu.frag',
        );

  @override
  F0983MazectricB3S1234Metadata get metadata => F0983MazectricB3S1234Metadata.instance;

  @override
  List<F0983MazectricB3S1234Preset> get presets => F0983MazectricB3S1234Presets.all;

  @override
  List<F0983MazectricB3S1234Variant> get variants => F0983MazectricB3S1234Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
