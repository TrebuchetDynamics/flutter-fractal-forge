// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0764_weierstrass_mandelbrot_cosine_presets.dart';
import 'f0764_weierstrass_mandelbrot_cosine_variants.dart';
import 'f0764_weierstrass_mandelbrot_cosine_metadata.dart';

/// Weierstrass-Mandelbrot Cosine — Number-Theory Fractals.
class F0764WeierstrassMandelbrotCosine extends CellularModule {
  F0764WeierstrassMandelbrotCosine()
      : super(
          id: 'f0764_weierstrass_mandelbrot_cosine',
          shader: 'shaders/f0764_weierstrass_mandelbrot_cosine_gpu.frag',
        );

  @override
  F0764WeierstrassMandelbrotCosineMetadata get metadata => F0764WeierstrassMandelbrotCosineMetadata.instance;

  @override
  List<F0764WeierstrassMandelbrotCosinePreset> get presets => F0764WeierstrassMandelbrotCosinePresets.all;

  @override
  List<F0764WeierstrassMandelbrotCosineVariant> get variants => F0764WeierstrassMandelbrotCosineVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
