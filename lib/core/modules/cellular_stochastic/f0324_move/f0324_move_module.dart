// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0324_move_presets.dart';
import 'f0324_move_variants.dart';
import 'f0324_move_metadata.dart';

/// Move — Cellular & Stochastic.
class F0324Move extends CellularModule {
  F0324Move()
      : super(
          id: 'f0324_move',
          shader: 'shaders/f0324_move_gpu.frag',
        );

  @override
  F0324MoveMetadata get metadata => F0324MoveMetadata.instance;

  @override
  List<F0324MovePreset> get presets => F0324MovePresets.all;

  @override
  List<F0324MoveVariant> get variants => F0324MoveVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
