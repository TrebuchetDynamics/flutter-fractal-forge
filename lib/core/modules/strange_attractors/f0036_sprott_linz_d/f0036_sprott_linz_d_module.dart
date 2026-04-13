// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0036_sprott_linz_d_presets.dart';
import 'f0036_sprott_linz_d_variants.dart';
import 'f0036_sprott_linz_d_metadata.dart';

/// Sprott-Linz D — Strange Attractors.
class F0036SprottLinzD extends AttractorModule {
  F0036SprottLinzD()
      : super(
          id: 'f0036_sprott_linz_d',
          shader: 'shaders/f0036_sprott_linz_d_gpu.frag',
        );

  @override
  F0036SprottLinzDMetadata get metadata => F0036SprottLinzDMetadata.instance;

  @override
  List<F0036SprottLinzDPreset> get presets => F0036SprottLinzDPresets.all;

  @override
  List<F0036SprottLinzDVariant> get variants => F0036SprottLinzDVariants.all;

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
