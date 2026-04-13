// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0415_gumowski_mira_lamp_presets.dart';
import 'f0415_gumowski_mira_lamp_variants.dart';
import 'f0415_gumowski_mira_lamp_metadata.dart';

/// Gumowski-Mira Lamp — Strange Attractors.
class F0415GumowskiMiraLamp extends AttractorModule {
  F0415GumowskiMiraLamp()
      : super(
          id: 'f0415_gumowski_mira_lamp',
          shader: 'shaders/f0415_gumowski_mira_lamp_gpu.frag',
        );

  @override
  F0415GumowskiMiraLampMetadata get metadata => F0415GumowskiMiraLampMetadata.instance;

  @override
  List<F0415GumowskiMiraLampPreset> get presets => F0415GumowskiMiraLampPresets.all;

  @override
  List<F0415GumowskiMiraLampVariant> get variants => F0415GumowskiMiraLampVariants.all;

  @override
  int get defaultIterations => 150000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
