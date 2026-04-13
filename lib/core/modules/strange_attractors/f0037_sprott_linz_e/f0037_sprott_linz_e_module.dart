// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0037_sprott_linz_e_presets.dart';
import 'f0037_sprott_linz_e_variants.dart';
import 'f0037_sprott_linz_e_metadata.dart';

/// Sprott-Linz E — Strange Attractors.
class F0037SprottLinzE extends AttractorModule {
  F0037SprottLinzE()
      : super(
          id: 'f0037_sprott_linz_e',
          shader: 'shaders/f0037_sprott_linz_e_gpu.frag',
        );

  @override
  F0037SprottLinzEMetadata get metadata => F0037SprottLinzEMetadata.instance;

  @override
  List<F0037SprottLinzEPreset> get presets => F0037SprottLinzEPresets.all;

  @override
  List<F0037SprottLinzEVariant> get variants => F0037SprottLinzEVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
