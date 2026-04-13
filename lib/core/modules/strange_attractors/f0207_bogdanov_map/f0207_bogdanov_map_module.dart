// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0207_bogdanov_map_presets.dart';
import 'f0207_bogdanov_map_variants.dart';
import 'f0207_bogdanov_map_metadata.dart';

/// Bogdanov Map — Strange Attractors.
class F0207BogdanovMap extends AttractorModule {
  F0207BogdanovMap()
      : super(
          id: 'f0207_bogdanov_map',
          shader: 'shaders/f0207_bogdanov_map_gpu.frag',
        );

  @override
  F0207BogdanovMapMetadata get metadata => F0207BogdanovMapMetadata.instance;

  @override
  List<F0207BogdanovMapPreset> get presets => F0207BogdanovMapPresets.all;

  @override
  List<F0207BogdanovMapVariant> get variants => F0207BogdanovMapVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
