// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0777_fibonacci_word_fractal_presets.dart';
import 'f0777_fibonacci_word_fractal_variants.dart';
import 'f0777_fibonacci_word_fractal_metadata.dart';

/// Fibonacci Word Fractal — Number-Theory Fractals.
class F0777FibonacciWordFractal extends CellularModule {
  F0777FibonacciWordFractal()
      : super(
          id: 'f0777_fibonacci_word_fractal',
          shader: 'shaders/f0777_fibonacci_word_fractal_gpu.frag',
        );

  @override
  F0777FibonacciWordFractalMetadata get metadata => F0777FibonacciWordFractalMetadata.instance;

  @override
  List<F0777FibonacciWordFractalPreset> get presets => F0777FibonacciWordFractalPresets.all;

  @override
  List<F0777FibonacciWordFractalVariant> get variants => F0777FibonacciWordFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
