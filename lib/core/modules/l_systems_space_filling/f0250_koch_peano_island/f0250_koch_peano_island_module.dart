// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0250_koch_peano_island_presets.dart';
import 'f0250_koch_peano_island_variants.dart';
import 'f0250_koch_peano_island_metadata.dart';

/// Koch-Peano Island — L-Systems & Space-Filling.
class F0250KochPeanoIsland extends LSystemModule {
  F0250KochPeanoIsland()
      : super(
          id: 'f0250_koch_peano_island',
          shader: 'shaders/f0250_koch_peano_island_gpu.frag',
        );

  @override
  F0250KochPeanoIslandMetadata get metadata => F0250KochPeanoIslandMetadata.instance;

  @override
  List<F0250KochPeanoIslandPreset> get presets => F0250KochPeanoIslandPresets.all;

  @override
  List<F0250KochPeanoIslandVariant> get variants => F0250KochPeanoIslandVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
