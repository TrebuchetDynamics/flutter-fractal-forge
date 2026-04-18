// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0992_dot_life_b3_s023_presets.dart';
import 'f0992_dot_life_b3_s023_variants.dart';
import 'f0992_dot_life_b3_s023_metadata.dart';

/// Dot Life (B3/S023) — Cellular & Stochastic.
class F0992DotLifeB3S023 extends CellularModule {
  F0992DotLifeB3S023()
      : super(
          id: 'f0992_dot_life_b3_s023',
          shader: 'shaders/f0992_dot_life_b3_s023_gpu.frag',
        );

  @override
  F0992DotLifeB3S023Metadata get metadata => F0992DotLifeB3S023Metadata.instance;

  @override
  List<F0992DotLifeB3S023Preset> get presets => F0992DotLifeB3S023Presets.all;

  @override
  List<F0992DotLifeB3S023Variant> get variants => F0992DotLifeB3S023Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
