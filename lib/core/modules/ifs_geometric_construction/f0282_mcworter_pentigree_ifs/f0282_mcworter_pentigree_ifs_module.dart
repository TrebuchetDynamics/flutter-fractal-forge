// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0282_mcworter_pentigree_ifs_presets.dart';
import 'f0282_mcworter_pentigree_ifs_variants.dart';
import 'f0282_mcworter_pentigree_ifs_metadata.dart';

/// McWorter Pentigree IFS — IFS & Geometric Construction.
class F0282McworterPentigreeIfs extends IFSModule {
  F0282McworterPentigreeIfs()
      : super(
          id: 'f0282_mcworter_pentigree_ifs',
          shader: 'shaders/f0282_mcworter_pentigree_ifs_gpu.frag',
        );

  @override
  F0282McworterPentigreeIfsMetadata get metadata => F0282McworterPentigreeIfsMetadata.instance;

  @override
  List<F0282McworterPentigreeIfsPreset> get presets => F0282McworterPentigreeIfsPresets.all;

  @override
  List<F0282McworterPentigreeIfsVariant> get variants => F0282McworterPentigreeIfsVariants.all;

  @override
  int get defaultIterations => 100000;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
