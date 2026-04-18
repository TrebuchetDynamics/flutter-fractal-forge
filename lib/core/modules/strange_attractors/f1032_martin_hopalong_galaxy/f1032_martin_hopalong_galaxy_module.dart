// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1032_martin_hopalong_galaxy_presets.dart';
import 'f1032_martin_hopalong_galaxy_variants.dart';
import 'f1032_martin_hopalong_galaxy_metadata.dart';

/// Martin Hopalong Galaxy — Strange Attractors.
class F1032MartinHopalongGalaxy extends AttractorModule {
  F1032MartinHopalongGalaxy()
      : super(
          id: 'f1032_martin_hopalong_galaxy',
          shader: 'shaders/f1032_martin_hopalong_galaxy_gpu.frag',
        );

  @override
  F1032MartinHopalongGalaxyMetadata get metadata => F1032MartinHopalongGalaxyMetadata.instance;

  @override
  List<F1032MartinHopalongGalaxyPreset> get presets => F1032MartinHopalongGalaxyPresets.all;

  @override
  List<F1032MartinHopalongGalaxyVariant> get variants => F1032MartinHopalongGalaxyVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
