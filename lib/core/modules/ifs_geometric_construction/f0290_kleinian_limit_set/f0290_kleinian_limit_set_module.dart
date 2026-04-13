// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0290_kleinian_limit_set_presets.dart';
import 'f0290_kleinian_limit_set_variants.dart';
import 'f0290_kleinian_limit_set_metadata.dart';

/// Kleinian Limit Set — IFS & Geometric Construction.
class F0290KleinianLimitSet extends IFSModule {
  F0290KleinianLimitSet()
      : super(
          id: 'f0290_kleinian_limit_set',
          shader: 'shaders/f0290_kleinian_limit_set_gpu.frag',
        );

  @override
  F0290KleinianLimitSetMetadata get metadata => F0290KleinianLimitSetMetadata.instance;

  @override
  List<F0290KleinianLimitSetPreset> get presets => F0290KleinianLimitSetPresets.all;

  @override
  List<F0290KleinianLimitSetVariant> get variants => F0290KleinianLimitSetVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
