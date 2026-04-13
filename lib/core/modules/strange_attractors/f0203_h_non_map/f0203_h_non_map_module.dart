// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0203_h_non_map_presets.dart';
import 'f0203_h_non_map_variants.dart';
import 'f0203_h_non_map_metadata.dart';

/// Hénon Map — Strange Attractors.
class F0203HNonMap extends AttractorModule {
  F0203HNonMap()
      : super(
          id: 'f0203_h_non_map',
          shader: 'shaders/f0203_h_non_map_gpu.frag',
        );

  @override
  F0203HNonMapMetadata get metadata => F0203HNonMapMetadata.instance;

  @override
  List<F0203HNonMapPreset> get presets => F0203HNonMapPresets.all;

  @override
  List<F0203HNonMapVariant> get variants => F0203HNonMapVariants.all;

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
