// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0262_fern_prusinkiewicz_presets.dart';
import 'f0262_fern_prusinkiewicz_variants.dart';
import 'f0262_fern_prusinkiewicz_metadata.dart';

/// Fern (Prusinkiewicz) — L-Systems & Space-Filling.
class F0262FernPrusinkiewicz extends LSystemModule {
  F0262FernPrusinkiewicz()
      : super(
          id: 'f0262_fern_prusinkiewicz',
          shader: 'shaders/f0262_fern_prusinkiewicz_gpu.frag',
        );

  @override
  F0262FernPrusinkiewiczMetadata get metadata => F0262FernPrusinkiewiczMetadata.instance;

  @override
  List<F0262FernPrusinkiewiczPreset> get presets => F0262FernPrusinkiewiczPresets.all;

  @override
  List<F0262FernPrusinkiewiczVariant> get variants => F0262FernPrusinkiewiczVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
