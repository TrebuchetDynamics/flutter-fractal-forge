// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0422_gumowski_mira_sea_urchin_presets.dart';
import 'f0422_gumowski_mira_sea_urchin_variants.dart';
import 'f0422_gumowski_mira_sea_urchin_metadata.dart';

/// Gumowski-Mira Sea Urchin — Strange Attractors.
class F0422GumowskiMiraSeaUrchin extends AttractorModule {
  F0422GumowskiMiraSeaUrchin()
      : super(
          id: 'f0422_gumowski_mira_sea_urchin',
          shader: 'shaders/f0422_gumowski_mira_sea_urchin_gpu.frag',
        );

  @override
  F0422GumowskiMiraSeaUrchinMetadata get metadata => F0422GumowskiMiraSeaUrchinMetadata.instance;

  @override
  List<F0422GumowskiMiraSeaUrchinPreset> get presets => F0422GumowskiMiraSeaUrchinPresets.all;

  @override
  List<F0422GumowskiMiraSeaUrchinVariant> get variants => F0422GumowskiMiraSeaUrchinVariants.all;

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
