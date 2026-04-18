// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0796_mobius_function_fractal_presets.dart';
import 'f0796_mobius_function_fractal_variants.dart';
import 'f0796_mobius_function_fractal_metadata.dart';

/// Mobius Function Fractal — Number-Theory Fractals.
class F0796MobiusFunctionFractal extends CellularModule {
  F0796MobiusFunctionFractal()
      : super(
          id: 'f0796_mobius_function_fractal',
          shader: 'shaders/f0796_mobius_function_fractal_gpu.frag',
        );

  @override
  F0796MobiusFunctionFractalMetadata get metadata => F0796MobiusFunctionFractalMetadata.instance;

  @override
  List<F0796MobiusFunctionFractalPreset> get presets => F0796MobiusFunctionFractalPresets.all;

  @override
  List<F0796MobiusFunctionFractalVariant> get variants => F0796MobiusFunctionFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
