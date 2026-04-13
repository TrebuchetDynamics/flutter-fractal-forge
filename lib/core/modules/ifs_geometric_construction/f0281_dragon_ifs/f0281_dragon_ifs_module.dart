// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0281_dragon_ifs_presets.dart';
import 'f0281_dragon_ifs_variants.dart';
import 'f0281_dragon_ifs_metadata.dart';

/// Dragon IFS — IFS & Geometric Construction.
class F0281DragonIfs extends IFSModule {
  F0281DragonIfs()
      : super(
          id: 'f0281_dragon_ifs',
          shader: 'shaders/f0281_dragon_ifs_gpu.frag',
        );

  @override
  F0281DragonIfsMetadata get metadata => F0281DragonIfsMetadata.instance;

  @override
  List<F0281DragonIfsPreset> get presets => F0281DragonIfsPresets.all;

  @override
  List<F0281DragonIfsVariant> get variants => F0281DragonIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
