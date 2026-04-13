// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0284_crystal_ifs_presets.dart';
import 'f0284_crystal_ifs_variants.dart';
import 'f0284_crystal_ifs_metadata.dart';

/// Crystal IFS — IFS & Geometric Construction.
class F0284CrystalIfs extends IFSModule {
  F0284CrystalIfs()
      : super(
          id: 'f0284_crystal_ifs',
          shader: 'shaders/f0284_crystal_ifs_gpu.frag',
        );

  @override
  F0284CrystalIfsMetadata get metadata => F0284CrystalIfsMetadata.instance;

  @override
  List<F0284CrystalIfsPreset> get presets => F0284CrystalIfsPresets.all;

  @override
  List<F0284CrystalIfsVariant> get variants => F0284CrystalIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
