// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0053_chen_attractor_presets.dart';
import 'f0053_chen_attractor_variants.dart';
import 'f0053_chen_attractor_metadata.dart';

/// Chen Attractor — Strange Attractors.
class F0053ChenAttractor extends AttractorModule {
  F0053ChenAttractor()
      : super(
          id: 'f0053_chen_attractor',
          shader: 'shaders/f0053_chen_attractor_gpu.frag',
        );

  @override
  F0053ChenAttractorMetadata get metadata => F0053ChenAttractorMetadata.instance;

  @override
  List<F0053ChenAttractorPreset> get presets => F0053ChenAttractorPresets.all;

  @override
  List<F0053ChenAttractorVariant> get variants => F0053ChenAttractorVariants.all;

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
