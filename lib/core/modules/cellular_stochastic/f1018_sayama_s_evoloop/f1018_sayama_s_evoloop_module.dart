// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1018_sayama_s_evoloop_presets.dart';
import 'f1018_sayama_s_evoloop_variants.dart';
import 'f1018_sayama_s_evoloop_metadata.dart';

/// Sayama's Evoloop — Cellular & Stochastic.
class F1018SayamaSEvoloop extends CellularModule {
  F1018SayamaSEvoloop()
      : super(
          id: 'f1018_sayama_s_evoloop',
          shader: 'shaders/f1018_sayama_s_evoloop_gpu.frag',
        );

  @override
  F1018SayamaSEvoloopMetadata get metadata => F1018SayamaSEvoloopMetadata.instance;

  @override
  List<F1018SayamaSEvoloopPreset> get presets => F1018SayamaSEvoloopPresets.all;

  @override
  List<F1018SayamaSEvoloopVariant> get variants => F1018SayamaSEvoloopVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
