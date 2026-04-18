// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0809_doubling_map_presets.dart';
import 'f0809_doubling_map_variants.dart';
import 'f0809_doubling_map_metadata.dart';

/// Doubling Map — Strange Attractors.
class F0809DoublingMap extends AttractorModule {
  F0809DoublingMap()
      : super(
          id: 'f0809_doubling_map',
          shader: 'shaders/f0809_doubling_map_gpu.frag',
        );

  @override
  F0809DoublingMapMetadata get metadata => F0809DoublingMapMetadata.instance;

  @override
  List<F0809DoublingMapPreset> get presets => F0809DoublingMapPresets.all;

  @override
  List<F0809DoublingMapVariant> get variants => F0809DoublingMapVariants.all;

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
