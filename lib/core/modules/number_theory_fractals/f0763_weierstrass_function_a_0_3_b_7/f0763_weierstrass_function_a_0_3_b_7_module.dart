// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0763_weierstrass_function_a_0_3_b_7_presets.dart';
import 'f0763_weierstrass_function_a_0_3_b_7_variants.dart';
import 'f0763_weierstrass_function_a_0_3_b_7_metadata.dart';

/// Weierstrass Function (a=0.3, b=7) — Number-Theory Fractals.
class F0763WeierstrassFunctionA03B7 extends CellularModule {
  F0763WeierstrassFunctionA03B7()
      : super(
          id: 'f0763_weierstrass_function_a_0_3_b_7',
          shader: 'shaders/f0763_weierstrass_function_a_0_3_b_7_gpu.frag',
        );

  @override
  F0763WeierstrassFunctionA03B7Metadata get metadata => F0763WeierstrassFunctionA03B7Metadata.instance;

  @override
  List<F0763WeierstrassFunctionA03B7Preset> get presets => F0763WeierstrassFunctionA03B7Presets.all;

  @override
  List<F0763WeierstrassFunctionA03B7Variant> get variants => F0763WeierstrassFunctionA03B7Variants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
