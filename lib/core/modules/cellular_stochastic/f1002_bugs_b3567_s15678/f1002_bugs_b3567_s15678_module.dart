// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1002_bugs_b3567_s15678_presets.dart';
import 'f1002_bugs_b3567_s15678_variants.dart';
import 'f1002_bugs_b3567_s15678_metadata.dart';

/// Bugs (B3567/S15678) — Cellular & Stochastic.
class F1002BugsB3567S15678 extends CellularModule {
  F1002BugsB3567S15678()
      : super(
          id: 'f1002_bugs_b3567_s15678',
          shader: 'shaders/f1002_bugs_b3567_s15678_gpu.frag',
        );

  @override
  F1002BugsB3567S15678Metadata get metadata => F1002BugsB3567S15678Metadata.instance;

  @override
  List<F1002BugsB3567S15678Preset> get presets => F1002BugsB3567S15678Presets.all;

  @override
  List<F1002BugsB3567S15678Variant> get variants => F1002BugsB3567S15678Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
