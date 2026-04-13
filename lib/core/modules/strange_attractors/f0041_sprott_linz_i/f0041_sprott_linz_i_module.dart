// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0041_sprott_linz_i_presets.dart';
import 'f0041_sprott_linz_i_variants.dart';
import 'f0041_sprott_linz_i_metadata.dart';

/// Sprott-Linz I — Strange Attractors.
class F0041SprottLinzI extends AttractorModule {
  F0041SprottLinzI()
      : super(
          id: 'f0041_sprott_linz_i',
          shader: 'shaders/f0041_sprott_linz_i_gpu.frag',
        );

  @override
  F0041SprottLinzIMetadata get metadata => F0041SprottLinzIMetadata.instance;

  @override
  List<F0041SprottLinzIPreset> get presets => F0041SprottLinzIPresets.all;

  @override
  List<F0041SprottLinzIVariant> get variants => F0041SprottLinzIVariants.all;

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
