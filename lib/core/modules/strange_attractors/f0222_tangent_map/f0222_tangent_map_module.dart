// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0222_tangent_map_presets.dart';
import 'f0222_tangent_map_variants.dart';
import 'f0222_tangent_map_metadata.dart';

/// Tangent Map — Strange Attractors.
class F0222TangentMap extends AttractorModule {
  F0222TangentMap()
      : super(
          id: 'f0222_tangent_map',
          shader: 'shaders/f0222_tangent_map_gpu.frag',
        );

  @override
  F0222TangentMapMetadata get metadata => F0222TangentMapMetadata.instance;

  @override
  List<F0222TangentMapPreset> get presets => F0222TangentMapPresets.all;

  @override
  List<F0222TangentMapVariant> get variants => F0222TangentMapVariants.all;

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
