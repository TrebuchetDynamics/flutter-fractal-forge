// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0075_hadley_circulation_presets.dart';
import 'f0075_hadley_circulation_variants.dart';
import 'f0075_hadley_circulation_metadata.dart';

/// Hadley Circulation — Strange Attractors.
class F0075HadleyCirculation extends AttractorModule {
  F0075HadleyCirculation()
      : super(
          id: 'f0075_hadley_circulation',
          shader: 'shaders/f0075_hadley_circulation_gpu.frag',
        );

  @override
  F0075HadleyCirculationMetadata get metadata => F0075HadleyCirculationMetadata.instance;

  @override
  List<F0075HadleyCirculationPreset> get presets => F0075HadleyCirculationPresets.all;

  @override
  List<F0075HadleyCirculationVariant> get variants => F0075HadleyCirculationVariants.all;

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
