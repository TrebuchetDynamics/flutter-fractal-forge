// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0795_euler_totient_fractal_presets.dart';
import 'f0795_euler_totient_fractal_variants.dart';
import 'f0795_euler_totient_fractal_metadata.dart';

/// Euler Totient Fractal — Number-Theory Fractals.
class F0795EulerTotientFractal extends CellularModule {
  F0795EulerTotientFractal()
      : super(
          id: 'f0795_euler_totient_fractal',
          shader: 'shaders/f0795_euler_totient_fractal_gpu.frag',
        );

  @override
  F0795EulerTotientFractalMetadata get metadata => F0795EulerTotientFractalMetadata.instance;

  @override
  List<F0795EulerTotientFractalPreset> get presets => F0795EulerTotientFractalPresets.all;

  @override
  List<F0795EulerTotientFractalVariant> get variants => F0795EulerTotientFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
