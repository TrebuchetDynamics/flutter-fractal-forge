// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0274_3d_cantor_dust_presets.dart';
import 'f0274_3d_cantor_dust_variants.dart';
import 'f0274_3d_cantor_dust_metadata.dart';

/// 3D Cantor Dust — IFS & Geometric Construction.
class F02743dCantorDust extends IFSModule {
  F02743dCantorDust()
      : super(
          id: 'f0274_3d_cantor_dust',
          shader: 'shaders/f0274_3d_cantor_dust_gpu.frag',
        );

  @override
  F02743dCantorDustMetadata get metadata => F02743dCantorDustMetadata.instance;

  @override
  List<F02743dCantorDustPreset> get presets => F02743dCantorDustPresets.all;

  @override
  List<F02743dCantorDustVariant> get variants => F02743dCantorDustVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
