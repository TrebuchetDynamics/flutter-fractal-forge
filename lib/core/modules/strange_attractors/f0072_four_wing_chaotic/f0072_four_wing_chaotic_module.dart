// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0072_four_wing_chaotic_presets.dart';
import 'f0072_four_wing_chaotic_variants.dart';
import 'f0072_four_wing_chaotic_metadata.dart';

/// Four-Wing Chaotic — Strange Attractors.
class F0072FourWingChaotic extends AttractorModule {
  F0072FourWingChaotic()
      : super(
          id: 'f0072_four_wing_chaotic',
          shader: 'shaders/f0072_four_wing_chaotic_gpu.frag',
        );

  @override
  F0072FourWingChaoticMetadata get metadata => F0072FourWingChaoticMetadata.instance;

  @override
  List<F0072FourWingChaoticPreset> get presets => F0072FourWingChaoticPresets.all;

  @override
  List<F0072FourWingChaoticVariant> get variants => F0072FourWingChaoticVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.005;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
