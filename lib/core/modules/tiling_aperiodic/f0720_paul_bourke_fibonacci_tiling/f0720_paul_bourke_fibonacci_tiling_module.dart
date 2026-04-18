// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0720_paul_bourke_fibonacci_tiling_presets.dart';
import 'f0720_paul_bourke_fibonacci_tiling_variants.dart';
import 'f0720_paul_bourke_fibonacci_tiling_metadata.dart';

/// Paul Bourke Fibonacci Tiling — Tiling & Aperiodic.
class F0720PaulBourkeFibonacciTiling extends IFSModule {
  F0720PaulBourkeFibonacciTiling()
      : super(
          id: 'f0720_paul_bourke_fibonacci_tiling',
          shader: 'shaders/f0720_paul_bourke_fibonacci_tiling_gpu.frag',
        );

  @override
  F0720PaulBourkeFibonacciTilingMetadata get metadata => F0720PaulBourkeFibonacciTilingMetadata.instance;

  @override
  List<F0720PaulBourkeFibonacciTilingPreset> get presets => F0720PaulBourkeFibonacciTilingPresets.all;

  @override
  List<F0720PaulBourkeFibonacciTilingVariant> get variants => F0720PaulBourkeFibonacciTilingVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
