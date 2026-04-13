// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0412_gumowski_mira_galaxy_presets.dart';
import 'f0412_gumowski_mira_galaxy_variants.dart';
import 'f0412_gumowski_mira_galaxy_metadata.dart';

/// Gumowski-Mira Galaxy — Strange Attractors.
class F0412GumowskiMiraGalaxy extends AttractorModule {
  F0412GumowskiMiraGalaxy()
      : super(
          id: 'f0412_gumowski_mira_galaxy',
          shader: 'shaders/f0412_gumowski_mira_galaxy_gpu.frag',
        );

  @override
  F0412GumowskiMiraGalaxyMetadata get metadata => F0412GumowskiMiraGalaxyMetadata.instance;

  @override
  List<F0412GumowskiMiraGalaxyPreset> get presets => F0412GumowskiMiraGalaxyPresets.all;

  @override
  List<F0412GumowskiMiraGalaxyVariant> get variants => F0412GumowskiMiraGalaxyVariants.all;

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
