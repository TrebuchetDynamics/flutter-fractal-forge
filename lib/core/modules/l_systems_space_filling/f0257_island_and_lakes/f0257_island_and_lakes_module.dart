// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0257_island_and_lakes_presets.dart';
import 'f0257_island_and_lakes_variants.dart';
import 'f0257_island_and_lakes_metadata.dart';

/// Island and Lakes — L-Systems & Space-Filling.
class F0257IslandAndLakes extends LSystemModule {
  F0257IslandAndLakes()
      : super(
          id: 'f0257_island_and_lakes',
          shader: 'shaders/f0257_island_and_lakes_gpu.frag',
        );

  @override
  F0257IslandAndLakesMetadata get metadata => F0257IslandAndLakesMetadata.instance;

  @override
  List<F0257IslandAndLakesPreset> get presets => F0257IslandAndLakesPresets.all;

  @override
  List<F0257IslandAndLakesVariant> get variants => F0257IslandAndLakesVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
