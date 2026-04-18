// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0790_rauzy_fractal_substitution_presets.dart';
import 'f0790_rauzy_fractal_substitution_variants.dart';
import 'f0790_rauzy_fractal_substitution_metadata.dart';

/// Rauzy Fractal (Substitution) — Number-Theory Fractals.
class F0790RauzyFractalSubstitution extends CellularModule {
  F0790RauzyFractalSubstitution()
      : super(
          id: 'f0790_rauzy_fractal_substitution',
          shader: 'shaders/f0790_rauzy_fractal_substitution_gpu.frag',
        );

  @override
  F0790RauzyFractalSubstitutionMetadata get metadata => F0790RauzyFractalSubstitutionMetadata.instance;

  @override
  List<F0790RauzyFractalSubstitutionPreset> get presets => F0790RauzyFractalSubstitutionPresets.all;

  @override
  List<F0790RauzyFractalSubstitutionVariant> get variants => F0790RauzyFractalSubstitutionVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
