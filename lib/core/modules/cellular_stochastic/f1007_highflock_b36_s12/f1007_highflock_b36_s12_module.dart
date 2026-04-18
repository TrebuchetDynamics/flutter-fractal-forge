// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1007_highflock_b36_s12_presets.dart';
import 'f1007_highflock_b36_s12_variants.dart';
import 'f1007_highflock_b36_s12_metadata.dart';

/// HighFlock (B36/S12) — Cellular & Stochastic.
class F1007HighflockB36S12 extends CellularModule {
  F1007HighflockB36S12()
      : super(
          id: 'f1007_highflock_b36_s12',
          shader: 'shaders/f1007_highflock_b36_s12_gpu.frag',
        );

  @override
  F1007HighflockB36S12Metadata get metadata => F1007HighflockB36S12Metadata.instance;

  @override
  List<F1007HighflockB36S12Preset> get presets => F1007HighflockB36S12Presets.all;

  @override
  List<F1007HighflockB36S12Variant> get variants => F1007HighflockB36S12Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
