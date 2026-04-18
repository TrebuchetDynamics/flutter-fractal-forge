// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0826_baker_s_map_presets.dart';
import 'f0826_baker_s_map_variants.dart';
import 'f0826_baker_s_map_metadata.dart';

/// Baker's Map — Strange Attractors.
class F0826BakerSMap extends AttractorModule {
  F0826BakerSMap()
      : super(
          id: 'f0826_baker_s_map',
          shader: 'shaders/f0826_baker_s_map_gpu.frag',
        );

  @override
  F0826BakerSMapMetadata get metadata => F0826BakerSMapMetadata.instance;

  @override
  List<F0826BakerSMapPreset> get presets => F0826BakerSMapPresets.all;

  @override
  List<F0826BakerSMapVariant> get variants => F0826BakerSMapVariants.all;

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
