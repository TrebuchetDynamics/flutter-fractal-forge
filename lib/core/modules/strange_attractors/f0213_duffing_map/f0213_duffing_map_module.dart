// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0213_duffing_map_presets.dart';
import 'f0213_duffing_map_variants.dart';
import 'f0213_duffing_map_metadata.dart';

/// Duffing Map — Strange Attractors.
class F0213DuffingMap extends AttractorModule {
  F0213DuffingMap()
      : super(
          id: 'f0213_duffing_map',
          shader: 'shaders/f0213_duffing_map_gpu.frag',
        );

  @override
  F0213DuffingMapMetadata get metadata => F0213DuffingMapMetadata.instance;

  @override
  List<F0213DuffingMapPreset> get presets => F0213DuffingMapPresets.all;

  @override
  List<F0213DuffingMapVariant> get variants => F0213DuffingMapVariants.all;

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
