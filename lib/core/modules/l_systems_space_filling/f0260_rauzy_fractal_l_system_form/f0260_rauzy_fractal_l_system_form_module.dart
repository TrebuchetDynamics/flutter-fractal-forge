// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0260_rauzy_fractal_l_system_form_presets.dart';
import 'f0260_rauzy_fractal_l_system_form_variants.dart';
import 'f0260_rauzy_fractal_l_system_form_metadata.dart';

/// Rauzy Fractal (L-system form) — L-Systems & Space-Filling.
class F0260RauzyFractalLSystemForm extends LSystemModule {
  F0260RauzyFractalLSystemForm()
      : super(
          id: 'f0260_rauzy_fractal_l_system_form',
          shader: 'shaders/f0260_rauzy_fractal_l_system_form_gpu.frag',
        );

  @override
  F0260RauzyFractalLSystemFormMetadata get metadata => F0260RauzyFractalLSystemFormMetadata.instance;

  @override
  List<F0260RauzyFractalLSystemFormPreset> get presets => F0260RauzyFractalLSystemFormPresets.all;

  @override
  List<F0260RauzyFractalLSystemFormVariant> get variants => F0260RauzyFractalLSystemFormVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
