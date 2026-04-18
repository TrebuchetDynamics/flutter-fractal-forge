// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0819_arnold_tongues_bifurcation_presets.dart';
import 'f0819_arnold_tongues_bifurcation_variants.dart';
import 'f0819_arnold_tongues_bifurcation_metadata.dart';

/// Arnold Tongues Bifurcation — Strange Attractors.
class F0819ArnoldTonguesBifurcation extends AttractorModule {
  F0819ArnoldTonguesBifurcation()
      : super(
          id: 'f0819_arnold_tongues_bifurcation',
          shader: 'shaders/f0819_arnold_tongues_bifurcation_gpu.frag',
        );

  @override
  F0819ArnoldTonguesBifurcationMetadata get metadata => F0819ArnoldTonguesBifurcationMetadata.instance;

  @override
  List<F0819ArnoldTonguesBifurcationPreset> get presets => F0819ArnoldTonguesBifurcationPresets.all;

  @override
  List<F0819ArnoldTonguesBifurcationVariant> get variants => F0819ArnoldTonguesBifurcationVariants.all;

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
