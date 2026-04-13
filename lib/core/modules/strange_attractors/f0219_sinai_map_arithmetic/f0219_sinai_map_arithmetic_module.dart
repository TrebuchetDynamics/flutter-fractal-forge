// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0219_sinai_map_arithmetic_presets.dart';
import 'f0219_sinai_map_arithmetic_variants.dart';
import 'f0219_sinai_map_arithmetic_metadata.dart';

/// Sinai Map (arithmetic) — Strange Attractors.
class F0219SinaiMapArithmetic extends AttractorModule {
  F0219SinaiMapArithmetic()
      : super(
          id: 'f0219_sinai_map_arithmetic',
          shader: 'shaders/f0219_sinai_map_arithmetic_gpu.frag',
        );

  @override
  F0219SinaiMapArithmeticMetadata get metadata => F0219SinaiMapArithmeticMetadata.instance;

  @override
  List<F0219SinaiMapArithmeticPreset> get presets => F0219SinaiMapArithmeticPresets.all;

  @override
  List<F0219SinaiMapArithmeticVariant> get variants => F0219SinaiMapArithmeticVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
