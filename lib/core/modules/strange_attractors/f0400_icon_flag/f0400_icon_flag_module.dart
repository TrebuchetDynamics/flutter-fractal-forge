// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0400_icon_flag_presets.dart';
import 'f0400_icon_flag_variants.dart';
import 'f0400_icon_flag_metadata.dart';

/// Icon — Flag — Strange Attractors.
class F0400IconFlag extends AttractorModule {
  F0400IconFlag()
      : super(
          id: 'f0400_icon_flag',
          shader: 'shaders/f0400_icon_flag_gpu.frag',
        );

  @override
  F0400IconFlagMetadata get metadata => F0400IconFlagMetadata.instance;

  @override
  List<F0400IconFlagPreset> get presets => F0400IconFlagPresets.all;

  @override
  List<F0400IconFlagVariant> get variants => F0400IconFlagVariants.all;

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
