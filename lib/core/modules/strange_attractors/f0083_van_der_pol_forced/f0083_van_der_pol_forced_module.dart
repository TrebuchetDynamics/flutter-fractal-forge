// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0083_van_der_pol_forced_presets.dart';
import 'f0083_van_der_pol_forced_variants.dart';
import 'f0083_van_der_pol_forced_metadata.dart';

/// Van der Pol (forced) — Strange Attractors.
class F0083VanDerPolForced extends AttractorModule {
  F0083VanDerPolForced()
      : super(
          id: 'f0083_van_der_pol_forced',
          shader: 'shaders/f0083_van_der_pol_forced_gpu.frag',
        );

  @override
  F0083VanDerPolForcedMetadata get metadata => F0083VanDerPolForcedMetadata.instance;

  @override
  List<F0083VanDerPolForcedPreset> get presets => F0083VanDerPolForcedPresets.all;

  @override
  List<F0083VanDerPolForcedVariant> get variants => F0083VanDerPolForcedVariants.all;

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
