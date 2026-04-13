// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0285_coastline_ifs_presets.dart';
import 'f0285_coastline_ifs_variants.dart';
import 'f0285_coastline_ifs_metadata.dart';

/// Coastline IFS — IFS & Geometric Construction.
class F0285CoastlineIfs extends IFSModule {
  F0285CoastlineIfs()
      : super(
          id: 'f0285_coastline_ifs',
          shader: 'shaders/f0285_coastline_ifs_gpu.frag',
        );

  @override
  F0285CoastlineIfsMetadata get metadata => F0285CoastlineIfsMetadata.instance;

  @override
  List<F0285CoastlineIfsPreset> get presets => F0285CoastlineIfsPresets.all;

  @override
  List<F0285CoastlineIfsVariant> get variants => F0285CoastlineIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
