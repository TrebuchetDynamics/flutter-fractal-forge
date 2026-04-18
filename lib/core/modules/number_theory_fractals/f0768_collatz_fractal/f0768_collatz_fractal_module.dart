// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0768_collatz_fractal_presets.dart';
import 'f0768_collatz_fractal_variants.dart';
import 'f0768_collatz_fractal_metadata.dart';

/// Collatz Fractal — Number-Theory Fractals.
class F0768CollatzFractal extends CellularModule {
  F0768CollatzFractal()
      : super(
          id: 'f0768_collatz_fractal',
          shader: 'shaders/f0768_collatz_fractal_gpu.frag',
        );

  @override
  F0768CollatzFractalMetadata get metadata => F0768CollatzFractalMetadata.instance;

  @override
  List<F0768CollatzFractalPreset> get presets => F0768CollatzFractalPresets.all;

  @override
  List<F0768CollatzFractalVariant> get variants => F0768CollatzFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
