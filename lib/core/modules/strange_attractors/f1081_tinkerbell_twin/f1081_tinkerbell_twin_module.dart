// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1081_tinkerbell_twin_presets.dart';
import 'f1081_tinkerbell_twin_variants.dart';
import 'f1081_tinkerbell_twin_metadata.dart';

/// Tinkerbell Twin — Strange Attractors.
class F1081TinkerbellTwin extends AttractorModule {
  F1081TinkerbellTwin()
      : super(
          id: 'f1081_tinkerbell_twin',
          shader: 'shaders/f1081_tinkerbell_twin_gpu.frag',
        );

  @override
  F1081TinkerbellTwinMetadata get metadata => F1081TinkerbellTwinMetadata.instance;

  @override
  List<F1081TinkerbellTwinPreset> get presets => F1081TinkerbellTwinPresets.all;

  @override
  List<F1081TinkerbellTwinVariant> get variants => F1081TinkerbellTwinVariants.all;

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
