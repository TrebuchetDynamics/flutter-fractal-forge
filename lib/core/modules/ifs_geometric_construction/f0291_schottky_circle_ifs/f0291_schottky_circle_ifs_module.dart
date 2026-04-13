// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0291_schottky_circle_ifs_presets.dart';
import 'f0291_schottky_circle_ifs_variants.dart';
import 'f0291_schottky_circle_ifs_metadata.dart';

/// Schottky Circle IFS — IFS & Geometric Construction.
class F0291SchottkyCircleIfs extends IFSModule {
  F0291SchottkyCircleIfs()
      : super(
          id: 'f0291_schottky_circle_ifs',
          shader: 'shaders/f0291_schottky_circle_ifs_gpu.frag',
        );

  @override
  F0291SchottkyCircleIfsMetadata get metadata => F0291SchottkyCircleIfsMetadata.instance;

  @override
  List<F0291SchottkyCircleIfsPreset> get presets => F0291SchottkyCircleIfsPresets.all;

  @override
  List<F0291SchottkyCircleIfsVariant> get variants => F0291SchottkyCircleIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
