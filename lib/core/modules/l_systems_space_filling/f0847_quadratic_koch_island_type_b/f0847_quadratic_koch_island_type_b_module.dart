// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0847_quadratic_koch_island_type_b_presets.dart';
import 'f0847_quadratic_koch_island_type_b_variants.dart';
import 'f0847_quadratic_koch_island_type_b_metadata.dart';

/// Quadratic Koch Island (Type B) — L-Systems & Space-Filling.
class F0847QuadraticKochIslandTypeB extends LSystemModule {
  F0847QuadraticKochIslandTypeB()
      : super(
          id: 'f0847_quadratic_koch_island_type_b',
          shader: 'shaders/f0847_quadratic_koch_island_type_b_gpu.frag',
        );

  @override
  F0847QuadraticKochIslandTypeBMetadata get metadata => F0847QuadraticKochIslandTypeBMetadata.instance;

  @override
  List<F0847QuadraticKochIslandTypeBPreset> get presets => F0847QuadraticKochIslandTypeBPresets.all;

  @override
  List<F0847QuadraticKochIslandTypeBVariant> get variants => F0847QuadraticKochIslandTypeBVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
