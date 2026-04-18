// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0770_continued_fraction_fractal_presets.dart';
import 'f0770_continued_fraction_fractal_variants.dart';
import 'f0770_continued_fraction_fractal_metadata.dart';

/// Continued Fraction Fractal — Number-Theory Fractals.
class F0770ContinuedFractionFractal extends CellularModule {
  F0770ContinuedFractionFractal()
      : super(
          id: 'f0770_continued_fraction_fractal',
          shader: 'shaders/f0770_continued_fraction_fractal_gpu.frag',
        );

  @override
  F0770ContinuedFractionFractalMetadata get metadata => F0770ContinuedFractionFractalMetadata.instance;

  @override
  List<F0770ContinuedFractionFractalPreset> get presets => F0770ContinuedFractionFractalPresets.all;

  @override
  List<F0770ContinuedFractionFractalVariant> get variants => F0770ContinuedFractionFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
