// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0824_sinai_map_presets.dart';
import 'f0824_sinai_map_variants.dart';
import 'f0824_sinai_map_metadata.dart';

/// Sinai Map — Strange Attractors.
class F0824SinaiMap extends AttractorModule {
  F0824SinaiMap()
      : super(
          id: 'f0824_sinai_map',
          shader: 'shaders/f0824_sinai_map_gpu.frag',
        );

  @override
  F0824SinaiMapMetadata get metadata => F0824SinaiMapMetadata.instance;

  @override
  List<F0824SinaiMapPreset> get presets => F0824SinaiMapPresets.all;

  @override
  List<F0824SinaiMapVariant> get variants => F0824SinaiMapVariants.all;

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
