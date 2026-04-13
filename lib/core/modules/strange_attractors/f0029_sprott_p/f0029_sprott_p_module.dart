// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0029_sprott_p_presets.dart';
import 'f0029_sprott_p_variants.dart';
import 'f0029_sprott_p_metadata.dart';

/// Sprott P — Strange Attractors.
class F0029SprottP extends AttractorModule {
  F0029SprottP()
      : super(
          id: 'f0029_sprott_p',
          shader: 'shaders/f0029_sprott_p_gpu.frag',
        );

  @override
  F0029SprottPMetadata get metadata => F0029SprottPMetadata.instance;

  @override
  List<F0029SprottPPreset> get presets => F0029SprottPPresets.all;

  @override
  List<F0029SprottPVariant> get variants => F0029SprottPVariants.all;

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
