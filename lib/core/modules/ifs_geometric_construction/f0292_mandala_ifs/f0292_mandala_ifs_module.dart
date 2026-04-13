// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0292_mandala_ifs_presets.dart';
import 'f0292_mandala_ifs_variants.dart';
import 'f0292_mandala_ifs_metadata.dart';

/// Mandala IFS — IFS & Geometric Construction.
class F0292MandalaIfs extends IFSModule {
  F0292MandalaIfs()
      : super(
          id: 'f0292_mandala_ifs',
          shader: 'shaders/f0292_mandala_ifs_gpu.frag',
        );

  @override
  F0292MandalaIfsMetadata get metadata => F0292MandalaIfsMetadata.instance;

  @override
  List<F0292MandalaIfsPreset> get presets => F0292MandalaIfsPresets.all;

  @override
  List<F0292MandalaIfsVariant> get variants => F0292MandalaIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
