// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0999_move_b368_s245_presets.dart';
import 'f0999_move_b368_s245_variants.dart';
import 'f0999_move_b368_s245_metadata.dart';

/// Move (B368/S245) — Cellular & Stochastic.
class F0999MoveB368S245 extends CellularModule {
  F0999MoveB368S245()
      : super(
          id: 'f0999_move_b368_s245',
          shader: 'shaders/f0999_move_b368_s245_gpu.frag',
        );

  @override
  F0999MoveB368S245Metadata get metadata => F0999MoveB368S245Metadata.instance;

  @override
  List<F0999MoveB368S245Preset> get presets => F0999MoveB368S245Presets.all;

  @override
  List<F0999MoveB368S245Variant> get variants => F0999MoveB368S245Variants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
