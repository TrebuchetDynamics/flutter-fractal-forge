// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1077_tinkerbell_classic_presets.dart';
import 'f1077_tinkerbell_classic_variants.dart';
import 'f1077_tinkerbell_classic_metadata.dart';

/// Tinkerbell Classic — Strange Attractors.
class F1077TinkerbellClassic extends AttractorModule {
  F1077TinkerbellClassic()
      : super(
          id: 'f1077_tinkerbell_classic',
          shader: 'shaders/f1077_tinkerbell_classic_gpu.frag',
        );

  @override
  F1077TinkerbellClassicMetadata get metadata => F1077TinkerbellClassicMetadata.instance;

  @override
  List<F1077TinkerbellClassicPreset> get presets => F1077TinkerbellClassicPresets.all;

  @override
  List<F1077TinkerbellClassicVariant> get variants => F1077TinkerbellClassicVariants.all;

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
