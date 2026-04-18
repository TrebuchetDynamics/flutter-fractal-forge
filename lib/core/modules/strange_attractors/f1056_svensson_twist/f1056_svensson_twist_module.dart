// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1056_svensson_twist_presets.dart';
import 'f1056_svensson_twist_variants.dart';
import 'f1056_svensson_twist_metadata.dart';

/// Svensson Twist — Strange Attractors.
class F1056SvenssonTwist extends AttractorModule {
  F1056SvenssonTwist()
      : super(
          id: 'f1056_svensson_twist',
          shader: 'shaders/f1056_svensson_twist_gpu.frag',
        );

  @override
  F1056SvenssonTwistMetadata get metadata => F1056SvenssonTwistMetadata.instance;

  @override
  List<F1056SvenssonTwistPreset> get presets => F1056SvenssonTwistPresets.all;

  @override
  List<F1056SvenssonTwistVariant> get variants => F1056SvenssonTwistVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
