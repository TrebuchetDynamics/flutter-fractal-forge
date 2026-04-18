// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0782_beta_expansion_fractal_sqrt2_presets.dart';
import 'f0782_beta_expansion_fractal_sqrt2_variants.dart';
import 'f0782_beta_expansion_fractal_sqrt2_metadata.dart';

/// Beta-Expansion Fractal (sqrt2) — Number-Theory Fractals.
class F0782BetaExpansionFractalSqrt2 extends CellularModule {
  F0782BetaExpansionFractalSqrt2()
      : super(
          id: 'f0782_beta_expansion_fractal_sqrt2',
          shader: 'shaders/f0782_beta_expansion_fractal_sqrt2_gpu.frag',
        );

  @override
  F0782BetaExpansionFractalSqrt2Metadata get metadata => F0782BetaExpansionFractalSqrt2Metadata.instance;

  @override
  List<F0782BetaExpansionFractalSqrt2Preset> get presets => F0782BetaExpansionFractalSqrt2Presets.all;

  @override
  List<F0782BetaExpansionFractalSqrt2Variant> get variants => F0782BetaExpansionFractalSqrt2Variants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
