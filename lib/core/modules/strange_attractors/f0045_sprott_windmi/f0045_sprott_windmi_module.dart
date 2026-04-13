// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0045_sprott_windmi_presets.dart';
import 'f0045_sprott_windmi_variants.dart';
import 'f0045_sprott_windmi_metadata.dart';

/// Sprott WINDMI — Strange Attractors.
class F0045SprottWindmi extends AttractorModule {
  F0045SprottWindmi()
      : super(
          id: 'f0045_sprott_windmi',
          shader: 'shaders/f0045_sprott_windmi_gpu.frag',
        );

  @override
  F0045SprottWindmiMetadata get metadata => F0045SprottWindmiMetadata.instance;

  @override
  List<F0045SprottWindmiPreset> get presets => F0045SprottWindmiPresets.all;

  @override
  List<F0045SprottWindmiVariant> get variants => F0045SprottWindmiVariants.all;

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
