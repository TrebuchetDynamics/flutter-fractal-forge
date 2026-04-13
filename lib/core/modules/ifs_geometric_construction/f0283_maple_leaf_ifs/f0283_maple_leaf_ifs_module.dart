// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0283_maple_leaf_ifs_presets.dart';
import 'f0283_maple_leaf_ifs_variants.dart';
import 'f0283_maple_leaf_ifs_metadata.dart';

/// Maple Leaf IFS — IFS & Geometric Construction.
class F0283MapleLeafIfs extends IFSModule {
  F0283MapleLeafIfs()
      : super(
          id: 'f0283_maple_leaf_ifs',
          shader: 'shaders/f0283_maple_leaf_ifs_gpu.frag',
        );

  @override
  F0283MapleLeafIfsMetadata get metadata => F0283MapleLeafIfsMetadata.instance;

  @override
  List<F0283MapleLeafIfsPreset> get presets => F0283MapleLeafIfsPresets.all;

  @override
  List<F0283MapleLeafIfsVariant> get variants => F0283MapleLeafIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
