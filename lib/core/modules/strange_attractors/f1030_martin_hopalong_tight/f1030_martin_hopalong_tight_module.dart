// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1030_martin_hopalong_tight_presets.dart';
import 'f1030_martin_hopalong_tight_variants.dart';
import 'f1030_martin_hopalong_tight_metadata.dart';

/// Martin Hopalong Tight — Strange Attractors.
class F1030MartinHopalongTight extends AttractorModule {
  F1030MartinHopalongTight()
      : super(
          id: 'f1030_martin_hopalong_tight',
          shader: 'shaders/f1030_martin_hopalong_tight_gpu.frag',
        );

  @override
  F1030MartinHopalongTightMetadata get metadata => F1030MartinHopalongTightMetadata.instance;

  @override
  List<F1030MartinHopalongTightPreset> get presets => F1030MartinHopalongTightPresets.all;

  @override
  List<F1030MartinHopalongTightVariant> get variants => F1030MartinHopalongTightVariants.all;

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
