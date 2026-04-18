// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0829_feigenbaum_universal_map_presets.dart';
import 'f0829_feigenbaum_universal_map_variants.dart';
import 'f0829_feigenbaum_universal_map_metadata.dart';

/// Feigenbaum Universal Map — Strange Attractors.
class F0829FeigenbaumUniversalMap extends AttractorModule {
  F0829FeigenbaumUniversalMap()
      : super(
          id: 'f0829_feigenbaum_universal_map',
          shader: 'shaders/f0829_feigenbaum_universal_map_gpu.frag',
        );

  @override
  F0829FeigenbaumUniversalMapMetadata get metadata => F0829FeigenbaumUniversalMapMetadata.instance;

  @override
  List<F0829FeigenbaumUniversalMapPreset> get presets => F0829FeigenbaumUniversalMapPresets.all;

  @override
  List<F0829FeigenbaumUniversalMapVariant> get variants => F0829FeigenbaumUniversalMapVariants.all;

  @override
  int get defaultIterations => 50000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
