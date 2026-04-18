// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1079_tinkerbell_wing_presets.dart';
import 'f1079_tinkerbell_wing_variants.dart';
import 'f1079_tinkerbell_wing_metadata.dart';

/// Tinkerbell Wing — Strange Attractors.
class F1079TinkerbellWing extends AttractorModule {
  F1079TinkerbellWing()
      : super(
          id: 'f1079_tinkerbell_wing',
          shader: 'shaders/f1079_tinkerbell_wing_gpu.frag',
        );

  @override
  F1079TinkerbellWingMetadata get metadata => F1079TinkerbellWingMetadata.instance;

  @override
  List<F1079TinkerbellWingPreset> get presets => F1079TinkerbellWingPresets.all;

  @override
  List<F1079TinkerbellWingVariant> get variants => F1079TinkerbellWingVariants.all;

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
