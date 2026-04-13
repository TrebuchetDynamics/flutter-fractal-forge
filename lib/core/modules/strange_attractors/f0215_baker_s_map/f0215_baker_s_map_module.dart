// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0215_baker_s_map_presets.dart';
import 'f0215_baker_s_map_variants.dart';
import 'f0215_baker_s_map_metadata.dart';

/// Baker's Map — Strange Attractors.
class F0215BakerSMap extends AttractorModule {
  F0215BakerSMap()
      : super(
          id: 'f0215_baker_s_map',
          shader: 'shaders/f0215_baker_s_map_gpu.frag',
        );

  @override
  F0215BakerSMapMetadata get metadata => F0215BakerSMapMetadata.instance;

  @override
  List<F0215BakerSMapPreset> get presets => F0215BakerSMapPresets.all;

  @override
  List<F0215BakerSMapVariant> get variants => F0215BakerSMapVariants.all;

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
