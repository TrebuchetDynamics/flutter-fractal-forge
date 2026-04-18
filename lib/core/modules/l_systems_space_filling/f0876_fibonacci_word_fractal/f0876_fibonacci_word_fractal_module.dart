// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0876_fibonacci_word_fractal_presets.dart';
import 'f0876_fibonacci_word_fractal_variants.dart';
import 'f0876_fibonacci_word_fractal_metadata.dart';

/// Fibonacci Word Fractal — L-Systems & Space-Filling.
class F0876FibonacciWordFractal extends LSystemModule {
  F0876FibonacciWordFractal()
      : super(
          id: 'f0876_fibonacci_word_fractal',
          shader: 'shaders/f0876_fibonacci_word_fractal_gpu.frag',
        );

  @override
  F0876FibonacciWordFractalMetadata get metadata => F0876FibonacciWordFractalMetadata.instance;

  @override
  List<F0876FibonacciWordFractalPreset> get presets => F0876FibonacciWordFractalPresets.all;

  @override
  List<F0876FibonacciWordFractalVariant> get variants => F0876FibonacciWordFractalVariants.all;

  @override
  int get defaultDepth => 4;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
