// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0802_logistic_onset_of_chaos_presets.dart';
import 'f0802_logistic_onset_of_chaos_variants.dart';
import 'f0802_logistic_onset_of_chaos_metadata.dart';

/// Logistic Onset of Chaos — Strange Attractors.
class F0802LogisticOnsetOfChaos extends AttractorModule {
  F0802LogisticOnsetOfChaos()
      : super(
          id: 'f0802_logistic_onset_of_chaos',
          shader: 'shaders/f0802_logistic_onset_of_chaos_gpu.frag',
        );

  @override
  F0802LogisticOnsetOfChaosMetadata get metadata => F0802LogisticOnsetOfChaosMetadata.instance;

  @override
  List<F0802LogisticOnsetOfChaosPreset> get presets => F0802LogisticOnsetOfChaosPresets.all;

  @override
  List<F0802LogisticOnsetOfChaosVariant> get variants => F0802LogisticOnsetOfChaosVariants.all;

  @override
  int get defaultIterations => 50000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
