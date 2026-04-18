// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1015_langton_s_loops_presets.dart';
import 'f1015_langton_s_loops_variants.dart';
import 'f1015_langton_s_loops_metadata.dart';

/// Langton's Loops — Cellular & Stochastic.
class F1015LangtonSLoops extends CellularModule {
  F1015LangtonSLoops()
      : super(
          id: 'f1015_langton_s_loops',
          shader: 'shaders/f1015_langton_s_loops_gpu.frag',
        );

  @override
  F1015LangtonSLoopsMetadata get metadata => F1015LangtonSLoopsMetadata.instance;

  @override
  List<F1015LangtonSLoopsPreset> get presets => F1015LangtonSLoopsPresets.all;

  @override
  List<F1015LangtonSLoopsVariant> get variants => F1015LangtonSLoopsVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
