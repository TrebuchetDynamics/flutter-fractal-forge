// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0783_p_adic_fractal_p_3_presets.dart';
import 'f0783_p_adic_fractal_p_3_variants.dart';
import 'f0783_p_adic_fractal_p_3_metadata.dart';

/// p-adic Fractal (p=3) — Number-Theory Fractals.
class F0783PAdicFractalP3 extends CellularModule {
  F0783PAdicFractalP3()
      : super(
          id: 'f0783_p_adic_fractal_p_3',
          shader: 'shaders/f0783_p_adic_fractal_p_3_gpu.frag',
        );

  @override
  F0783PAdicFractalP3Metadata get metadata => F0783PAdicFractalP3Metadata.instance;

  @override
  List<F0783PAdicFractalP3Preset> get presets => F0783PAdicFractalP3Presets.all;

  @override
  List<F0783PAdicFractalP3Variant> get variants => F0783PAdicFractalP3Variants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
