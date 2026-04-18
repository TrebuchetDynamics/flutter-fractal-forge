// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0838_gosper_island_presets.dart';
import 'f0838_gosper_island_variants.dart';
import 'f0838_gosper_island_metadata.dart';

/// Gosper Island — L-Systems & Space-Filling.
class F0838GosperIsland extends LSystemModule {
  F0838GosperIsland()
      : super(
          id: 'f0838_gosper_island',
          shader: 'shaders/f0838_gosper_island_gpu.frag',
        );

  @override
  F0838GosperIslandMetadata get metadata => F0838GosperIslandMetadata.instance;

  @override
  List<F0838GosperIslandPreset> get presets => F0838GosperIslandPresets.all;

  @override
  List<F0838GosperIslandVariant> get variants => F0838GosperIslandVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
