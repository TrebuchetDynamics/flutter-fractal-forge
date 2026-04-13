// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0082_duffing_oscillator_forced_presets.dart';
import 'f0082_duffing_oscillator_forced_variants.dart';
import 'f0082_duffing_oscillator_forced_metadata.dart';

/// Duffing Oscillator (forced) — Strange Attractors.
class F0082DuffingOscillatorForced extends AttractorModule {
  F0082DuffingOscillatorForced()
      : super(
          id: 'f0082_duffing_oscillator_forced',
          shader: 'shaders/f0082_duffing_oscillator_forced_gpu.frag',
        );

  @override
  F0082DuffingOscillatorForcedMetadata get metadata => F0082DuffingOscillatorForcedMetadata.instance;

  @override
  List<F0082DuffingOscillatorForcedPreset> get presets => F0082DuffingOscillatorForcedPresets.all;

  @override
  List<F0082DuffingOscillatorForcedVariant> get variants => F0082DuffingOscillatorForcedVariants.all;

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
