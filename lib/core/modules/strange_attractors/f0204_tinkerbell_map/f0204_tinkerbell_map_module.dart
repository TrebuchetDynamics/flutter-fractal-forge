// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0204_tinkerbell_map_presets.dart';
import 'f0204_tinkerbell_map_variants.dart';
import 'f0204_tinkerbell_map_metadata.dart';

/// Tinkerbell Map — Strange Attractors.
class F0204TinkerbellMap extends AttractorModule {
  F0204TinkerbellMap()
      : super(
          id: 'f0204_tinkerbell_map',
          shader: 'shaders/f0204_tinkerbell_map_gpu.frag',
        );

  @override
  F0204TinkerbellMapMetadata get metadata => F0204TinkerbellMapMetadata.instance;

  @override
  List<F0204TinkerbellMapPreset> get presets => F0204TinkerbellMapPresets.all;

  @override
  List<F0204TinkerbellMapVariant> get variants => F0204TinkerbellMapVariants.all;

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
