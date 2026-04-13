// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0278_spiral_ifs_presets.dart';
import 'f0278_spiral_ifs_variants.dart';
import 'f0278_spiral_ifs_metadata.dart';

/// Spiral IFS — IFS & Geometric Construction.
class F0278SpiralIfs extends IFSModule {
  F0278SpiralIfs()
      : super(
          id: 'f0278_spiral_ifs',
          shader: 'shaders/f0278_spiral_ifs_gpu.frag',
        );

  @override
  F0278SpiralIfsMetadata get metadata => F0278SpiralIfsMetadata.instance;

  @override
  List<F0278SpiralIfsPreset> get presets => F0278SpiralIfsPresets.all;

  @override
  List<F0278SpiralIfsVariant> get variants => F0278SpiralIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
