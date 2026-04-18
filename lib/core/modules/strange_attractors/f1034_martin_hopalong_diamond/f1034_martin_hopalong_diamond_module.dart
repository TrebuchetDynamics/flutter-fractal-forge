// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1034_martin_hopalong_diamond_presets.dart';
import 'f1034_martin_hopalong_diamond_variants.dart';
import 'f1034_martin_hopalong_diamond_metadata.dart';

/// Martin Hopalong Diamond — Strange Attractors.
class F1034MartinHopalongDiamond extends AttractorModule {
  F1034MartinHopalongDiamond()
      : super(
          id: 'f1034_martin_hopalong_diamond',
          shader: 'shaders/f1034_martin_hopalong_diamond_gpu.frag',
        );

  @override
  F1034MartinHopalongDiamondMetadata get metadata => F1034MartinHopalongDiamondMetadata.instance;

  @override
  List<F1034MartinHopalongDiamondPreset> get presets => F1034MartinHopalongDiamondPresets.all;

  @override
  List<F1034MartinHopalongDiamondVariant> get variants => F1034MartinHopalongDiamondVariants.all;

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
