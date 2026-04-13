// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0340_clifford_galaxy_presets.dart';
import 'f0340_clifford_galaxy_variants.dart';
import 'f0340_clifford_galaxy_metadata.dart';

/// Clifford Galaxy — Strange Attractors.
class F0340CliffordGalaxy extends AttractorModule {
  F0340CliffordGalaxy()
      : super(
          id: 'f0340_clifford_galaxy',
          shader: 'shaders/f0340_clifford_galaxy_gpu.frag',
        );

  @override
  F0340CliffordGalaxyMetadata get metadata => F0340CliffordGalaxyMetadata.instance;

  @override
  List<F0340CliffordGalaxyPreset> get presets => F0340CliffordGalaxyPresets.all;

  @override
  List<F0340CliffordGalaxyVariant> get variants => F0340CliffordGalaxyVariants.all;

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
