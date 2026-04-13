// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0087_van_der_pol_unforced_presets.dart';
import 'f0087_van_der_pol_unforced_variants.dart';
import 'f0087_van_der_pol_unforced_metadata.dart';

/// Van der Pol (unforced) — Strange Attractors.
class F0087VanDerPolUnforced extends AttractorModule {
  F0087VanDerPolUnforced()
      : super(
          id: 'f0087_van_der_pol_unforced',
          shader: 'shaders/f0087_van_der_pol_unforced_gpu.frag',
        );

  @override
  F0087VanDerPolUnforcedMetadata get metadata => F0087VanDerPolUnforcedMetadata.instance;

  @override
  List<F0087VanDerPolUnforcedPreset> get presets => F0087VanDerPolUnforcedPresets.all;

  @override
  List<F0087VanDerPolUnforcedVariant> get variants => F0087VanDerPolUnforcedVariants.all;

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
