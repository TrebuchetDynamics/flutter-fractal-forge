// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0810_bernoulli_shift_presets.dart';
import 'f0810_bernoulli_shift_variants.dart';
import 'f0810_bernoulli_shift_metadata.dart';

/// Bernoulli Shift — Strange Attractors.
class F0810BernoulliShift extends AttractorModule {
  F0810BernoulliShift()
      : super(
          id: 'f0810_bernoulli_shift',
          shader: 'shaders/f0810_bernoulli_shift_gpu.frag',
        );

  @override
  F0810BernoulliShiftMetadata get metadata => F0810BernoulliShiftMetadata.instance;

  @override
  List<F0810BernoulliShiftPreset> get presets => F0810BernoulliShiftPresets.all;

  @override
  List<F0810BernoulliShiftVariant> get variants => F0810BernoulliShiftVariants.all;

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
