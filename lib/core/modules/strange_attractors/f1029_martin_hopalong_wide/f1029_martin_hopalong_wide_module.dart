// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1029_martin_hopalong_wide_presets.dart';
import 'f1029_martin_hopalong_wide_variants.dart';
import 'f1029_martin_hopalong_wide_metadata.dart';

/// Martin Hopalong Wide — Strange Attractors.
class F1029MartinHopalongWide extends AttractorModule {
  F1029MartinHopalongWide()
      : super(
          id: 'f1029_martin_hopalong_wide',
          shader: 'shaders/f1029_martin_hopalong_wide_gpu.frag',
        );

  @override
  F1029MartinHopalongWideMetadata get metadata => F1029MartinHopalongWideMetadata.instance;

  @override
  List<F1029MartinHopalongWidePreset> get presets => F1029MartinHopalongWidePresets.all;

  @override
  List<F1029MartinHopalongWideVariant> get variants => F1029MartinHopalongWideVariants.all;

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
