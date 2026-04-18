// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0784_p_adic_fractal_p_5_presets.dart';
import 'f0784_p_adic_fractal_p_5_variants.dart';
import 'f0784_p_adic_fractal_p_5_metadata.dart';

/// p-adic Fractal (p=5) — Number-Theory Fractals.
class F0784PAdicFractalP5 extends CellularModule {
  F0784PAdicFractalP5()
      : super(
          id: 'f0784_p_adic_fractal_p_5',
          shader: 'shaders/f0784_p_adic_fractal_p_5_gpu.frag',
        );

  @override
  F0784PAdicFractalP5Metadata get metadata => F0784PAdicFractalP5Metadata.instance;

  @override
  List<F0784PAdicFractalP5Preset> get presets => F0784PAdicFractalP5Presets.all;

  @override
  List<F0784PAdicFractalP5Variant> get variants => F0784PAdicFractalP5Variants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
