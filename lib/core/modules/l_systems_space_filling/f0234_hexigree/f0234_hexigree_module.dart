// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0234_hexigree_presets.dart';
import 'f0234_hexigree_variants.dart';
import 'f0234_hexigree_metadata.dart';

/// Hexigree — L-Systems & Space-Filling.
class F0234Hexigree extends LSystemModule {
  F0234Hexigree()
      : super(
          id: 'f0234_hexigree',
          shader: 'shaders/f0234_hexigree_gpu.frag',
        );

  @override
  F0234HexigreeMetadata get metadata => F0234HexigreeMetadata.instance;

  @override
  List<F0234HexigreePreset> get presets => F0234HexigreePresets.all;

  @override
  List<F0234HexigreeVariant> get variants => F0234HexigreeVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
