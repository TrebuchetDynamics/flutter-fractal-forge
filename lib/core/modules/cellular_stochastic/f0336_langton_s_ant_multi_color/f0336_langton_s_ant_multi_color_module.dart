// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0336_langton_s_ant_multi_color_presets.dart';
import 'f0336_langton_s_ant_multi_color_variants.dart';
import 'f0336_langton_s_ant_multi_color_metadata.dart';

/// Langton's Ant (multi-color) — Cellular & Stochastic.
class F0336LangtonSAntMultiColor extends CellularModule {
  F0336LangtonSAntMultiColor()
      : super(
          id: 'f0336_langton_s_ant_multi_color',
          shader: 'shaders/f0336_langton_s_ant_multi_color_gpu.frag',
        );

  @override
  F0336LangtonSAntMultiColorMetadata get metadata => F0336LangtonSAntMultiColorMetadata.instance;

  @override
  List<F0336LangtonSAntMultiColorPreset> get presets => F0336LangtonSAntMultiColorPresets.all;

  @override
  List<F0336LangtonSAntMultiColorVariant> get variants => F0336LangtonSAntMultiColorVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
