// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0216_horseshoe_map_presets.dart';
import 'f0216_horseshoe_map_variants.dart';
import 'f0216_horseshoe_map_metadata.dart';

/// Horseshoe Map — Strange Attractors.
class F0216HorseshoeMap extends AttractorModule {
  F0216HorseshoeMap()
      : super(
          id: 'f0216_horseshoe_map',
          shader: 'shaders/f0216_horseshoe_map_gpu.frag',
        );

  @override
  F0216HorseshoeMapMetadata get metadata => F0216HorseshoeMapMetadata.instance;

  @override
  List<F0216HorseshoeMapPreset> get presets => F0216HorseshoeMapPresets.all;

  @override
  List<F0216HorseshoeMapVariant> get variants => F0216HorseshoeMapVariants.all;

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
