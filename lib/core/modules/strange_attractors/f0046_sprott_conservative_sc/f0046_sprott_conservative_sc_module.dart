// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0046_sprott_conservative_sc_presets.dart';
import 'f0046_sprott_conservative_sc_variants.dart';
import 'f0046_sprott_conservative_sc_metadata.dart';

/// Sprott Conservative SC — Strange Attractors.
class F0046SprottConservativeSc extends AttractorModule {
  F0046SprottConservativeSc()
      : super(
          id: 'f0046_sprott_conservative_sc',
          shader: 'shaders/f0046_sprott_conservative_sc_gpu.frag',
        );

  @override
  F0046SprottConservativeScMetadata get metadata => F0046SprottConservativeScMetadata.instance;

  @override
  List<F0046SprottConservativeScPreset> get presets => F0046SprottConservativeScPresets.all;

  @override
  List<F0046SprottConservativeScVariant> get variants => F0046SprottConservativeScVariants.all;

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
