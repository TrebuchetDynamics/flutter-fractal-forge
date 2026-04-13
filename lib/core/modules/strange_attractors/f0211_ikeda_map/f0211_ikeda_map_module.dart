// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0211_ikeda_map_presets.dart';
import 'f0211_ikeda_map_variants.dart';
import 'f0211_ikeda_map_metadata.dart';

/// Ikeda Map — Strange Attractors.
class F0211IkedaMap extends AttractorModule {
  F0211IkedaMap()
      : super(
          id: 'f0211_ikeda_map',
          shader: 'shaders/f0211_ikeda_map_gpu.frag',
        );

  @override
  F0211IkedaMapMetadata get metadata => F0211IkedaMapMetadata.instance;

  @override
  List<F0211IkedaMapPreset> get presets => F0211IkedaMapPresets.all;

  @override
  List<F0211IkedaMapVariant> get variants => F0211IkedaMapVariants.all;

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
