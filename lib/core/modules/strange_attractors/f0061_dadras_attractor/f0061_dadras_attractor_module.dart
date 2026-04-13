// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0061_dadras_attractor_presets.dart';
import 'f0061_dadras_attractor_variants.dart';
import 'f0061_dadras_attractor_metadata.dart';

/// Dadras Attractor — Strange Attractors.
class F0061DadrasAttractor extends AttractorModule {
  F0061DadrasAttractor()
      : super(
          id: 'f0061_dadras_attractor',
          shader: 'shaders/f0061_dadras_attractor_gpu.frag',
        );

  @override
  F0061DadrasAttractorMetadata get metadata => F0061DadrasAttractorMetadata.instance;

  @override
  List<F0061DadrasAttractorPreset> get presets => F0061DadrasAttractorPresets.all;

  @override
  List<F0061DadrasAttractorVariant> get variants => F0061DadrasAttractorVariants.all;

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
