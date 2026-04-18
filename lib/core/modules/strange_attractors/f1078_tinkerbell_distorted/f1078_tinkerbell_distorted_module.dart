// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1078_tinkerbell_distorted_presets.dart';
import 'f1078_tinkerbell_distorted_variants.dart';
import 'f1078_tinkerbell_distorted_metadata.dart';

/// Tinkerbell Distorted — Strange Attractors.
class F1078TinkerbellDistorted extends AttractorModule {
  F1078TinkerbellDistorted()
      : super(
          id: 'f1078_tinkerbell_distorted',
          shader: 'shaders/f1078_tinkerbell_distorted_gpu.frag',
        );

  @override
  F1078TinkerbellDistortedMetadata get metadata => F1078TinkerbellDistortedMetadata.instance;

  @override
  List<F1078TinkerbellDistortedPreset> get presets => F1078TinkerbellDistortedPresets.all;

  @override
  List<F1078TinkerbellDistortedVariant> get variants => F1078TinkerbellDistortedVariants.all;

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
