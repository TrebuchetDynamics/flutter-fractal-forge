// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1080_tinkerbell_ring_presets.dart';
import 'f1080_tinkerbell_ring_variants.dart';
import 'f1080_tinkerbell_ring_metadata.dart';

/// Tinkerbell Ring — Strange Attractors.
class F1080TinkerbellRing extends AttractorModule {
  F1080TinkerbellRing()
      : super(
          id: 'f1080_tinkerbell_ring',
          shader: 'shaders/f1080_tinkerbell_ring_gpu.frag',
        );

  @override
  F1080TinkerbellRingMetadata get metadata => F1080TinkerbellRingMetadata.instance;

  @override
  List<F1080TinkerbellRingPreset> get presets => F1080TinkerbellRingPresets.all;

  @override
  List<F1080TinkerbellRingVariant> get variants => F1080TinkerbellRingVariants.all;

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
