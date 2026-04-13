// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0280_leaf_ifs_presets.dart';
import 'f0280_leaf_ifs_variants.dart';
import 'f0280_leaf_ifs_metadata.dart';

/// Leaf IFS — IFS & Geometric Construction.
class F0280LeafIfs extends IFSModule {
  F0280LeafIfs()
      : super(
          id: 'f0280_leaf_ifs',
          shader: 'shaders/f0280_leaf_ifs_gpu.frag',
        );

  @override
  F0280LeafIfsMetadata get metadata => F0280LeafIfsMetadata.instance;

  @override
  List<F0280LeafIfsPreset> get presets => F0280LeafIfsPresets.all;

  @override
  List<F0280LeafIfsVariant> get variants => F0280LeafIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
