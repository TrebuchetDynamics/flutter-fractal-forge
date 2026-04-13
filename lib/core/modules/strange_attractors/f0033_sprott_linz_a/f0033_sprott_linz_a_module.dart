// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0033_sprott_linz_a_presets.dart';
import 'f0033_sprott_linz_a_variants.dart';
import 'f0033_sprott_linz_a_metadata.dart';

/// Sprott-Linz A — Strange Attractors.
class F0033SprottLinzA extends AttractorModule {
  F0033SprottLinzA()
      : super(
          id: 'f0033_sprott_linz_a',
          shader: 'shaders/f0033_sprott_linz_a_gpu.frag',
        );

  @override
  F0033SprottLinzAMetadata get metadata => F0033SprottLinzAMetadata.instance;

  @override
  List<F0033SprottLinzAPreset> get presets => F0033SprottLinzAPresets.all;

  @override
  List<F0033SprottLinzAVariant> get variants => F0033SprottLinzAVariants.all;

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
