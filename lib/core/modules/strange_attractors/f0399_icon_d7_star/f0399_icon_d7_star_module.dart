// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0399_icon_d7_star_presets.dart';
import 'f0399_icon_d7_star_variants.dart';
import 'f0399_icon_d7_star_metadata.dart';

/// Icon — D7 Star — Strange Attractors.
class F0399IconD7Star extends AttractorModule {
  F0399IconD7Star()
      : super(
          id: 'f0399_icon_d7_star',
          shader: 'shaders/f0399_icon_d7_star_gpu.frag',
        );

  @override
  F0399IconD7StarMetadata get metadata => F0399IconD7StarMetadata.instance;

  @override
  List<F0399IconD7StarPreset> get presets => F0399IconD7StarPresets.all;

  @override
  List<F0399IconD7StarVariant> get variants => F0399IconD7StarVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
