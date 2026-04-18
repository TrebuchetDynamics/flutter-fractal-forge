// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1031_martin_hopalong_spiral_presets.dart';
import 'f1031_martin_hopalong_spiral_variants.dart';
import 'f1031_martin_hopalong_spiral_metadata.dart';

/// Martin Hopalong Spiral — Strange Attractors.
class F1031MartinHopalongSpiral extends AttractorModule {
  F1031MartinHopalongSpiral()
      : super(
          id: 'f1031_martin_hopalong_spiral',
          shader: 'shaders/f1031_martin_hopalong_spiral_gpu.frag',
        );

  @override
  F1031MartinHopalongSpiralMetadata get metadata => F1031MartinHopalongSpiralMetadata.instance;

  @override
  List<F1031MartinHopalongSpiralPreset> get presets => F1031MartinHopalongSpiralPresets.all;

  @override
  List<F1031MartinHopalongSpiralVariant> get variants => F1031MartinHopalongSpiralVariants.all;

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
