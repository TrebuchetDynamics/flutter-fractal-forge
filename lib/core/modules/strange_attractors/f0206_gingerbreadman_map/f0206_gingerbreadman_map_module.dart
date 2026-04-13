// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0206_gingerbreadman_map_presets.dart';
import 'f0206_gingerbreadman_map_variants.dart';
import 'f0206_gingerbreadman_map_metadata.dart';

/// Gingerbreadman Map — Strange Attractors.
class F0206GingerbreadmanMap extends AttractorModule {
  F0206GingerbreadmanMap()
      : super(
          id: 'f0206_gingerbreadman_map',
          shader: 'shaders/f0206_gingerbreadman_map_gpu.frag',
        );

  @override
  F0206GingerbreadmanMapMetadata get metadata => F0206GingerbreadmanMapMetadata.instance;

  @override
  List<F0206GingerbreadmanMapPreset> get presets => F0206GingerbreadmanMapPresets.all;

  @override
  List<F0206GingerbreadmanMapVariant> get variants => F0206GingerbreadmanMapVariants.all;

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
