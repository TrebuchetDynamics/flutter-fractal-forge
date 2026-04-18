// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1028_martin_hopalong_classic_presets.dart';
import 'f1028_martin_hopalong_classic_variants.dart';
import 'f1028_martin_hopalong_classic_metadata.dart';

/// Martin Hopalong (Classic) — Strange Attractors.
class F1028MartinHopalongClassic extends AttractorModule {
  F1028MartinHopalongClassic()
      : super(
          id: 'f1028_martin_hopalong_classic',
          shader: 'shaders/f1028_martin_hopalong_classic_gpu.frag',
        );

  @override
  F1028MartinHopalongClassicMetadata get metadata => F1028MartinHopalongClassicMetadata.instance;

  @override
  List<F1028MartinHopalongClassicPreset> get presets => F1028MartinHopalongClassicPresets.all;

  @override
  List<F1028MartinHopalongClassicVariant> get variants => F1028MartinHopalongClassicVariants.all;

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
