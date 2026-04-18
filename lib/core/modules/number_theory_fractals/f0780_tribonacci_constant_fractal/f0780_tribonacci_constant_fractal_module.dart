// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0780_tribonacci_constant_fractal_presets.dart';
import 'f0780_tribonacci_constant_fractal_variants.dart';
import 'f0780_tribonacci_constant_fractal_metadata.dart';

/// Tribonacci Constant Fractal — Number-Theory Fractals.
class F0780TribonacciConstantFractal extends CellularModule {
  F0780TribonacciConstantFractal()
      : super(
          id: 'f0780_tribonacci_constant_fractal',
          shader: 'shaders/f0780_tribonacci_constant_fractal_gpu.frag',
        );

  @override
  F0780TribonacciConstantFractalMetadata get metadata => F0780TribonacciConstantFractalMetadata.instance;

  @override
  List<F0780TribonacciConstantFractalPreset> get presets => F0780TribonacciConstantFractalPresets.all;

  @override
  List<F0780TribonacciConstantFractalVariant> get variants => F0780TribonacciConstantFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
