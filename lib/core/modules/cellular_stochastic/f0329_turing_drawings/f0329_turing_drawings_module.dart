// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0329_turing_drawings_presets.dart';
import 'f0329_turing_drawings_variants.dart';
import 'f0329_turing_drawings_metadata.dart';

/// Turing Drawings — Cellular & Stochastic.
class F0329TuringDrawings extends CellularModule {
  F0329TuringDrawings()
      : super(
          id: 'f0329_turing_drawings',
          shader: 'shaders/f0329_turing_drawings_gpu.frag',
        );

  @override
  F0329TuringDrawingsMetadata get metadata => F0329TuringDrawingsMetadata.instance;

  @override
  List<F0329TuringDrawingsPreset> get presets => F0329TuringDrawingsPresets.all;

  @override
  List<F0329TuringDrawingsVariant> get variants => F0329TuringDrawingsVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
