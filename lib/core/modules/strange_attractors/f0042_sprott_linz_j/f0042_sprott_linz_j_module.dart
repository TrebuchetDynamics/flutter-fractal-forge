// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0042_sprott_linz_j_presets.dart';
import 'f0042_sprott_linz_j_variants.dart';
import 'f0042_sprott_linz_j_metadata.dart';

/// Sprott-Linz J — Strange Attractors.
class F0042SprottLinzJ extends AttractorModule {
  F0042SprottLinzJ()
      : super(
          id: 'f0042_sprott_linz_j',
          shader: 'shaders/f0042_sprott_linz_j_gpu.frag',
        );

  @override
  F0042SprottLinzJMetadata get metadata => F0042SprottLinzJMetadata.instance;

  @override
  List<F0042SprottLinzJPreset> get presets => F0042SprottLinzJPresets.all;

  @override
  List<F0042SprottLinzJVariant> get variants => F0042SprottLinzJVariants.all;

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
