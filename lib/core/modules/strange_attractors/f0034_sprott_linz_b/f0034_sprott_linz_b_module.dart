// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0034_sprott_linz_b_presets.dart';
import 'f0034_sprott_linz_b_variants.dart';
import 'f0034_sprott_linz_b_metadata.dart';

/// Sprott-Linz B — Strange Attractors.
class F0034SprottLinzB extends AttractorModule {
  F0034SprottLinzB()
      : super(
          id: 'f0034_sprott_linz_b',
          shader: 'shaders/f0034_sprott_linz_b_gpu.frag',
        );

  @override
  F0034SprottLinzBMetadata get metadata => F0034SprottLinzBMetadata.instance;

  @override
  List<F0034SprottLinzBPreset> get presets => F0034SprottLinzBPresets.all;

  @override
  List<F0034SprottLinzBVariant> get variants => F0034SprottLinzBVariants.all;

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
