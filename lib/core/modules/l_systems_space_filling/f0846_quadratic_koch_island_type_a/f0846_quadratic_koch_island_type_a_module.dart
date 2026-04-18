// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0846_quadratic_koch_island_type_a_presets.dart';
import 'f0846_quadratic_koch_island_type_a_variants.dart';
import 'f0846_quadratic_koch_island_type_a_metadata.dart';

/// Quadratic Koch Island (Type A) — L-Systems & Space-Filling.
class F0846QuadraticKochIslandTypeA extends LSystemModule {
  F0846QuadraticKochIslandTypeA()
      : super(
          id: 'f0846_quadratic_koch_island_type_a',
          shader: 'shaders/f0846_quadratic_koch_island_type_a_gpu.frag',
        );

  @override
  F0846QuadraticKochIslandTypeAMetadata get metadata => F0846QuadraticKochIslandTypeAMetadata.instance;

  @override
  List<F0846QuadraticKochIslandTypeAPreset> get presets => F0846QuadraticKochIslandTypeAPresets.all;

  @override
  List<F0846QuadraticKochIslandTypeAVariant> get variants => F0846QuadraticKochIslandTypeAVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
