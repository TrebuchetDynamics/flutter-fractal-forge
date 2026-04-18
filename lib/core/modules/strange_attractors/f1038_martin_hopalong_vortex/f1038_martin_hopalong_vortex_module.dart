// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1038_martin_hopalong_vortex_presets.dart';
import 'f1038_martin_hopalong_vortex_variants.dart';
import 'f1038_martin_hopalong_vortex_metadata.dart';

/// Martin Hopalong Vortex — Strange Attractors.
class F1038MartinHopalongVortex extends AttractorModule {
  F1038MartinHopalongVortex()
      : super(
          id: 'f1038_martin_hopalong_vortex',
          shader: 'shaders/f1038_martin_hopalong_vortex_gpu.frag',
        );

  @override
  F1038MartinHopalongVortexMetadata get metadata => F1038MartinHopalongVortexMetadata.instance;

  @override
  List<F1038MartinHopalongVortexPreset> get presets => F1038MartinHopalongVortexPresets.all;

  @override
  List<F1038MartinHopalongVortexVariant> get variants => F1038MartinHopalongVortexVariants.all;

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
