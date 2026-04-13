// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0038_sprott_linz_f_presets.dart';
import 'f0038_sprott_linz_f_variants.dart';
import 'f0038_sprott_linz_f_metadata.dart';

/// Sprott-Linz F — Strange Attractors.
class F0038SprottLinzF extends AttractorModule {
  F0038SprottLinzF()
      : super(
          id: 'f0038_sprott_linz_f',
          shader: 'shaders/f0038_sprott_linz_f_gpu.frag',
        );

  @override
  F0038SprottLinzFMetadata get metadata => F0038SprottLinzFMetadata.instance;

  @override
  List<F0038SprottLinzFPreset> get presets => F0038SprottLinzFPresets.all;

  @override
  List<F0038SprottLinzFVariant> get variants => F0038SprottLinzFVariants.all;

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
