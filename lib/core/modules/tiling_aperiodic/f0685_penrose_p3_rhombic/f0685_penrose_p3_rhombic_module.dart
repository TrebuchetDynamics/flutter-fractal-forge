// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/ifs_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0685_penrose_p3_rhombic_presets.dart';
import 'f0685_penrose_p3_rhombic_variants.dart';
import 'f0685_penrose_p3_rhombic_metadata.dart';

/// Penrose P3 Rhombic — Tiling & Aperiodic.
class F0685PenroseP3Rhombic extends IFSModule {
  F0685PenroseP3Rhombic()
      : super(
          id: 'f0685_penrose_p3_rhombic',
          shader: 'shaders/f0685_penrose_p3_rhombic_gpu.frag',
        );

  @override
  F0685PenroseP3RhombicMetadata get metadata => F0685PenroseP3RhombicMetadata.instance;

  @override
  List<F0685PenroseP3RhombicPreset> get presets => F0685PenroseP3RhombicPresets.all;

  @override
  List<F0685PenroseP3RhombicVariant> get variants => F0685PenroseP3RhombicVariants.all;

  @override
  int get defaultIterations => 6;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
  }
}
