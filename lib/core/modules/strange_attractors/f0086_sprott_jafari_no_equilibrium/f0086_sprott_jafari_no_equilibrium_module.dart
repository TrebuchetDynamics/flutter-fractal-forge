// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0086_sprott_jafari_no_equilibrium_presets.dart';
import 'f0086_sprott_jafari_no_equilibrium_variants.dart';
import 'f0086_sprott_jafari_no_equilibrium_metadata.dart';

/// Sprott-Jafari No-Equilibrium — Strange Attractors.
class F0086SprottJafariNoEquilibrium extends AttractorModule {
  F0086SprottJafariNoEquilibrium()
      : super(
          id: 'f0086_sprott_jafari_no_equilibrium',
          shader: 'shaders/f0086_sprott_jafari_no_equilibrium_gpu.frag',
        );

  @override
  F0086SprottJafariNoEquilibriumMetadata get metadata => F0086SprottJafariNoEquilibriumMetadata.instance;

  @override
  List<F0086SprottJafariNoEquilibriumPreset> get presets => F0086SprottJafariNoEquilibriumPresets.all;

  @override
  List<F0086SprottJafariNoEquilibriumVariant> get variants => F0086SprottJafariNoEquilibriumVariants.all;

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
