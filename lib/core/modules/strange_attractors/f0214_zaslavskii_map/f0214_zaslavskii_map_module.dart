// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0214_zaslavskii_map_presets.dart';
import 'f0214_zaslavskii_map_variants.dart';
import 'f0214_zaslavskii_map_metadata.dart';

/// Zaslavskii Map — Strange Attractors.
class F0214ZaslavskiiMap extends AttractorModule {
  F0214ZaslavskiiMap()
      : super(
          id: 'f0214_zaslavskii_map',
          shader: 'shaders/f0214_zaslavskii_map_gpu.frag',
        );

  @override
  F0214ZaslavskiiMapMetadata get metadata => F0214ZaslavskiiMapMetadata.instance;

  @override
  List<F0214ZaslavskiiMapPreset> get presets => F0214ZaslavskiiMapPresets.all;

  @override
  List<F0214ZaslavskiiMapVariant> get variants => F0214ZaslavskiiMapVariants.all;

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
