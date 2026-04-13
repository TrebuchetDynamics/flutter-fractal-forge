// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0019_sprott_f_presets.dart';
import 'f0019_sprott_f_variants.dart';
import 'f0019_sprott_f_metadata.dart';

/// Sprott F — Strange Attractors.
class F0019SprottF extends AttractorModule {
  F0019SprottF()
      : super(
          id: 'f0019_sprott_f',
          shader: 'shaders/f0019_sprott_f_gpu.frag',
        );

  @override
  F0019SprottFMetadata get metadata => F0019SprottFMetadata.instance;

  @override
  List<F0019SprottFPreset> get presets => F0019SprottFPresets.all;

  @override
  List<F0019SprottFVariant> get variants => F0019SprottFVariants.all;

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
