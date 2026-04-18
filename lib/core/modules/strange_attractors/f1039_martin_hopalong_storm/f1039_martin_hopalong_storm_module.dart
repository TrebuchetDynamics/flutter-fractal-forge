// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1039_martin_hopalong_storm_presets.dart';
import 'f1039_martin_hopalong_storm_variants.dart';
import 'f1039_martin_hopalong_storm_metadata.dart';

/// Martin Hopalong Storm — Strange Attractors.
class F1039MartinHopalongStorm extends AttractorModule {
  F1039MartinHopalongStorm()
      : super(
          id: 'f1039_martin_hopalong_storm',
          shader: 'shaders/f1039_martin_hopalong_storm_gpu.frag',
        );

  @override
  F1039MartinHopalongStormMetadata get metadata => F1039MartinHopalongStormMetadata.instance;

  @override
  List<F1039MartinHopalongStormPreset> get presets => F1039MartinHopalongStormPresets.all;

  @override
  List<F1039MartinHopalongStormVariant> get variants => F1039MartinHopalongStormVariants.all;

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
