// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1071_rulkov_tonic_presets.dart';
import 'f1071_rulkov_tonic_variants.dart';
import 'f1071_rulkov_tonic_metadata.dart';

/// Rulkov Tonic — Strange Attractors.
class F1071RulkovTonic extends AttractorModule {
  F1071RulkovTonic()
      : super(
          id: 'f1071_rulkov_tonic',
          shader: 'shaders/f1071_rulkov_tonic_gpu.frag',
        );

  @override
  F1071RulkovTonicMetadata get metadata => F1071RulkovTonicMetadata.instance;

  @override
  List<F1071RulkovTonicPreset> get presets => F1071RulkovTonicPresets.all;

  @override
  List<F1071RulkovTonicVariant> get variants => F1071RulkovTonicVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
