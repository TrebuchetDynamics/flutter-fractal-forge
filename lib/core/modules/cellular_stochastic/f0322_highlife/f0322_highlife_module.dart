// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0322_highlife_presets.dart';
import 'f0322_highlife_variants.dart';
import 'f0322_highlife_metadata.dart';

/// HighLife — Cellular & Stochastic.
class F0322Highlife extends CellularModule {
  F0322Highlife()
      : super(
          id: 'f0322_highlife',
          shader: 'shaders/f0322_highlife_gpu.frag',
        );

  @override
  F0322HighlifeMetadata get metadata => F0322HighlifeMetadata.instance;

  @override
  List<F0322HighlifePreset> get presets => F0322HighlifePresets.all;

  @override
  List<F0322HighlifeVariant> get variants => F0322HighlifeVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
