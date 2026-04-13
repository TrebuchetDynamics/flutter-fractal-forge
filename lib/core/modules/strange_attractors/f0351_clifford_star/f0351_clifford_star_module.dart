// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0351_clifford_star_presets.dart';
import 'f0351_clifford_star_variants.dart';
import 'f0351_clifford_star_metadata.dart';

/// Clifford Star — Strange Attractors.
class F0351CliffordStar extends AttractorModule {
  F0351CliffordStar()
      : super(
          id: 'f0351_clifford_star',
          shader: 'shaders/f0351_clifford_star_gpu.frag',
        );

  @override
  F0351CliffordStarMetadata get metadata => F0351CliffordStarMetadata.instance;

  @override
  List<F0351CliffordStarPreset> get presets => F0351CliffordStarPresets.all;

  @override
  List<F0351CliffordStarVariant> get variants => F0351CliffordStarVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
